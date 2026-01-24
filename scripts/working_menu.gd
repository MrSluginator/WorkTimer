extends PanelContainer
class_name WorkingMenu

# duration is in minutes
@export var duration:int = 0

var elapsed_time:float
var orig_size:Vector2i

@onready var checkin_scene:PackedScene = load("res://scenes/checkin_menu.tscn")
var pomodoro:Timer
var interval:Timer

var paused:bool = false

func _ready() -> void:
	if (duration > 0):
		%TimerProgressBar.animate_to_value(100, duration * 60)
	else:
		%TimerProgressBar.animate_to_value(100, Data.long_session_interval * 60)
		var resetTimer = Timer.new()
		resetTimer.wait_time = Data.long_session_interval * 60
		resetTimer.timeout.connect(func(): 
			%TimerProgressBar.value = 0
			%TimerProgressBar.animate_to_value(100, Data.long_session_interval * 60))
		add_child(resetTimer)
		resetTimer.start()
	
	orig_size = get_window().size
	get_window().size = size
	DisplayServer.window_set_size(size)
	
	if Data.intervals:
		interval = Timer.new()
		interval.wait_time = Data.interval_duration * 60
		interval.timeout.connect(show_checkin)
		add_child(interval)
		interval.start()
	if Data.pomodoro:
		pomodoro = Timer.new()
		pass

func show_checkin():
	var checkin_name:String = "checkin"
	if has_node(checkin_name):
		return
	var window = Window.new()
	var checkin:Control = checkin_scene.instantiate()
	window.add_child(checkin)
	window.always_on_top = true
	window.size = Vector2i(400, 300)
	window.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	checkin.tree_exited.connect(func(): window.queue_free())
	add_child(window)
	window.name = checkin_name
	$NotificationPlayer.play()

func _process(delta: float) -> void:
	if paused:
		return
	
	elapsed_time += delta
	
	if duration <= 0:
		%Time.text = format_time(elapsed_time)
	else:
		%Time.text = format_time(duration * 60 - elapsed_time)
		if elapsed_time >= duration * 60:
			show_checkin()
			paused = true
			var checkin:Window = get_node("checkin")
			if checkin:
				await checkin.tree_exited
			complete_work()

func format_time(time:float) -> String:
	var hours:int = floor(time / 3600)
	var minutes:int = floor((time - 3600 * hours) / 60)
	var seconds:int = floor((time - 3600 * hours - 60 * minutes))
	if hours > 0:
		return "{0}:{1}:{2}".format([hours, minutes, seconds])
	return "{0}:{1}".format([minutes, seconds])

func complete_work() -> void:
	var time:int
	if duration <= 0:
		time = int(elapsed_time / 60)
	else:
		time = min(duration, elapsed_time / 60)
	if time >= 1:
		Data.add_entry(time, Data.current_tasks)
		Data.current_tasks.clear()
	
	$CompletionPlayer.play()
	await get_tree().create_timer(1.0).timeout
	
	get_tree().root.get_node("/root/MainMenu").show()
	
	get_window().size = orig_size
	DisplayServer.window_set_size(orig_size)
	queue_free()

func _on_quit_pressed() -> void:
	complete_work()

func _on_pause_pressed() -> void:
	paused = not paused
	
	for node:Node in get_children():
		if node is Timer:
			node.paused = paused

func _on_add_pressed() -> void:
	show_checkin()
