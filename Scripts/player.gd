extends CharacterBody3D


@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var ACCELERATION = 2.0
@export var LOOK_SPEED = 0.03


func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity += get_gravity() * delta
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    var input_dir := Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")
    var direction := transform.basis * Vector3(input_dir.x, 0, input_dir.y)
    velocity.x = move_toward(velocity.x, direction.x * SPEED, ACCELERATION)
    velocity.z = move_toward(velocity.z, direction.z * SPEED, ACCELERATION)

    var look_inp := Input.get_axis("LookRight", "LookLeft")
    rotate_y(look_inp * LOOK_SPEED)

    move_and_slide()
