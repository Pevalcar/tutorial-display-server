extends Control

const CURSOR_TEX := preload("res://assets/cursor_custom.png")

var original_window_size: Vector2i

@onready var display_info: RichTextLabel = %DisplayInfo
@onready var reset_button: Button = %ResetButton
@onready var game_area: Control = %GameArea
@onready var godot_sprite: TextureRect = %GodotSprite
@onready var score_label: Label = %ScoreLabel
@onready var btn_reset_score: Button = %BtnResetScore

var _toggle_data: Array[Dictionary]
var _cursor_active: bool = false
var _confined: bool = false
var _score: int = 0


func _ready() -> void:
	original_window_size = DisplayServer.window_get_size()
	reset_button.pressed.connect(_on_reset)
	_toggle_data = [
		{ "btn": %BtnMousePassthrough, "flag": DisplayServer.WINDOW_FLAG_MOUSE_PASSTHROUGH, "label": "Mouse Passthrough" },
		{ "btn": %BtnTransparent, "flag": DisplayServer.WINDOW_FLAG_TRANSPARENT, "label": "Transparencia" },
		{ "btn": %BtnBorderless, "flag": DisplayServer.WINDOW_FLAG_BORDERLESS, "label": "Sin Bordes" },
	]
	for i in _toggle_data.size():
		_toggle_data[i].btn.pressed.connect(_on_toggle.bind(i))
	_refresh_toggle_texts()
	%BtnCursor.pressed.connect(_on_cursor_pressed)
	%BtnConfine.pressed.connect(_on_confine_pressed)
	%Btn3D.pressed.connect(_on_open_3d)
	btn_reset_score.pressed.connect(_on_reset_score)
	godot_sprite.gui_input.connect(_on_godot_input)
	_update_display_info()
	_move_godot()


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


func _refresh_toggle_texts() -> void:
	for data in _toggle_data:
		var current: bool = DisplayServer.window_get_flag(data.flag)
		data.btn.text = data.label + ": " + ("ON" if current else "OFF")


func _on_toggle(idx: int) -> void:
	var data: Dictionary = _toggle_data[idx]
	var current: bool = DisplayServer.window_get_flag(data.flag)
	DisplayServer.window_set_flag(data.flag, not current)
	data.btn.text = data.label + ": " + ("ON" if not current else "OFF")


func _on_cursor_pressed() -> void:
	_cursor_active = not _cursor_active
	if _cursor_active:
		DisplayServer.cursor_set_custom_image(CURSOR_TEX, DisplayServer.CURSOR_ARROW, Vector2(16, 16))
	else:
		DisplayServer.cursor_set_custom_image(null, DisplayServer.CURSOR_ARROW)
	%BtnCursor.text = "Cursor Personalizado: " + ("ON" if _cursor_active else "OFF")


func _on_confine_pressed() -> void:
	_confined = not _confined
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CONFINED if _confined else DisplayServer.MOUSE_MODE_VISIBLE)
	%BtnConfine.text = "Confinar Rat\u00f3n: " + ("ON" if _confined else "OFF")


func _on_open_3d() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1024, 768))
	_center_window()
	get_tree().change_scene_to_file(&"res://scenes/level3_3d.tscn")


func _move_godot() -> void:
	if not game_area or not godot_sprite:
		return
	var parent_size := game_area.size
	var sprite_size := godot_sprite.custom_minimum_size
	var max_x := maxi(0, int(parent_size.x - sprite_size.x))
	var max_y := maxi(0, int(parent_size.y - sprite_size.y))
	godot_sprite.position = Vector2(
		randi() % (maxi(1, max_x + 1)),
		randi() % (maxi(1, max_y + 1)),
	)


func _on_godot_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_score += 1
		score_label.text = "Puntuaci\u00f3n: %d" % _score
		_move_godot()


func _on_reset_score() -> void:
	_score = 0
	score_label.text = "Puntuaci\u00f3n: 0"
	_move_godot()


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
	_cursor_active = false
	_confined = false
	%BtnCursor.text = "Cursor Personalizado: OFF"
	%BtnConfine.text = "Confinar Rat\u00f3n: OFF"
	_refresh_toggle_texts()
	_score = 0
	score_label.text = "Puntuaci\u00f3n: 0"
	_update_display_info()
	_move_godot()
