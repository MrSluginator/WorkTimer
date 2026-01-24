extends PanelContainer

func _ready() -> void:
	for topic in Data.recent_topics:
		var button = Button.new()
		button.text = topic
		button.pressed.connect(func(): submit_task(topic))
		%RecentTopics.add_child(button)
	
	%Task.grab_focus()

func _on_topic_text_submitted(new_text: String) -> void:
	if Data.recent_topics.size() >= 5:
		Data.recent_topics.pop_back()
	Data.recent_topics.push_front(new_text)
	submit_task(new_text)

func submit_task(topic:String):
	print(Data.recent_topics)
	Data.current_tasks.append(topic + %Task.text)
	queue_free()
