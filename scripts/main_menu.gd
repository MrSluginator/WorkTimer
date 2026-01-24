extends PanelContainer

@onready var option_menu_scene:PackedScene = load("res://scenes/options_menu.tscn")

var window:Window

func _on_quit_pressed() -> void:
	Data._on_tree_exiting()
	get_tree().quit()

func _on_options_pressed() -> void:
	window = Window.new()
	window.size = Vector2i(1000, 600)
	window.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	var options_menu = option_menu_scene.instantiate()
	window.add_child(options_menu)
	add_child(window)
	options_menu.tree_exited.connect(_on_close_requested)
	window.close_requested.connect(_on_close_requested)

func _on_close_requested():
	if window:
		window.queue_free()
