extends Control

var original_window_size: Vector2i
var bouncing_velocity: Vector2 = Vector2(200, 150)

@onready var bouncing_sprite: TextureRect = %BouncingSprite
@onready var display_info: RichTextLabel = %DisplayInfo
@onready var reset_button: Button = %ResetButton
@onready var screen_info: Label = %ScreenInfo

var _toggle_data: Array[Dictionary]


func _ready() -> void:
	original_window_size = DisplayServer.window_get_size()
	reset_button.pressed.connect(_on_reset)
	%BtnFullscreen.pressed.connect(_on_fullscreen)
	%BtnExclusive.pressed.connect(_on_exclusive)
	%BtnWindowed.pressed.connect(_on_windowed)
	_toggle_data = [
		{"btn": %BtnBorderless, "flag": DisplayServer.WINDOW_FLAG_BORDERLESS, "label": "Sin Bordes"},
		{"btn": %BtnAlwaysOnTop, "flag": DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, "label": "Siempre al Frente"},
		{"btn": %BtnResizeDisabled, "flag": DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, "label": "Redimensionar"},
	]
	for i in _toggle_data.size():
		_toggle_data[i].btn.pressed.connect(_on_toggle.bind(i))
	_refresh_toggle_texts()
	_update_display_info()
	_update_screen_info()


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


func _update_screen_info() -> void:
	var count: int = DisplayServer.get_screen_count()
	screen_info.text = "Monitores detectados: %d\n" % count
	for i in count:
		var rect := DisplayServer.screen_get_usable_rect(i)
		var res := DisplayServer.screen_get_size(i)
		var rate := DisplayServer.screen_get_refresh_rate(i)
		var orient := DisplayServer.screen_get_orientation(i)
		screen_info.text += "Monitor %d: %dx%d @ %.0f Hz (usable: %dx%d, orient: %d)\n" % [i, res.x, res.y, rate, rect.size.x, rect.size.y, orient]


func _refresh_toggle_texts() -> void:
	for data in _toggle_data:
		var current: bool = DisplayServer.window_get_flag(data.flag)
		data.btn.text = data.label + ": " + ("ON" if current else "OFF")


func _on_toggle(idx: int) -> void:
	var data: Dictionary = _toggle_data[idx]
	var current: bool = DisplayServer.window_get_flag(data.flag)
	DisplayServer.window_set_flag(data.flag, not current)
	data.btn.text = data.label + ": " + ("ON" if not current else "OFF")


func _on_fullscreen() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	DisplayServer.window_set_title("Modo: Pantalla Completa")


func _on_exclusive() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	DisplayServer.window_set_title("Modo: Fullscreen Exclusivo")


func _on_windowed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1024, 768))
	_center_window()
	DisplayServer.window_set_title("Tutoria Display Server \u2014 Tutorial 2: El Director de Pantallas")


func _process(delta: float) -> void:
	_update_bouncing_sprite(delta)


func _update_bouncing_sprite(delta: float) -> void:
	if not bouncing_sprite or not bouncing_sprite.is_visible_in_tree():
		return
	var parent_size = bouncing_sprite.get_parent().size
	if parent_size == Vector2.ZERO:
		return
	var sprite_size := bouncing_sprite.custom_minimum_size
	var pos := bouncing_sprite.position + bouncing_velocity * delta
	if pos.x <= 0 or pos.x + sprite_size.x >= parent_size.x:
		bouncing_velocity.x = -bouncing_velocity.x
		pos.x = clamp(pos.x, 0, parent_size.x - sprite_size.x)
	if pos.y <= 0 or pos.y + sprite_size.y >= parent_size.y:
		bouncing_velocity.y = -bouncing_velocity.y
		pos.y = clamp(pos.y, 0, parent_size.y - sprite_size.y)
	bouncing_sprite.position = pos


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


func _exit_tree() -> void:
	_reset_all()


func _on_reset() -> void:
	_reset_all()
	_refresh_toggle_texts()
	_update_display_info()
	_update_screen_info()
