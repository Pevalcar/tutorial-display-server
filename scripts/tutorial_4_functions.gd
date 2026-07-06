extends Control

func _ready() -> void:
	# =========================================================================
	# TUTORIAL 4 — Accessibility, System, and Multi-Window (PIP)
	# =========================================================================

	# --------------------------------------------------------------------------
	# is_dark_mode_supported / is_dark_mode
	# --------------------------------------------------------------------------
	# System theme detection (dark/light mode).
	#
	# How it works: See tutorial 1 for full documentation.
	#   In this tutorial, it is used to apply a dark theme to the game
	#   automatically if the system is in dark mode.
	#
	# Example:
	var dark_supported: bool = DisplayServer.is_dark_mode_supported()
	var is_dark: bool = DisplayServer.is_dark_mode() if dark_supported else false
	if is_dark:
		# Apply dark theme
		pass

	# --------------------------------------------------------------------------
	# accessibility_should_increase_contrast
	# --------------------------------------------------------------------------
	# Queries whether the user needs high contrast.
	# See tutorial 1 for full documentation.
	var contrast: int = DisplayServer.accessibility_should_increase_contrast()

	# --------------------------------------------------------------------------
	# accessibility_should_reduce_animation
	# --------------------------------------------------------------------------
	# Queries whether the user needs reduced animations.
	# See tutorial 1 for full documentation.
	var reduce_anim: int = DisplayServer.accessibility_should_reduce_animation()

	# --------------------------------------------------------------------------
	# accessibility_should_reduce_transparency
	# --------------------------------------------------------------------------
	# Indicates whether the user has requested reduced transparency in the OS.
	#
	# How it works: Similar to reduce_animation, but for transparency
	#   and blur effects. On Windows: "Transparency effects" disabled.
	#   On macOS: "Reduce transparency" enabled.
	#
	# Usage: If it returns > 0, avoid using transparency, blur, or
	#   glass effects in the UI.
	#
	# Returns: int
	#
	# Example:
	var reduce_trans: int = DisplayServer.accessibility_should_reduce_transparency()

	# --------------------------------------------------------------------------
	# accessibility_screen_reader_active
	# --------------------------------------------------------------------------
	# See tutorial 1 for full documentation.
	var screen_reader: int = DisplayServer.accessibility_screen_reader_active()

	# --------------------------------------------------------------------------
	# virtual_keyboard_show
	# --------------------------------------------------------------------------
	# Shows the system virtual keyboard (Android, iOS, Web only).
	#
	# How it works: On mobile devices and browsers, shows the OS
	#   virtual keyboard for text input. Has no effect on desktop.
	#   The position is specified with a Rect2 so the OS can place
	#   the keyboard without covering the text field.
	#
	# Usage: Pass initial text, a position rectangle,
	#   keyboard type (0 = default), and max length (-1 = unlimited).
	#   Note: the second parameter is Rect2, not two separate ints.
	#
	# Parameters:
	#   existing_text (String): Pre-filled text.
	#   position (Rect2): Text field area in screen coordinates.
	#   type (int): Keyboard type (0=default, 1=url, 2=number, etc.).
	#   max_length (int): -1 for unlimited.
	#
	# Example:
	DisplayServer.virtual_keyboard_show("Texto de prueba", Rect2(0, 0, 0, 0), 0, -1)

	# --------------------------------------------------------------------------
	# screen_get_orientation
	# --------------------------------------------------------------------------
	# Returns the screen orientation (see tutorial 2).
	#
	# Example:
	var orient: int = DisplayServer.screen_get_orientation()
	# 0 = portrait, 1 = landscape, 2 = inverted portrait, 3 = inverted landscape

	# --------------------------------------------------------------------------
	# clipboard_set / clipboard_get
	# --------------------------------------------------------------------------
	# Accesses the system clipboard.
	#
	# How it works:
	#   clipboard_set(text): Writes text to the OS clipboard.
	#     Any application can paste that text afterwards.
	#   clipboard_get(): Reads the current text from the clipboard.
	#     Returns the text the user copied from any application.
	#
	# Usage: clipboard_set for a "Copy" button, clipboard_get for "Paste".
	#   Always verify the text is not empty before copying.
	#
	# Parameters:
	#   text (String): Text to copy (clipboard_set).
	#
	# Returns (clipboard_get): String
	#
	# Example:
	DisplayServer.clipboard_set("Texto copiado desde el juego")
	var pasted_text: String = DisplayServer.clipboard_get()

	# --------------------------------------------------------------------------
	# tts_get_voices
	# --------------------------------------------------------------------------
	# Gets the list of available Text-To-Speech voices.
	#
	# How it works: Queries the OS for installed voices. Each voice is a
	#   Dictionary with keys such as "id", "name", "language".
	#   On Windows it uses Narrator voices, on macOS VoiceOver voices,
	#   on Linux it may use espeak or speech-dispatcher.
	#
	# Usage: Always check the array is not empty before attempting
	#   to use TTS. If empty, TTS is not available.
	#
	# Returns: Array[Dictionary]
	#
	# Example:
	var voices: Array = DisplayServer.tts_get_voices()
	if voices.size() > 0:
		print("TTS disponible con %d voces" % voices.size())
	else:
		print("TTS no disponible en este sistema")

	# --------------------------------------------------------------------------
	# tts_speak
	# --------------------------------------------------------------------------
	# Makes the system speak text using a TTS voice.
	#
	# How it works: Queues the text in the OS TTS engine. The chosen
	#   voice will read the text in the corresponding language.
	#   The call is asynchronous — the game continues while speaking.
	#
	# Usage: Pass the text to speak, the voice ID (from tts_get_voices),
	#   volume (0-100), pitch (0.0-2.0), and rate (0.1-10.0).
	#   The last parameter (utterance_id) is used to identify the
	#   utterance in subsequent signals.
	#
	# Parameters:
	#   text (String): Text to read.
	#   voice_id (String): Voice ID (from tts_get_voices).
	#   volume (int): 0-100.
	#   pitch (float): 0.0-2.0 (1.0 = normal).
	#   rate (float): 0.1-10.0 (1.0 = normal).
	#   utterance_id (int): Tracking ID (0 = automatic).
	#   interrupt (bool): true = stop and start, false = queue.
	#
	# Example:
	var voice_id: String = voices[0].get(&"id", "") if voices.size() > 0 else ""
	if voice_id != "":
		DisplayServer.tts_speak("Bienvenido al tutorial de DisplayServer", voice_id, 50, 1.0, 1.0, 0, false)

	# --------------------------------------------------------------------------
	# tts_stop
	# --------------------------------------------------------------------------
	# Stops any ongoing speech synthesis.
	#
	# How it works: Clears the TTS queue and stops playback
	#   immediately. There is no way to resume — it must start over.
	#
	# Usage: For a "Stop" button or when the user changes scenes
	#   while TTS is playing.
	#
	# Example:
	DisplayServer.tts_stop()

	# --------------------------------------------------------------------------
	# Window + SubViewport — Picture-in-Picture (PIP)
	# --------------------------------------------------------------------------
	# Creates a secondary window with its own render viewport.
	#
	# How it works:
	#   1. A Window node is created with add_child() — it is a real OS window.
	#   2. A SubViewport is assigned as its child, acting as an independent
	#      render "canvas".
	#   3. Nodes are added inside the SubViewport (ColorRect, Label, etc.),
	#      which are rendered only in that PIP window.
	#   4. SubViewport has handle_input_locally = false to avoid input
	#      conflicts between windows.
	#
	# DisplayServer does NOT have a window_create() function — secondary
	#   windows are created using Godot's Window node.
	#
	# Usage: Create a Window, add a SubViewport, populate the viewport
	#   with visual nodes. Always clean up with queue_free() when closing.
	#
	# Important Window properties:
	#   title (String): Window title.
	#   size (Vector2i): Size in pixels.
	#   always_on_top (bool): Keep above other windows.
	#   initial_position: WINDOW_INITIAL_POSITION_ABSOLUTE for manual positioning.
	#   position (Vector2i): Screen position (if initial_position=ABSOLUTE).
	#
	# Important SubViewport properties:
	#   size (Vector2i): Viewport size.
	#   handle_input_locally (bool): false to avoid conflict with parent window.
	#   transparent_bg (bool): true for transparent background.
	#
	# Full example:
	var pip_window := Window.new()
	pip_window.title = "PIP - Feed en Vivo"
	pip_window.size = Vector2i(320, 240)
	pip_window.always_on_top = true
	pip_window.initial_position = Window.WINDOW_INITIAL_POSITION_ABSOLUTE
	add_child(pip_window)

	# Position PIP window to the right of the main window
	var main_pos := DisplayServer.window_get_position()
	var main_size := DisplayServer.window_get_size()
	pip_window.position = main_pos + Vector2i(main_size.x + 20, 100)

	# Create the SubViewport for independent rendering
	var viewport := SubViewport.new()
	viewport.size = Vector2i(320, 240)
	viewport.handle_input_locally = false
	viewport.transparent_bg = true
	pip_window.add_child(viewport)

	# Populate the viewport with visual content
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

	# To close the PIP window:
	#   pip_window.queue_free()
	#   pip_window = null
