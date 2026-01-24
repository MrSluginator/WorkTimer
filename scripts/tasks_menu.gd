extends CenterContainer

@onready var task_scene:PackedScene = load("res://scenes/task.tscn")

func _on_new_task_pressed() -> void:
	var task:Task = task_scene.instantiate()
	%TaskList.add_child(task)
	%TaskList.move_child(task, get_children().size() - 2)
