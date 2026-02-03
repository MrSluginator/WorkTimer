extends PanelContainer

func _ready() -> void:
	%TermGoal.value = Data.term_goal / 60.0
	%MontlyGoal.value = Data.monthly_goal / 60.0
	%WeeklyGoal.value = Data.weekly_goal / 60.0
	%DailyGoal.value = Data.daily_goal / 60.0
	
	%PomodoroCheck.button_pressed = Data.pomodoro
	%PomodoroOptions.visible = Data.pomodoro
	%FocusDuration.value = Data.pomodoro_focus
	%BreakDuration.value = Data.pomodoro_break
	
	%IntervalCheck.button_pressed = Data.intervals
	%IntervalDuration.value = Data.interval_duration


func _on_term_goal_value_changed(value: float) -> void:
	Data.term_goal = int(value * 60)


func _on_montly_goal_value_changed(value: float) -> void:
	Data.monthly_goal = int(value * 60)


func _on_weekly_goal_value_changed(value: float) -> void:
	Data.weekly_goal = int(value * 60)


func _on_daily_goal_value_changed(value: float) -> void:
	Data.daily_goal = int(value * 60)


func _on_interval_check_toggled(toggled_on: bool) -> void:
	Data.intervals = toggled_on


func _on_pomodoro_check_toggled(toggled_on: bool) -> void:
	Data.pomodoro = toggled_on
	%PomodoroOptions.visible = toggled_on

func _on_interval_duration_value_changed(value: float) -> void:
	Data.interval_duration = int(value)


func _on_focus_duration_value_changed(value: float) -> void:
	Data.pomodoro_focus = int(value)


func _on_break_duration_value_changed(value: float) -> void:
	Data.pomodoro_break = int(value)

func _on_session_interval_value_changed(value: float) -> void:
	Data.long_session_interval = int(value)


func _on_save_pressed() -> void:
	queue_free()

var invoice_menu_scene:PackedScene = load("res://scenes/invoice_menu.tscn")

func _on_create_invoice_pressed() -> void:
	var invoice_menu:Node = invoice_menu_scene.instantiate()
	add_child(invoice_menu)
