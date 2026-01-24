extends PanelContainer
class_name MonthPanel

const term_bg = Color(0.396, 0.486, 0.208, 1.0)
const term_fg = Color(0.616, 0.941, 0.533, 1.0)
const month_bg = Color(0.396, 0.486, 0.208, 1.0)
const month_gl = Color(0.616, 0.941, 0.533, 1.0)
const month_fg = Color(0.921, 0.993, 0.791, 1.0)

var max_minutes:int = 0

@onready var week_scene:PackedScene = load("res://scenes/week.tscn")

var minutes:int = 0 :
	set(_minutes):
		minutes = _minutes
		if minutes <= Data.monthly_goal:
			self_modulate = lerp(month_bg, month_gl, float(minutes) / Data.monthly_goal)
		else:
			self_modulate = lerp(month_gl, month_fg, float(minutes - Data.monthly_goal) / (max_minutes - Data.monthly_goal))
		tooltip_text = str(minutes) + "/" + str(max_minutes)

var month:Time.Month = Time.MONTH_JANUARY
var month_days:Array
var year:int

func _on_entries_updated():
	minutes = 0
	for week in %Weeks.get_children():
		week._on_entries_updated()
		minutes += week.minutes

func set_month(_month:Time.Month, _year:int) -> void:
	month = _month
	year = _year
	var date = Date.new(1, month, year)
	month_days = date.get_calendar_array2d()
	
	for week_days in month_days:
		var week:WeekPanel = week_scene.instantiate()
		%Weeks.add_child(week)
		week.set_week_days(week_days, month, year)
		max_minutes += week.max_minutes
	
	_on_entries_updated()
