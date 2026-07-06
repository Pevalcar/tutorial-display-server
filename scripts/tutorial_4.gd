extends Control

var original_window_size: Vector2i

@onready var display_info: RichTextLabel = %DisplayInfo
@onready var reset_button: Button = %ResetButton
@onready var dark_mode_info: Label = %DarkModeInfo
@onready var acc_info: Label = %AccInfo
@onready var orientation_info: Label = %OrientationInfo
@onready var clip_input: LineEdit = %ClipInput
@onready var btn_copy: Button = %BtnCopy
@onready var btn_paste: Button = %BtnPaste
@onready var tts_input: LineEdit = %TTSInput
@onready var btn_speak: Button = %BtnSpeak
@onready var btn_stop: Button = %BtnStop
@onready var tts_title: Label = %TTSTitle
@onready var btn_create_pip: Button = %BtnCreatePIP
@onready var btn_destroy_pip: Button = %BtnDestroyPIP

var _tts_voices: Array
var _pip_window: Window


func _ready() -> void:
	original_window_size = DisplayServer.window_get_size()
	_tts_voices = DisplayServer.tts_get_voices()
	reset_button.pressed.connect(_on_reset)
	btn_copy.pressed.connect(_on_copy_pressed)
	btn_paste.pressed.connect(_on_paste_pressed)
	%BtnKeyboard.pressed.connect(_on_keyboard_pressed)
	btn_speak.pressed.connect(_on_tts_speak)
	btn_stop.pressed.connect(_on_tts_stop)
	btn_create_pip.pressed.connect(_on_create_pip)
	btn_destroy_pip.pressed.connect(_on_destroy_pip)
	_update_info_labels()
	_update_display_info()


func _update_info_labels() -> void:
	var dark_supported: bool = DisplayServer.is_dark_mode_supported()
	var is_dark: bool = DisplayServer.is_dark_mode() if dark_supported else false
	dark_mode_info.text = "Modo oscuro soportado: %s | Activo: %s" % ["S\u00ed" if dark_supported else "No", "S\u00ed" if is_dark else "No"]
	if is_dark:
		theme = _create_dark_theme()

	var contrast: int = DisplayServer.accessibility_should_increase_contrast()
	var reduce_anim: int = DisplayServer.accessibility_should_reduce_animation()
	var reduce_trans: int = DisplayServer.accessibility_should_reduce_transparency()
	var screen_reader: int = DisplayServer.accessibility_screen_reader_active()
	acc_info.text = "Alto contraste: %s | Reducir anim: %s | Reducir trans: %s | Lector: %s" % [
		"S\u00ed" if contrast > 0 else "No",
		"S\u00ed" if reduce_anim > 0 else "No",
		"S\u00ed" if reduce_trans > 0 else "No",
		"S\u00ed" if screen_reader > 0 else "No",
	]

	var orient: int = DisplayServer.screen_get_orientation()
	orientation_info.text = "Orientaci\u00f3n de pantalla: %d (0=retrato, 1=paisaje, 2=invertido)" % orient

	if _tts_voices.size() > 0:
		tts_title.text = "Text-To-Speech (TTS): %d voces disponibles" % _tts_voices.size()
	else:
		tts_title.text = "TTS no disponible en este sistema"
		btn_speak.disabled = true
		btn_stop.disabled = true


func _update_display_info() -> void:
	var screen_count: int = DisplayServer.get_screen_count()
	var primary_size: Vector2i = DisplayServer.screen_get_size()
	var refresh: float = DisplayServer.screen_get_refresh_rate()
	var dark_mode: bool = DisplayServer.is_dark_mode() if DisplayServer.is_dark_mode_supported() else false
	var contrast: int = DisplayServer.accessibility_should_increase_contrast()
	var reduce_anim: int = DisplayServer.accessibility_should_reduce_animation()
	var screen_reader: int = DisplayServer.accessibility_screen_reader_active()

	display_info.text = (
			"[i]Monitores: %d | Res. primaria: %dx%d | Refresco: %.0f Hz\n" % [screen_count, primary_size.x, primary_size.y, refresh] +
			"Modo oscuro: %s | Alto contraste: %s | Reducir anim: %s | Lector: %s[/i]" % [
				"S\u00ed" if dark_mode else "No",
				"S\u00ed" if contrast > 0 else "No",
				"S\u00ed" if reduce_anim > 0 else "No",
				"S\u00ed" if screen_reader > 0 else "No",
			]
	)


func _on_keyboard_pressed() -> void:
	DisplayServer.virtual_keyboard_show("Texto de prueba", Rect2(0, 0, 0, 0), 0, -1)


func _on_copy_pressed() -> void:
	DisplayServer.clipboard_set(clip_input.text)
	btn_copy.text = "Copiado"
	var t := get_tree().create_timer(1.5)
	await t.timeout
	if is_instance_valid(btn_copy):
		btn_copy.text = "Copiar"


func _on_paste_pressed() -> void:
	clip_input.text = DisplayServer.clipboard_get()


func _on_tts_speak() -> void:
	if _tts_voices.size() > 0:
		var voice_id: String = _tts_voices[0].get(&"id", "")
		DisplayServer.tts_speak(tts_input.text, voice_id, 50, 1.0, 1.0, 0, false)


func _on_tts_stop() -> void:
	DisplayServer.tts_stop()


func _on_create_pip() -> void:
	if is_instance_valid(_pip_window):
		return

	_pip_window = Window.new()
	_pip_window.title = "PIP - Feed en Vivo (SubViewport)"
	_pip_window.size = Vector2i(320, 240)
	_pip_window.always_on_top = true
	_pip_window.initial_position = Window.WINDOW_INITIAL_POSITION_ABSOLUTE
	add_child(_pip_window)

	var main_pos := DisplayServer.window_get_position()
	var main_size := DisplayServer.window_get_size()
	_pip_window.position = main_pos + Vector2i(main_size.x + 20, 100)

	var viewport := SubViewport.new()
	viewport.size = Vector2i(320, 240)
	viewport.handle_input_locally = false
	viewport.transparent_bg = true
	_pip_window.add_child(viewport)

	var bg := ColorRect.new()
	bg.size = Vector2(320, 240)
	bg.color = Color(0.15, 0.25, 0.45)
	viewport.add_child(bg)

	var label := Label.new()
	label.text = "PIP\nEn Vivo"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2(320, 240)
	label.add_theme_font_size_override(&"font_size", 36)
	viewport.add_child(label)

	var sublabel := Label.new()
	sublabel.text = "Renderizado independiente"
	sublabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sublabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	sublabel.position = Vector2(0, 200)
	sublabel.size = Vector2(320, 40)
	sublabel.add_theme_font_size_override(&"font_size", 14)
	viewport.add_child(sublabel)

	btn_create_pip.text = "PIP Creado"
	btn_create_pip.disabled = true
	btn_destroy_pip.disabled = false


func _on_destroy_pip() -> void:
	if is_instance_valid(_pip_window):
		_pip_window.queue_free()
		_pip_window = null
	btn_create_pip.text = "Crear Ventana PIP"
	btn_create_pip.disabled = false
	btn_destroy_pip.disabled = true


func _create_dark_theme() -> Theme:
	var t := Theme.new()
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.12, 0.12, 0.14)
	s.set_corner_radius_all(6)
	t.set_stylebox(&"panel", &"Panel", s)
	t.set_color(&"font_color", &"Label", Color(0.9, 0.9, 0.95))
	t.set_color(&"font_color", &"Button", Color(0.9, 0.9, 0.95))
	return t


func _center_window() -> void:
	var screen := DisplayServer.window_get_current_screen()
	var screen_pos := DisplayServer.screen_get_position(screen)
	var screen_size := DisplayServer.screen_get_size(screen)
	var window_size := DisplayServer.window_get_size()
	DisplayServer.window_set_position(screen_pos + (screen_size - window_size) / 2)


func _reset_all() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, false)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, false)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, false)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_MOUSE_PASSTHROUGH, false)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_NO_FOCUS, false)
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	DisplayServer.window_set_mouse_passthrough(PackedVector2Array())
	DisplayServer.cursor_set_custom_image(null, DisplayServer.CURSOR_ARROW)
	DisplayServer.window_set_size(original_window_size)
	DisplayServer.window_set_title("Tutoria Display Server")
	_center_window()
	if is_instance_valid(_pip_window):
		_pip_window.queue_free()
		_pip_window = null
	theme = null


func _exit_tree() -> void:
	_reset_all()


func _on_reset() -> void:
	_reset_all()
	btn_create_pip.text = "Crear Ventana PIP"
	btn_create_pip.disabled = false
	btn_destroy_pip.disabled = true
	btn_copy.text = "Copiar"
	_update_info_labels()
	_update_display_info()
