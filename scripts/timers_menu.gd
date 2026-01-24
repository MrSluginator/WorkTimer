extends PanelContainer

var session_scene:PackedScene = load("res://scenes/session_button.tscn")
var working_scene:PackedScene = load("res://scenes/working_menu.tscn")

func _ready() -> void:
	for t in [15, 30, 60, 120]:
		var button:SessionButton = session_scene.instantiate()
		button.duration = t
		button.created_session.connect(_on_create_session)
		
		%SessionList.add_child(button)

func _on_create_session(duration:int) -> void:
	var working_menu:WorkingMenu = working_scene.instantiate()
	working_menu.duration = duration
	get_tree().root.add_child(working_menu)
	get_node("/root/MainMenu").hide()

func _on_long_session_created_session(duration: int) -> void:
	_on_create_session(duration)
