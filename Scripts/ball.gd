class_name Ball
extends RigidBody3D

signal HitFloor()
signal BallDestroyed()

func _on_body_entered(body: Node) -> void:
    print(body)
    if body.is_in_group("Floor"):
        HitFloor.emit()
        %DestroyTimer.timeout.connect(OnDestroyTimerTimeout)
        %DestroyTimer.start()

func OnDestroyTimerTimeout() -> void:
    BallDestroyed.emit()
    queue_free()