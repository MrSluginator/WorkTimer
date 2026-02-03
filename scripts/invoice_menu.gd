extends PanelContainer

var current:Date
var invoice:Dictionary = {}
var tasks:Array = []
var hours:float = 0

var start_date:Date
var end_date:Date

var filename = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)+"/invoice.csv"

func _on_create_invoice_pressed() -> void:
	start_date = Date.new()
	if start_date.day < 14:
		start_date.increment_month(false)
	start_date.day = 1
	end_date = Date.new(start_date.day, start_date.month, start_date.year)
	end_date.increment_month(true)
	end_date.increment_day(false)
	current = start_date
	
	var has_entries = false
	while (not has_entries):
		print("looking at entries for " + str(current.day) + " " + str(current.month))
		for entry in Data.entries:
			var time = Time.get_datetime_dict_from_datetime_string(entry[1], false)
			if time["year"] == current.year and time["month"] == current.month and time["day"] == current.day:
				has_entries = true
				break
		
		if (not has_entries):
			current.increment_day(true)
	
	%Date.text = current.join_formats([current.format_year(4), current.format_month(2), current.format_day(2)])
	%Summary.text = ""
	for entry:Array in Data.entries:
		var time = Time.get_datetime_dict_from_datetime_string(entry[1], false)
		if time["year"] == current.year and time["month"] == current.month and time["day"] == current.day:
			tasks.append(entry)
			hours += float(entry[2])/60
			
			for i in range(3, entry.size()):
				%Summary.text += entry[i] + str(" | ")
	
	%PrevDay.disabled = true
	%PickDuration.visible = false
	%MakeEntry.visible = true

func _on_done_pressed() -> void:
	save_entries()
	print("queue free")
	queue_free()

func save_entries() -> void:
	var file = FileAccess.open(filename, FileAccess.WRITE)
	if (not file):
		print("could not open file " + filename)
	
	var total_time:float = 0.0
	var extra_time:float = 0.0
	for entry in invoice.values():
		total_time += float(entry[1])
		var whole:int = int(float(entry[1]) * 4)
		extra_time += float(entry[1]) * 4 - whole
		if extra_time >= 1:
			whole += 1
			extra_time -= 1
		entry[1] = str(float(whole) / 4)
		file.store_csv_line(entry)
	
	file.store_string(str(total_time))
	print("saved invoice to" + str(filename))
	file.close()

func _on_prev_day_pressed() -> void:
	invoice[current.day] = [%Date.text, hours, %Summary.text]
	
	var has_entries = false
	while (not has_entries):
		current.increment_day(false)
		for entry in Data.entries:
			var time = Time.get_datetime_dict_from_datetime_string(entry[1], false)
			if time["year"] == current.year and time["month"] == current.month and time["day"] == current.day:
				has_entries = true
				break
			if time["year"] <= current.year and time["month"] < current.month:
				%PrevDay.disabled = true
				return
	
	hours = 0
	tasks = []
	%Summary.text = ""
	%Date.text = current.join_formats([current.format_year(4), current.format_month(2), current.format_day(2)])
	for entry in Data.entries:
		var time = Time.get_datetime_dict_from_datetime_string(entry[1], false)
		if time["year"] == current.year and time["month"] == current.month and time["day"] == current.day:
			tasks.append(entry)
			hours += float(entry[2])/60
			
			for i in range(3, entry.size()):
				%Summary.text += entry[i] + str(" | ")
	
	%NextDay.disabled = false
	if current.day == 1:
		%PrevDay.disabled = true

func _on_next_day_pressed() -> void:
	invoice[current.day] = [%Date.text, hours, %Summary.text]
	
	var has_entries = false
	while (not has_entries):
		current.increment_day(true)
		for entry in Data.entries:
			var time = Time.get_datetime_dict_from_datetime_string(entry[1], false)
			if time["year"] == current.year and time["month"] == current.month and time["day"] == current.day:
				has_entries = true
				break
			if time["year"] >= current.year and time["month"] > current.month:
				%NextDay.disabled = true
				return
	
	hours = 0
	tasks = []
	%Date.text = current.join_formats([current.format_year(4), current.format_month(2), current.format_day(2)])
	%Summary.text = ""
	for entry in Data.entries:
		var time = Time.get_datetime_dict_from_datetime_string(entry[1], false)
		if time["year"] == current.year and time["month"] == current.month and time["day"] == current.day:
			tasks.append(entry)
			hours += float(entry[2])/60
			
			for i in range(3, entry.size()):
				%Summary.text += entry[i] + str(" | ")
	
	%PrevDay.disabled = false
	if current.day == current.get_days_in_month():
		%NextDay.disabled = true
