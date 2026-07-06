extends Control

func _ready() -> void:
	# Switches the window to fullscreen mode (non-exclusive).
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	# Exclusive fullscreen: the game has full control of the screen.
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

	# --------------------------------------------------------------------------
	# window_set_mode — WINDOW_MODE_WINDOWED
	# --------------------------------------------------------------------------
	# Returns the window to normal windowed mode (not fullscreen).

	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1024, 768))

	# Enables or disables the window borders and title bar.
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	# To read the current state:
	var is_borderless: bool = DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS)

	# Keeps the window always on top of other windows.
	#
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, true)

	# Disables or enables user window resizing.

	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)

	# Reads the current state of a window flag.
	#
	var current: bool = DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, not current)

	# Returns the usable area of a monitor (excluding taskbars, docks).

	var usable: Rect2i = DisplayServer.screen_get_usable_rect(0)

	# Returns the current orientation of the monitor.

	var orient: int = DisplayServer.screen_get_orientation(0)

	# The above functions are also used together to display
	# detailed information about all detected monitors.

	var count: int = DisplayServer.get_screen_count()
	for i in count:
		var res: Vector2i = DisplayServer.screen_get_size(i)
		var rate: float = DisplayServer.screen_get_refresh_rate(i)
		var rect: Rect2i = DisplayServer.screen_get_usable_rect(i)
		var orientation: int = DisplayServer.screen_get_orientation(i)
		print(
			"Monitor %d: %dx%d @ %.0f Hz (usable: %dx%d, orient: %d)" % [
				i,
				res.x,
				res.y,
				rate,
				rect.size.x,
				rect.size.y,
				orientation,
			],
		)
