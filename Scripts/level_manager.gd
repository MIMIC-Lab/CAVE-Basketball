class_name LevelManager
extends Node

enum PlayerType {
	Controller, Wand, Gesture
}

@export_group("Player Types")
@export var _activePlayerType: PlayerType
@export var _controllerPlayer: PackedScene

@export_group("RNG Settings")
@export var _seed: int = 42
@export var _lowerBoundaryMark: Marker3D
@export var _upperBoundaryMark: Marker3D

var _rng: RandomNumberGenerator
var _currentPlayer: Node3D

func _ready() -> void:
	_rng = RandomNumberGenerator.new()
	_rng.seed = _seed
	_rng.state = 0
	_placePlayer()

func _placePlayer() -> void:
	if _activePlayerType == PlayerType.Controller:
		_currentPlayer = _controllerPlayer.instantiate()
		
	get_parent().add_child.call_deferred(_currentPlayer)
	_currentPlayer.set_deferred("global_position", GenerateShotPosition())

func GenerateShotPosition() -> Vector3:
	var x = _rng.randf_range(_lowerBoundaryMark.global_position.x, _upperBoundaryMark.global_position.x)
	var z = _rng.randf_range(_lowerBoundaryMark.global_position.z, _upperBoundaryMark.global_position.z)
	return Vector3(x, 0, z)
