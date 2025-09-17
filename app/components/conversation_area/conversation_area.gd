extends Control
class_name ConversationArea

var message_bubble = preload("res://app/components/conversation_area/message_bubble/message_bubble.tscn")
@export var message_container : VBoxContainer
@export var input_edit : TextEdit
@export var send_btn : Button
@export var min_input_height : float = 40.
@export var max_input_height : float = 120.0
@export var line_height : float = 20.0
@export var url : String = "http://127.0.0.1:8000"
@export var model_btn : OptionButton
var is_editing : bool = false
var original_input_height : float
var last_line_count : int = 1

signal _on_user_message_sent

func _ready() -> void:
	send_btn.pressed.connect(send_message)

func create_message(message : String, sender : String):
	var new_message = message_bubble.instantiate() as MessageBubble
	new_message.setup_message(message, sender)
	message_container.add_child(new_message)
	send_request(message)

@export var generate_request : HTTPRequest
## Send chat request to backend.
func send_request(message : String):
	var headers = ["Content-Type: application/json"]
	var data = {
		"prompt": message,
		"model": model_btn.get_item_text(model_btn.selected)
		}
	var json = JSON.stringify(data)
	generate_request.request("%s/generate" %url, headers, HTTPClient.METHOD_POST, json)
## Create message when successfully recieved response.
func _on_generate_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if (response_code == 200):
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		if (parse_result == OK):
			create_message(parse_result["response"], "system")

func send_message() -> void:
	create_message(input_edit.text, "user")
	input_edit.clear()
	_on_user_message_sent.emit()

func _on_input_container_focus_entered() -> void:
	is_editing = true

func _on_input_container_focus_exited() -> void:
	is_editing = false


func _on_input_edit_gui_input(event: InputEvent) -> void:
	if not is_editing:
		return

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER and not event.shift_pressed:
			input_edit.accept_event()
			send_message()

func _on_input_edit_focus_entered() -> void:
	is_editing = true


func _on_input_edit_focus_exited() -> void:
	is_editing = false

@export var model_request : HTTPRequest
## Get local ollama models by sending request to backend.
func get_ollama_models():
	model_request.request("%s/models", [],HTTPClient.METHOD_GET)

## Add items to model_btn.
func _on_model_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if (response_code == 200):
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		if (parse_result == OK):
			var models = parse_result["models"]
			for model in models:
				model_btn.add_item("model")
		else:
			printerr("Can't parse data.")
	else:
		printerr("Can't get ollama models due to %d" %response_code)
