extends VBoxContainer
class_name Task

signal task_deleted

@onready var task_scene:PackedScene = load("res://scenes/task.tscn")

func _on_add_child_pressed() -> void:
	%Duration.hide()
	
	var new_task:Task = task_scene.instantiate()
	%SubTaskList.add_child(new_task)
	new_task.task_deleted.connect(_on_task_deleted)

func _on_task_deleted() -> void:
	if %SubTaskList.get_child_count() <= 0:
		%Duration.show()

func _on_delete_pressed() -> void:
	task_deleted.emit()
	queue_free()
