class_name Player
extends CharacterBody3D

signal BallShot(ball: Ball, position: Vector3, rotation: Vector3, velocity: Vector3, spawnedTimestamp: float, throwPressedTimestamp: float, throwReleasedTimestamp: float)

var _controlEnabled: bool = true
var _throwPressedTimestamp = 0
var _throwReleasedTimestamp = 0
var _spawnedTimestamp = 0


func EnableControl() -> void:
    _controlEnabled = true
    _spawnedTimestamp = Time.get_unix_time_from_system()

func DisableControl() -> void:
    _controlEnabled = false