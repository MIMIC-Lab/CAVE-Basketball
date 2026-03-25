extends XRController3D

@export var velocity_samples: int = 5
@export var _ballScene: PackedScene

var _velocity_averager := XRToolsVelocityAverager.new(velocity_samples)
var _ballInstance: RigidBody3D = null

func _ready() -> void:
    button_pressed.connect(_onButtonPressed)
    button_released.connect(_onButtonReleased)

func _process(delta: float) -> void:
    if _ballInstance:
        _ballInstance.global_position = global_position
        _ballInstance.global_rotation = global_rotation

    _velocity_averager.add_transform(delta, global_transform)


func _onButtonPressed(button_name) -> void:
    print(button_name)
    if button_name == "trigger_click":
        SpawnBall()

func _onButtonReleased(button_name) -> void:
    print(button_name)
    if button_name == "trigger_click":
        ReleaseBall()

func SpawnBall() -> void:
    print("Spawn")
    _ballInstance = _ballScene.instantiate() as RigidBody3D
    add_child(_ballInstance)
    _ballInstance.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
    _ballInstance.freeze = true

func ReleaseBall() -> void:
    if _ballInstance:
        _ballInstance.freeze = false
        remove_child(_ballInstance)
        get_parent().get_parent().add_child(_ballInstance)
        _ballInstance.global_position = global_position
        _ballInstance.rotation = rotation
        _ballInstance.linear_velocity = _velocity_averager.linear_velocity()
        _ballInstance.angular_velocity = _velocity_averager.angular_velocity()
        _ballInstance = null