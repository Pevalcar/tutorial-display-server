extends Control

func _ready() -> void:
	# Changes the OS window title bar text.

	DisplayServer.window_set_title("Tutorial 1: Mi Primera Ventana")

	# Sets the minimum size the user can resize the window to.

	DisplayServer.window_set_min_size(Vector2i(800, 600))

	# Changes the current game window size.

	DisplayServer.window_set_size(Vector2i(1024, 768))

	# Places the window at a specific screen position.

	# Functions involved:
	#   window_get_current_screen()  → int (screen index)
	#   screen_get_position(screen)  → Vector2i (screen origin)
	#   screen_get_size(screen)      → Vector2i (screen resolution)
	#   window_get_size()            → Vector2i (current window size)
	#   window_set_position(pos)     → void (positions the window)

	var screen := DisplayServer.window_get_current_screen()
	var screen_pos := DisplayServer.screen_get_position(screen)
	var screen_size := DisplayServer.screen_get_size(screen)
	var window_size := DisplayServer.window_get_size()
	DisplayServer.window_set_position(screen_pos + (screen_size - window_size) / 2)

	# Returns the number of monitors detected by the system.

	# Usage: Useful for displaying info to the user or deciding which
	#   screen to open additional windows on.

	var screen_count: int = DisplayServer.get_screen_count()

	# How it works: Gets the pixel size of the monitor. Includes
	#   the entire monitor area, not just the usable one (excluding taskbars).

	var primary_size: Vector2i = DisplayServer.screen_get_size()
	# For a specific screen:
	var size_monitor_1: Vector2i = DisplayServer.screen_get_size(1)

	# Returns the monitor refresh rate in Hz.
	#
	# How it works: Queries the monitor's vertical refresh rate.
	#   Useful for syncing V-Sync or displaying technical info.
	#

	var refresh: float = DisplayServer.screen_get_refresh_rate()

	#
	# Indicates whether the OS supports dark mode.

	var dark_supported: bool = DisplayServer.is_dark_mode_supported()

	# Returns whether the system is currently in dark mode.
	#
	# How it works: Reads the OS setting. Should only be called if
	#   is_dark_mode_supported() returns true.

	var is_dark: bool = DisplayServer.is_dark_mode() if dark_supported else false

	# Indicates whether the user has requested high contrast in the OS.

	# Example:
	var contrast: int = DisplayServer.accessibility_should_increase_contrast()

	# Indicates whether the user has requested reduced animations in the OS.

	# Usage: If it returns > 0, disable animations, transitions, and
	#   non-essential visual effects.
	#
	# Returns: int
	#
	# Example:
	var reduce_anim: int = DisplayServer.accessibility_should_reduce_animation()

	# --------------------------------------------------------------------------

	# Indicates whether a screen reader is active (NVDA, JAWS, VoiceOver, etc.).
	#
	# How it works: The OS notifies when a screen reader is active.
	#   The game should provide alternative text descriptions.
	#
	# Usage: If it returns > 0, ensure all interactive elements have
	#   accessible text (AccessibleDescription, etc.).
	#
	# Returns: int
	#
	# Example:
	var screen_reader: int = DisplayServer.accessibility_screen_reader_active()
