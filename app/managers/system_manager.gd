extends Node

@export var url : String = "http://127.0.0.1:8000"
@export var backend_path : String = ""

##TODO First load config file and start backend service.
func _ready() -> void:
	
	start_backend_service()

## Start backend service.
func start_backend_service():
	OS.execute(backend_path,[])
