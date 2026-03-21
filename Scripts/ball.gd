class_name Ball
extends RigidBody3D

signal HitFloor()
signal BallDestroyed()

var _alreadyHit: bool = false

func _on_body_entered(body: Node) -> void:
    if body.is_in_group("Floor") and not _alreadyHit:
        HitFloor.emit()
        %DestroyTimer.timeout.connect(OnDestroyTimerTimeout)
        %DestroyTimer.start()
        _alreadyHit = true

func OnDestroyTimerTimeout() -> void:
    BallDestroyed.emit()
    queue_free()