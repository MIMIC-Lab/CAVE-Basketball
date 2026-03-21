class_name LevelManager
extends Node

enum PlayerType {
	Controller, Wand, Gesture
}

@export_group("Game Settings")
@export var _shotsPerPosition: int = 3
@export var _numPositions: int = 4

@export_group("Player Types")
@export var _activePlayerType: PlayerType
@export var _controllerPlayer: PackedScene

@export_group("RNG Settings")
@export var _seed: int = 42
@export var _lowerBoundaryMark: Marker3D
@export var _upperBoundaryMark: Marker3D
@export var _hoop: Marker3D

var _rng: RandomNumberGenerator
var _currentPlayer: Player
var _completedShots: int = 0
var _completedPositions: int = 0

func _ready() -> void:
	_rng = RandomNumberGenerator.new()
	_rng.seed = _seed
	_rng.state = 0
	_instantiatePlayer.call_deferred()
	_placePlayer.call_deferred()

func _instantiatePlayer() -> void:
	if _activePlayerType == PlayerType.Controller:
		_currentPlayer = _controllerPlayer.instantiate() as Player
	get_parent().add_child(_currentPlayer)
	_currentPlayer.BallShot.connect(OnPlayerShotBall)

func _placePlayer() -> void:
	_currentPlayer.global_position = GenerateShotPosition()
	_currentPlayer.look_at(_hoop.global_position)

func GenerateShotPosition() -> Vector3:
	var x = _rng.randf_range(_lowerBoundaryMark.global_position.x, _upperBoundaryMark.global_position.x)
	var z = _rng.randf_range(_lowerBoundaryMark.global_position.z, _upperBoundaryMark.global_position.z)
	return Vector3(x, 0, z)

func OnPlayerShotBall(ball: RigidBody3D) -> void:
	_completedShots += 1

	if _completedShots >= _shotsPerPosition:
		_completedPositions += 1
		_placePlayer.call_deferred()