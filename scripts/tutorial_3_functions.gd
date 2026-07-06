extends Control

func _ready() -> void:
	# =========================================================================
	# TUTORIAL 3 — Transparent Window, Cursor, Confinement, and 3D
	# =========================================================================

	# --------------------------------------------------------------------------
	# window_set_flag — WINDOW_FLAG_MOUSE_PASSTHROUGH
	# --------------------------------------------------------------------------
	# Makes mouse clicks pass through the window as if it didn't exist.
	#
	# How it works: When active, all mouse events are passed through
	#   to the window underneath. The game window becomes a "ghost"
	#   for the input system. Visual content remains visible (useful
	#   when combined with TRANSPARENT).
	#
	# Usage: For overlays, desktop widgets, or notifications that
	#   should not intercept clicks. Requires WINDOW_FLAG_TRANSPARENT
	#   enabled to make visual sense.
	#
	# Parameters:
	#   flag (WINDOW_FLAG_MOUSE_PASSTHROUGH): The constant.
	#   enabled (bool): true to enable.
	#
	# Example:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_MOUSE_PASSTHROUGH, true)

	# --------------------------------------------------------------------------
	# window_set_flag — WINDOW_FLAG_TRANSPARENT
	# --------------------------------------------------------------------------
	# Makes the window background transparent.
	#
	# How it works: The OS window is configured with an alpha channel.
	#   Transparent game pixels let the desktop or windows behind show
	#   through. Only works with modern window compositors.
	#   Generally requires BORDERLESS = true.
	#
	# Usage: For non-rectangular window shapes, overlays,
	#   or visual effects that blend with the desktop.
	#
	# Example:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true)

	# --------------------------------------------------------------------------
	# window_set_flag — WINDOW_FLAG_BORDERLESS
	# --------------------------------------------------------------------------
	# Removes window decoration (borders, title bar).
	#
	# How it works: See tutorial 2 for full documentation.
	#   In this tutorial, it is used as a requirement for TRANSPARENT.
	#
	# Example:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

	# --------------------------------------------------------------------------
	# cursor_set_custom_image
	# --------------------------------------------------------------------------
	# Replaces the mouse cursor with a custom texture.
	#
	# How it works: DisplayServer loads the texture and registers it as
	#   a system cursor for a specific shape (CURSOR_ARROW, etc.).
	#   The hotspot defines which pixel of the texture is the click point.
	#   To restore: call with null as the first parameter.
	#
	# Usage: Preload the texture with preload() and pass it together with
	#   the cursor shape you want to replace. The hotspot must be
	#   the coordinate within the texture that acts as the tip.
	#
	# Parameters:
	#   cursor (Texture2D | null): The cursor texture. null = restore.
	#   shape (CURSOR_*): The cursor shape to replace.
	#   hotspot (Vector2): Click point within the texture.
	#
	# Example (enable):
	const CURSOR_TEX := preload("res://assets/cursor_custom.png")
	DisplayServer.cursor_set_custom_image(CURSOR_TEX, DisplayServer.CURSOR_ARROW, Vector2(16, 16))
	# Example (restore):
	DisplayServer.cursor_set_custom_image(null, DisplayServer.CURSOR_ARROW)

	# --------------------------------------------------------------------------
	# mouse_set_mode — MOUSE_MODE_CONFINED
	# --------------------------------------------------------------------------
	# Confines the mouse within the game window boundaries.
	#
	# How it works: The OS limits mouse movement to the window area.
	#   The cursor cannot leave the window edges but remains visible
	#   and functional. It is less aggressive than MOUSE_MODE_CAPTURED.
	#
	# Usage: For games that need the mouse inside the window
	#   but do not require full capture (strategy, MOBA, puzzles).
	#
	# Example:
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CONFINED)
	# To restore:
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)

	# --------------------------------------------------------------------------
	# mouse_get_mode
	# --------------------------------------------------------------------------
	# Returns the current mouse mode.
	#
	# How it works: Queries the internal mouse mode state. Useful for
	#   saving and restoring the mode when entering/exiting a 3D scene.
	#
	# Returns: MOUSE_MODE_* (int)
	#
	# Example:
	var previous_mode: int = DisplayServer.mouse_get_mode()

	# --------------------------------------------------------------------------
	# Input.mouse_mode — MOUSE_MODE_CAPTURED (3D scenes only)
	# --------------------------------------------------------------------------
	# Captures the mouse: the cursor is hidden and movements are reported
	#   as InputEventMouseMotion events without screen boundaries.
	#
	# How it works: Godot hides the cursor and virtually "confines" the mouse.
	#   Each physical mouse movement is translated into event.relative,
	#   which indicates the offset from the last frame. The mouse never
	#   hits the screen edges.
	#
	# Usage: For 3D games with mouse camera control (FPS, TPS).
	#   Activated via Input.mouse_mode, not DisplayServer.
	#
	# Difference from MOUSE_CONFINED: CAPTURED hides the cursor and allows
	#   unlimited movement; CONFINED keeps the cursor visible but
	#   limits it to the window.
	#
	# Example:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# To restore:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# --------------------------------------------------------------------------
	# InputEventMouseMotion — Mouse camera control (3D)
	# --------------------------------------------------------------------------
	# Processes mouse movement to rotate the camera in 3D.
	#
	# How it works: Each frame, InputEventMouseMotion.relative contains
	#   the mouse offset from the previous frame. It is multiplied
	#   by a sensitivity factor and applied to the camera rotation.
	#
	# Usage: In _input(event), check if event is InputEventMouseMotion
	#   and if the mouse is captured. Apply the offset to the rotation.
	#
	# Constants:
	#   MOUSE_SENSITIVITY (float): Sensitivity factor (e.g. 0.003).
	#
	# Example:
	#   const MOUSE_SENSITIVITY: float = 0.003
	#   var _camera_rot_x: float = 0.0
	#   var _camera_rot_y: float = 0.0
	#
	#   func _input(event: InputEvent) -> void:
	#       if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
	#           _camera_rot_y -= event.relative.x * MOUSE_SENSITIVITY
	#           _camera_rot_x -= event.relative.y * MOUSE_SENSITIVITY
	#           _camera_rot_x = clampf(_camera_rot_x, -1.4, 1.4)
	#           camera.rotation.x = _camera_rot_x
	#           camera.rotation.y = _camera_rot_y

	# --------------------------------------------------------------------------
	# InputEventMouseButton — Click detection on sprite (minigame)
	# --------------------------------------------------------------------------
	# Detects when the user clicks on a UI element.
	#
	# How it works: Connects the gui_input signal of a TextureRect. When
	#   the user left-clicks on it, the event fires.
	#
	# Usage: Useful for minigames, custom buttons, or interactive
	#   elements that don't use the Button's pressed signal.
	#
	# Example:
	#   func _on_godot_input(event: InputEvent) -> void:
	#       if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
	#           score += 1
	#           _move_godot_to_random_position()

	# --------------------------------------------------------------------------
	# change_scene_to_file — Scene navigation
	# --------------------------------------------------------------------------
	# Switches to another scene in the project.
	#
	# How it works: Godot unloads the current scene and loads the new one
	#   from the specified path. It is an asynchronous operation that
	#   occurs at the end of the current frame.
	#
	# Usage: Pass the full path using the &"res://..." literal.
	#   Before switching, restore DisplayServer state if needed
	#   (window mode, size, etc.) so the target scene starts
	#   with predictable values.
	#
	# Parameters:
	#   path (String): Path to the .tscn file.
	#
	# Example:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1024, 768))
	get_tree().change_scene_to_file(&"res://scenes/level3_3d.tscn")
