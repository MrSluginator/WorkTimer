extends PanelContainer

func _ready():
	var time = Time.get_datetime_dict_from_system()
	%Month.set_month(time["month"], time["year"])
	Data.entries_updated.connect(%Month._on_entries_updated)
