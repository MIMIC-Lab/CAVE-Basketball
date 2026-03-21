class_name LevelManager
extends Node

enum PlayerType {
    Controller, Wand, Gesture
}

@export_group("Game Settings")
@export var _shotsPerPosition: int = 3
@export var _shotPositions: Array[Marker3D]
@export var _hoop: Marker3D

@export_group("Animation")
@export var _letterboxAnim: AnimationPlayer
@export var _fadeRect: ColorRect

@export_group("Player Types")
@export var _activePlayerType: PlayerType
@export var _controllerPlayer: PackedScene

var _currentPlayer: Player
var _completedShots: int = 0
var _completedPositions: int = 0

func _ready() -> void:
    _instantiatePlayer.call_deferred()
    _placePlayer.call_deferred()

func _instantiatePlayer() -> void:
    if _activePlayerType == PlayerType.Controller:
        _currentPlayer = _controllerPlayer.instantiate() as Player
    get_parent().add_child(_currentPlayer)
    _currentPlayer.BallShot.connect(OnPlayerShotBall)

func _placePlayer() -> void:
    _currentPlayer.global_position = NextShotPosition()
    _currentPlayer.look_at(_hoop.global_position)

func NextShotPosition() -> Vector3:
    return _shotPositions[_completedPositions].global_position

func OnPlayerShotBall(ball: Ball) -> void:
    _completedShots += 1
    _currentPlayer._controlEnabled = false
    _letterboxAnim.play("LetterboxOn")
    ball.BallDestroyed.connect(OnBallDestroy)

func OnBallDestroy() -> void:
    if _completedShots >= _shotsPerPosition:
        _completedPositions += 1
        var tween = create_tween().tween_property(_fadeRect, "modulate", Color.BLACK, 1)
        tween.finished.connect(OnFadeToBlackComplete)
        _completedShots = 0
    else:
        _letterboxAnim.play("LetterboxOff")
        _currentPlayer._controlEnabled = true

func OnFadeToBlackComplete() -> void:
    if _completedPositions < _shotPositions.size():
        _placePlayer()
        var tween = create_tween().tween_property(_fadeRect, "modulate", Color(0,0,0,0), 1)
        tween.finished.connect(OnFadeFromBlackComplete)

func OnFadeFromBlackComplete() -> void:
    _letterboxAnim.play("LetterboxOff")
    _currentPlayer._controlEnabled = true
