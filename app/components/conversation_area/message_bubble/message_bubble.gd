extends Control
class_name MessageBubble

@export_enum("user", "system") var role : String = "user"
@export var timestamp_label : Label
@export var message_container : PanelContainer
@export var message_label : RichTextLabel
@export var regenerate_btn : Button
@export var edit_btn : Button
var user_bg_color : Color = Color("#5a5a5a")
var system_bg_color : Color = Color("#323232")
var message_data : Dictionary = {}

func _ready() -> void:
	initialize()

func initialize():
	var style_box : StyleBox = message_container.get_theme_stylebox("panel").duplicate()
	if (role == "user"):
		regenerate_btn.hide()
		edit_btn.show()
		style_box.bg_color = user_bg_color
	elif (role == "system"):
		regenerate_btn.show()
		edit_btn.hide()
		style_box.bg_color = system_bg_color
	message_container.add_theme_stylebox_override("panel", style_box)

func setup_message(message : String, sender : String):
	message_data["message"] = message
	
	message_label.text = message
	
	self.role = sender
	if (sender == "user"):
		message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		timestamp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	
	# Set timestamp
	var time = Time.get_datetime_dict_from_system()
	timestamp_label.text = "%s/%s/%s %02d:%02d" %[time["year"], time["month"], time["day"], time["hour"], time["minute"]]
