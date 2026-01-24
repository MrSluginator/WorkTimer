extends PanelContainer

@export var term_goal:int = 0 :
	set(goal):
		term_goal = goal
		%TermProgress.max_value = goal
@export var monthly_goal:int = 0 :
	set(goal):
		monthly_goal = goal
		%MonthlyProgress.max_value = goal
@export var weekly_goal:int = 0 :
	set(goal):
		weekly_goal = goal
		%WeeklyProgress.max_value = goal

var term_count:int = 0
var monthly_count:int = 0
var weekly_count:int = 0

const start_of_week = Time.WEEKDAY_MONDAY

func _ready() -> void:
	term_goal = Data.term_goal
	monthly_goal = Data.monthly_goal
	weekly_goal = Data.weekly_goal
	Data.entries_updated.connect(_on_entries_updated)
	_on_entries_updated()

func _on_entries_updated():
	term_count = 0
	for entry in get_term_entries():
		term_count += int(entry[2])
	%TermProgress.value = term_count
	%TermProgress.tooltip_text = str(term_count) + "/" + str(term_goal)
	
	monthly_count = 0
	for entry in get_monthly_entries():
		monthly_count += int(entry[2])
	%MonthlyProgress.value = monthly_count
	%MonthlyProgress.tooltip_text = str(monthly_count) + "/" + str(monthly_goal)
	
	weekly_count = 0
	for entry in get_weekly_entries():
		weekly_count += int(entry[2])
	%WeeklyProgress.value = weekly_count
	%WeeklyProgress.tooltip_text = str(weekly_count) + "/" + str(weekly_goal)


func get_weekly_entries() -> Array:
	var now:Dictionary = Time.get_datetime_dict_from_system()
	var time = now
	time["day"] = time["day"] - ((time["weekday"] + 7 - start_of_week) % 7)
	
	return get_entries_since(time)

func get_monthly_entries() -> Array:
	var now:Dictionary = Time.get_datetime_dict_from_system()
	var time = now
	time["day"] = 0
	
	return get_entries_since(time)

func get_term_entries() -> Array:
	var now:Dictionary = Time.get_datetime_dict_from_system()
	var time = now
	time["day"] = 0
	if now["month"] <= Time.MONTH_MARCH:
		time["month"] = Time.MONTH_JANUARY
	elif now["month"] <= Time.MONTH_JUNE:
		time["month"] = Time.MONTH_APRIL
	elif now["month"] <= Time.MONTH_SEPTEMBER:
		time["month"] = Time.MONTH_JULY
	else:
		time["month"] = Time.MONTH_OCTOBER
	
	return get_entries_since(time)

func get_entries_since(date:Dictionary) -> Array:
	var since:Array = []
	
	for entry in Data.entries:
		var time = Time.get_datetime_dict_from_datetime_string(entry[1], false)
		if time["year"] < date["year"]:
			continue
		if time["month"] < date["month"]:
			continue
		if time["day"] < date["day"]:
			continue
		since.append(entry)
	
	return since
