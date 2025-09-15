extends Control
class_name ConversationArea

var message_bubble = preload("res://app/components/conversation_area/message_bubble/message_bubble.tscn")
@export var message_container : VBoxContainer
@export var input_edit : TextEdit
@export var send_btn : Button
@export var min_input_height : float = 40.
@export var max_input_height : float = 120.0
@export var line_height : float = 20.0
var is_editing : bool = false
var original_input_height : float
var last_line_count : int = 1
var request : HTTPRequest
signal _on_user_message_sent

func _ready() -> void:
	send_btn.pressed.connect(send_message)
	request = HTTPRequest.new()
	get_tree().current_scene.add_child(request)
	request.request_completed.connect(_on_request_completed)
	
	get_ollama_models()

func create_message(message : String, sender : String):
	var new_message = message_bubble.instantiate() as MessageBubble
	new_message.setup_message(message, sender)
	message_container.add_child(new_message)
	send_request(message)

# Send http request to backend.
func send_request(message : String):
	var headers = ["Content-Type: application/json"]
	var url = "http://127.0.0.1:8000/generate"
	var data = {"prompt": message}
	var json = JSON.stringify(data)
	request.request(url, headers, HTTPClient.METHOD_POST, json)

func _on_request_completed(result, response_code, headers, body):
	if (response_code == 200):
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		if (parse_result == OK):
			prints(parse_result)

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

##TODO Get ollama models by sending request to backend.
# Get ollama models using command line
func get_ollama_models():
	var output_array : Array = []
	var exit_code = OS.execute("cmd.exe", ["/C", "ollama list"], output_array, true)
	# Set model list if successfully get ollama's models.
	if (exit_code == 0):
		for line in output_array:
			print(typeof(line))
			print(line)
	else:
		printerr("Command failed with exit code: ", exit_code)
