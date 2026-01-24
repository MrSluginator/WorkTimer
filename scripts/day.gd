extends PanelContainer
class_name DayPanel

const day_none = Color(0.04, 0.04, 0.04, 0.7)
const day_bg = Color(0.173, 0.51, 0.745, 1.0)
const day_gl = Color(0.612, 0.784, 0.945, 1.0)
const day_fg = Color(0.776, 0.912, 0.994, 1.0)

const max_minutes:int = 24 * 60

var minutes:int = 0 :
	set(_minutes):
		minutes = _minutes
		if minutes <= Data.daily_goal:
			self_modulate = lerp(day_bg, day_gl, float(minutes) / Data.daily_goal)
		else:
			self_modulate = lerp(day_gl, day_fg, float(minutes - Data.daily_goal) / (max_minutes - Data.daily_goal))
		tooltip_text = str(minutes) + "/" + str(max_minutes)

var date:Date

func _on_entries_updated():
	if not date:
		return
	
	minutes = 0
	for entry in Data.entries:
		var time = Time.get_datetime_dict_from_datetime_string(entry[1], false)
		if time["year"] == date.year and time["month"] == date.month and time["day"] == date.day:
			minutes += int(entry[2])

func set_day(day:int, month:Time.Month, year:int):
	if day <= 0:
		self_modulate = day_none
		queue_free()
		return
	date = Date.new(day, month, year)
	
	_on_entries_updated()
