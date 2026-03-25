class_name Ball
extends RigidBody3D

signal HitFloor()
signal BallDestroyed()

var _alreadyHit: bool = false
var _upperEntered: bool = false
var _lowerEntered: bool = false
var isBasket: bool :
    get: return (_upperEntered and _lowerEntered)

func _ready() -> void:
    # 60 second lifetime of ball after released to ensure it never gets stuck
    %LifetimeTimer.timeout.connect(OnDestroyTimerTimeout)

func _on_body_entered(body: Node) -> void:
    if body.is_in_group("Floor") and not _alreadyHit:
        HitFloor.emit()
        %DestroyTimer.timeout.connect(OnDestroyTimerTimeout)
        %DestroyTimer.start()
        _alreadyHit = true

func OnDestroyTimerTimeout() -> void:
    BallDestroyed.emit()
    queue_free()