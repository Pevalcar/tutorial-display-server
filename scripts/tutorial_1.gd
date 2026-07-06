extends Control

var original_window_size: Vector2i
var bouncing_velocity: Vector2 = Vector2(200, 150)
var bouncing_active: bool = false

@onready var bouncing_sprite: TextureRect = %BouncingSprite
@onready var display_info: RichTextLabel = %DisplayInfo
@onready var reset_button: Button = %ResetButton
@onready var status_label: Label = %StatusLabel
@onready var btn_bounce: Button = %BtnBounce


func _ready() -> void:
	original_window_size = DisplayServer.window_get_size()
	reset_button.pressed.connect(_on_reset)
	%BtnTitle.pressed.connect(_on_title)
	%BtnMinSize.pressed.connect(_on_min_size)
	%BtnResize.pressed.connect(_on_resize)
	%BtnCenter.pressed.connect(_on_center)
	btn_bounce.pressed.connect(_on_bounce_toggle)
	bouncing_sprite.visible = false
	_update_display_info()


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


func _on_title() -> void:
	DisplayServer.window_set_title("Tutorial 1: Mi Primera Ventana")
	status_label.text = "T\u00edtulo cambiado"


func _on_min_size() -> void:
	DisplayServer.window_set_min_size(Vector2i(800, 600))
	status_label.text = "Tama\u00f1o m\u00ednimo: 800x600"


func _on_resize() -> void:
	DisplayServer.window_set_size(Vector2i(1024, 768))
	status_label.text = "Ventana redimensionada a 1024x768"


func _on_center() -> void:
	_center_window()
	status_label.text = "Ventana centrada"


func _on_bounce_toggle() -> void:
	bouncing_active = not bouncing_active
	bouncing_sprite.visible = bouncing_active
	btn_bounce.text = "5. Sprite Rebotante: " + ("ON" if bouncing_active else "OFF")
	if bouncing_active:
		bouncing_sprite.position = Vector2.ZERO
		status_label.text = "Sprite activado"
	else:
		status_label.text = "Sprite desactivado"


func _process(delta: float) -> void:
	if bouncing_active:
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
	bouncing_active = false
	bouncing_sprite.visible = false
	btn_bounce.text = "5. Sprite Rebotante: OFF"
	status_label.text = "Todo reiniciado"
	_update_display_info()
