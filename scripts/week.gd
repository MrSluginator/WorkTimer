extends PanelContainer
class_name WeekPanel

const week_bg = Color(0.123, 0.232, 0.201, 1.0)
const week_gl = Color(0.238, 0.645, 0.529, 1.0)
const week_fg = Color(0.191, 0.852, 0.634, 1.0)

var max_minutes:int = 0

@onready var day_scene:PackedScene = load("res://scenes/day.tscn")

var minutes:int = 0 :
	set(_minutes):
		minutes = _minutes
		if minutes <= Data.weekly_goal:
			self_modulate = lerp(week_bg, week_gl, float(minutes) / Data.weekly_goal)
		else:
			self_modulate = lerp(week_gl, week_fg, float(minutes - Data.weekly_goal) / (max_minutes - Data.weekly_goal))
		tooltip_text = str(minutes) + "/" + str(max_minutes)

func _on_entries_updated():
	minutes = 0
	for day in %Days.get_children():
		day._on_entries_updated()
		minutes += day.minutes

func set_week_days(week_days:Array, month:Time.Month, year:int) -> void:
	for day:String in week_days:
		if not int(day) > 0:
			continue
		var day_panel:DayPanel = day_scene.instantiate()
		%Days.add_child(day_panel)
		day_panel.set_day(int(day), month, year)
		max_minutes += day_panel.max_minutes
	
	if %Days.get_children().is_empty():
		queue_free()
	
	_on_entries_updated()
