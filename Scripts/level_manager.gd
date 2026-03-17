class_name LevelManager
extends Node

@export var _seed: int = 42
@export var _lowerBoundaryMark: Marker3D
@export var _upperBoundaryMark: Marker3D

var _rng: RandomNumberGenerator

func _ready() -> void:
    _rng = RandomNumberGenerator.new()
    _rng.seed = _seed
    _rng.state = 0

func GenerateShotPosition() -> Vector3:
    var x = _rng.randf_range(_lowerBoundaryMark.position.x, _upperBoundaryMark.position.x)
    var z = _rng.randf_range(_lowerBoundaryMark.position.z, _upperBoundaryMark.position.z)
    return Vector3(x, 0, z)
