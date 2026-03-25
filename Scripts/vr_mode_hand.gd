extends XRController3D

@export var impulse_factor : float = 1.0
@export var velocity_samples: int = 5
@export var _ballScene: PackedScene

var parent: Player
var _velocity_averager := XRToolsVelocityAverager.new(velocity_samples)
var _ballInstance: RigidBody3D = null

func _ready() -> void:
	button_pressed.connect(_onButtonPressed)
	button_released.connect(_onButtonReleased)
	parent = get_parent().get_parent()

func _process(delta: float) -> void:
	if _ballInstance:
		_ballInstance.global_position = global_position
		_ballInstance.global_rotation = global_rotation

	_velocity_averager.add_transform(delta, global_transform)

func _onButtonPressed(button_name) -> void:
	if button_name == "trigger_click" and parent._controlEnabled:
		SpawnBall()

func _onButtonReleased(button_name) -> void:
	if button_name == "trigger_click" and parent._controlEnabled:
		ReleaseBall()

func SpawnBall() -> void:
	parent._throwPressedTimestamp = Time.get_unix_time_from_system()
	_ballInstance = _ballScene.instantiate() as RigidBody3D
	add_child(_ballInstance)
	_ballInstance.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	_ballInstance.freeze = true

func ReleaseBall() -> void:
	if _ballInstance:
		parent._throwReleasedTimestamp = Time.get_unix_time_from_system()
		_ballInstance.freeze = false
		remove_child(_ballInstance)
		parent.get_parent().add_child(_ballInstance)
		_ballInstance.global_position = global_position
		_ballInstance.rotation = rotation
		print(_velocity_averager.linear_velocity())
		_ballInstance.linear_velocity = _velocity_averager.linear_velocity() * impulse_factor
		_ballInstance.angular_velocity = _velocity_averager.angular_velocity() * impulse_factor
		parent.BallShot.emit(_ballInstance, _ballInstance.global_position, _ballInstance.global_rotation, _ballInstance.linear_velocity, parent._spawnedTimestamp, parent._throwPressedTimestamp, parent._throwReleasedTimestamp)
		_ballInstance = null
