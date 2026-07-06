extends Node3D

const MOUSE_SENSITIVITY: float = 0.003

@onready var camera: Camera3D = %Camera3D

var _camera_rot_x: float = 0.0
var _camera_rot_y: float = 0.0
var _previous_mouse_mode: int


func _ready() -> void:
	_previous_mouse_mode = DisplayServer.mouse_get_mode()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	DisplayServer.window_set_title("Modo 3D \u2014 Rat\u00f3n Capturado (ESC para salir)")


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	DisplayServer.mouse_set_mode(_previous_mouse_mode)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_camera_rot_y -= event.relative.x * MOUSE_SENSITIVITY
		_camera_rot_x -= event.relative.y * MOUSE_SENSITIVITY
		_camera_rot_x = clampf(_camera_rot_x, -1.4, 1.4)
		camera.rotation.x = _camera_rot_x
		camera.rotation.y = _camera_rot_y

	if event.is_action_pressed(&"ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			_return_to_main()


func _return_to_main() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file(&"res://scenes/tutorial_3.tscn")
