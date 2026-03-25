class_name LevelManager
extends Node

enum PlayerType {
    Controller, VR, Gesture
}

@export_group("Game Settings")
@export var _shotsPerPosition: int = 3
@export var _shotPositions: Array[Marker3D]
@export var _hoop: Marker3D
@export var _dataLogger: DataLogger

@export_group("Animation")
@export var _letterboxAnim: AnimationPlayer
@export var _fadeRect: ColorRect

@export_group("Player Types")
@export var _activePlayerType: PlayerType
@export var _controllerPlayer: PackedScene
@export var _vrPlayer: PackedScene

var _currentPlayer: Player
var _currentBall: Ball
var _completedShots: int = 0
var _completedPositions: int = 0
var current_attempts: Array[Dictionary]

func _ready() -> void:
    _instantiatePlayer.call_deferred()
    _placePlayer.call_deferred()
    current_attempts = []

func _instantiatePlayer() -> void:
    if _activePlayerType == PlayerType.Controller:
        _currentPlayer = _controllerPlayer.instantiate() as Player
    if _activePlayerType == PlayerType.VR:
        _currentPlayer = _vrPlayer.instantiate() as Player

    get_parent().add_child(_currentPlayer)
    _currentPlayer.BallShot.connect(OnPlayerShotBall)

func _placePlayer() -> void:
    _currentPlayer.global_position = GetShotPosition()
    _currentPlayer.look_at(_hoop.global_position)

func GetShotPosition() -> Vector3:
    return _shotPositions[_completedPositions].global_position

func OnPlayerShotBall(ball: Ball, position: Vector3, rotation: Vector3, velocity: Vector3, spawnedTimestamp: float, throwPressedTimestamp: float, throwReleasedTimestamp: float) -> void:
    _completedShots += 1
    _currentPlayer.DisableControl()
    _letterboxAnim.play("LetterboxOn")
    _currentBall = ball
    ball.BallDestroyed.connect(OnBallDestroy)
    var attempt = {
        "spawned_time": spawnedTimestamp,
        "pressed_time": throwPressedTimestamp,
        "release_time": throwReleasedTimestamp,
        "pos_x": position.x,
        "pos_y": position.y,
        "pos_z": position.z,
        "rot_x": rotation.x,
        "rot_y": rotation.y,
        "rot_z": rotation.z,
        "vel_x": velocity.x,
        "vel_y": velocity.y,
        "vel_z": velocity.z,
        "basket": false
    }
    current_attempts.append(attempt)

func OnBallDestroy() -> void:
    _currentBall = null
    if _completedShots >= _shotsPerPosition:
        var tween = create_tween().tween_property(_fadeRect, "modulate", Color.BLACK, 1)
        tween.finished.connect(OnFadeToBlackComplete)
        IncrementShotPosition()
    else:
        _letterboxAnim.play("LetterboxOff")
        _currentPlayer.EnableControl()

func OnFadeToBlackComplete() -> void:
    if _completedPositions < _shotPositions.size():
        _placePlayer()
        var tween = create_tween().tween_property(_fadeRect, "modulate", Color(0,0,0,0), 1)
        tween.finished.connect(OnFadeFromBlackComplete)
    else:
        _dataLogger.FinalizeSave()

func OnFadeFromBlackComplete() -> void:
    _letterboxAnim.play("LetterboxOff")
    _currentPlayer.EnableControl()

func IncrementShotPosition() -> void:
    _dataLogger.SaveShot(_completedPositions, GetShotPosition(), current_attempts)
    _completedShots = 0
    _completedPositions += 1
    current_attempts = []

func _OnHoopUpperAreaBodyEntered(body: Node3D) -> void:
    if _currentBall and _currentBall == body:
        _currentBall._upperEntered = true
        current_attempts[-1]["basket"] = _currentBall.isBasket
func _OnHoopLowerAreaBodyEntered(body: Node3D) -> void:
    if _currentBall and _currentBall == body:
        _currentBall._lowerEntered = true
        current_attempts[-1]["basket"] = _currentBall.isBasket
