extends Control
class_name SystemPromptEditor

@export var prompt_edit : TextEdit
@export var update_btn : Button
@export var update_system_prompt_request : HTTPRequest
@export var get_system_prompt_request : HTTPRequest
@export var system_prompt : String = ""

func _ready() -> void:
	get_system_prompt()

func get_system_prompt():
	get_system_prompt_request.request("%s/get-system-prompt" %SystemManager.url)

func _on_get_system_prompt_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if (response_code == 200):
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		if (parse_result == OK):
			prompt_edit.text = parse_result["system_prompt"]
			system_prompt = parse_result["system_prompt"]
		else:
			printerr("Can't parse data.")
	else:
		printerr("Can't get system prompt due to %d" %response_code)
		

func _on_update_btn_pressed() -> void:
	var headers = ["Content-Type: application/json"]
	var data = {
		"system_prompt": prompt_edit.text
		}
	var json = JSON.stringify(data)
	update_system_prompt_request.request("%s/update-system-prompt" %SystemManager.url, headers, HTTPClient.METHOD_PUT, json)
	update_btn.disabled = true

func _on_prompt_edit_text_changed() -> void:
	if (prompt_edit.text == system_prompt):
		update_btn.disabled = true
	else:
		system_prompt = prompt_edit.text
		update_btn.disabled = false
