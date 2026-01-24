extends Button
class_name SessionButton

signal created_session(duration:int)

@export var duration:int = 0 :
	set(_duration):
		duration = _duration
		text = str(duration) + " min"

func _ready() -> void:
	pressed.connect(start_session)

func start_session() -> void:
	created_session.emit(duration)
