extends Node

signal entries_updated

var filename = OS.get_user_data_dir() + "work_entries.csv"
var settings_filename = OS.get_user_data_dir() + "settings.cfg"
var curr_id: int
var entries:Array = []

var term_goal:int = 250 * 60
var monthly_goal:int = 70 * 60
var weekly_goal:int = 20 * 60
var daily_goal:int = 4 * 60

var intervals:bool = false
var interval_duration:int = 15

var pomodoro:bool = false
var pomodoro_focus:int = 25
var pomodoro_break:int = 5

var long_session_interval:int = 60

var recent_topics:Array = []
var current_tasks:Array = []

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_entries()
		save_settings()
		get_tree().quit()  # Quit after saving

func _ready():
	read_entries()
	read_settings()
	curr_id = get_last_used_id() + 1
	entries_updated.emit()

func _on_tree_exiting() -> void:
	save_entries()
	save_settings()

# Get the last used ID from all entries
func get_last_used_id() -> int:
	var max_id = 0
	
	for entry in entries:
		if entry.size() > 0 and entry[0] != "":
			var entry_id = int(entry[0])
			if entry_id > max_id:
				max_id = entry_id
	
	return max_id

func create_entry(duration: int, tasks: Array) -> Array:
	var entry = [str(curr_id), Time.get_datetime_string_from_system(), str(duration)]
	curr_id += 1
	
	for task in tasks:
		entry.append(task)
	
	return entry

# Add a new entry
func add_entry(duration: int, tasks: Array) -> void:
	entries.append(create_entry(duration, tasks))
	entries_updated.emit()

# Remove an entry by ID
func remove_entry(id: int) -> bool:
	for entry in entries:
		if entry[0] == id:
			entries.erase(entry)
			entries_updated.emit()
			return true
	
	return false

# Get a specific entry by ID
func get_entry_by_id(id: int) -> Array:
	for entry in entries:
		if entry.size() > 0 and int(entry[0]) == id:
			return entry
	
	return []

func update_entry(id: int, duration: int, tasks: Array) -> bool:
	
	for i in range(entries.size()):
		if entries[i][0] == id:
			var entry = [id, Time.get_datetime_string_from_system(), str(duration)]
			for task in tasks:
				entry.append(task)
			entries[i] = entry
			entries_updated.emit()
	
	return true

func clear_all_entries() -> void:
	entries = []
	curr_id = 0
	entries_updated.emit()

# Read all entries
func read_entries() -> void:
	if not FileAccess.file_exists(filename):
		print("file DNE")
		return
	
	var file = FileAccess.open(filename, FileAccess.READ)
	
	while file.get_position() < file.get_length():
		var entry = file.get_csv_line()
		if entry.size() > 0 and entry[0] != "":
			entries.append(entry)
	
	print(entries)
	file.close()

func save_entries() -> void:
	var file = FileAccess.open(filename, FileAccess.WRITE)
	
	for entry in entries:
		file.store_csv_line(entry)
	
	print("saved entries")
	file.close()

func read_settings() -> void:
	var config = ConfigFile.new()

	# Load data from a file.
	var err = config.load(settings_filename)

	# If the file didn't load, ignore it.
	if err != OK:
		return

	var keys:PackedStringArray = config.get_section_keys("options")
	
	pomodoro = config.get_value("options", "pomodoro")
	pomodoro_focus = config.get_value("options", "pomodoro_focus")
	pomodoro_break = config.get_value("options", "pomodoro_break")
	intervals = config.get_value("options", "intervals")
	interval_duration = config.get_value("options", "interval_duration")
	if "long_session_interval" in keys:
		long_session_interval = config.get_value("options", "long_session_interval")

	term_goal = config.get_value("goals", "term_goal")
	monthly_goal = config.get_value("goals", "monthly_goal")
	weekly_goal = config.get_value("goals", "weekly_goal")
	daily_goal = config.get_value("goals", "daily_goal")
	print(pomodoro,  pomodoro_break, pomodoro_focus)


func save_settings() -> void:
	var config = ConfigFile.new()

	config.set_value("options", "pomodoro", pomodoro)
	config.set_value("options", "pomodoro_focus", pomodoro_focus)
	config.set_value("options", "pomodoro_break", pomodoro_break)
	config.set_value("options", "intervals", intervals)
	config.set_value("options", "interval_duration", interval_duration)
	config.set_value("options", "long_session_interval", long_session_interval)

	config.set_value("goals", "term_goal", term_goal)
	config.set_value("goals", "monthly_goal", monthly_goal)
	config.set_value("goals", "weekly_goal", weekly_goal)
	config.set_value("goals", "daily_goal", daily_goal)
	print(pomodoro,  pomodoro_break, pomodoro_focus)

	config.save(settings_filename)
