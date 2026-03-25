class_name DataLogger
extends Node

@export var _participant_id := 0
@export var _log_data := true
const SAVE_PREFIX = "res://data_logs/"

@onready var _shots: Array[Dictionary] = []
var _file: FileAccess = null

func _ready() -> void:
	var path = SAVE_PREFIX + str(_participant_id) + ".json"
	_file = FileAccess.open(path, FileAccess.WRITE)
	assert(_file != null, "Unable to open save file.")

func SaveShot(pos_id: int, pos: Vector3, attempts: Array[Dictionary]) -> void:
	_shots.append({
		"pos_id": pos_id,
		"pos_x": pos.x,
		"pos_y": pos.y,
		"pos_z": pos.z,
		"attempts": attempts
	})

func FinalizeSave() -> void:
	var out_data = {
		"participant_id": _participant_id,
		"recording_date": Time.get_date_string_from_system(),
		"shots": _shots
	}
	var json_str = JSON.stringify(out_data, "    ")

	if _file == null or not _file.store_line(json_str):
		push_warning("Unable to write to file. Printing to console for manual save.")
		print(json_str)
	else:
		print("Saved participant data.")
	
	if _file:
		_file.close()

	
