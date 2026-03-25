extends Player

@export_group("Movement")
@export var SPEED = 5.0
@export var ACCELERATION = 2.0
@export var LOOK_SPEED = 0.03

@export_group("Shot Settings")
@export var _defaultShotAngle := 45.0
@export var _shotAngleMin := -45.0
@export var _shotAngleMax := 90
@export var _shotAngleAccel := 0.75
@export var _defaultShotForce := 10.0
@export var _shotForceMin := 8.0
@export var _shotForceMax := 12.0
@export var _shotForceAccel := 0.1

@export_group("References")
@export var _ballScene: PackedScene
@export var _line3D: LinePath3D
@export var _ballVisual: MeshInstance3D

var _isShooting: bool = false
var _currentBall: RigidBody3D
@onready var _throwAngle: float = _defaultShotAngle
@onready var _throwForce: float = _defaultShotForce
var _throw_dir : Vector3
var _moveEnabled: bool = false

func _process(_delta: float) -> void:   
	if _controlEnabled: 
		if Input.is_action_just_pressed("Shoot"):
			_ballVisual.visible = true
			_isShooting = true
			_line3D.visible = true
			_throwPressedTimestamp = Time.get_unix_time_from_system()
		if Input.is_action_pressed("Shoot") and _isShooting:
			ProcessShot()
		if Input.is_action_just_released("Shoot") and _isShooting:
			_isShooting = false
			_throwReleasedTimestamp = Time.get_unix_time_from_system()
			DoShot()
		
		if Input.is_action_just_pressed("EnableMovement"):
			_moveEnabled = !_moveEnabled

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if _controlEnabled and _moveEnabled and not _isShooting:
		var input_dir := Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")
		var direction := transform.basis * Vector3(input_dir.x, 0, input_dir.y)
		velocity.x = move_toward(velocity.x, direction.x * SPEED, ACCELERATION)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, ACCELERATION)
	else:
		velocity.x = 0
		velocity.z = 0
	
	if _controlEnabled:
		var look_inp := Input.get_axis("LookRight", "LookLeft")
		rotate_y(look_inp * LOOK_SPEED)

	move_and_slide()

func SpawnBall() -> void:
	var ball = _ballScene.instantiate() as RigidBody3D
	get_parent().add_child(ball)
	ball.position = _ballVisual.global_position
	_currentBall = ball

func ProcessShot() -> void:
	# Adjust angle and power based on input
	if Input.is_action_pressed("LookDown"):
		_throwAngle = move_toward(_throwAngle, _shotAngleMin, _shotAngleAccel)
	if Input.is_action_pressed("LookUp"):
		_throwAngle = move_toward(_throwAngle, _shotAngleMax, _shotAngleAccel)
	if Input.is_action_pressed("ShotPowerDown"):
		_throwForce = move_toward(_throwForce, _shotForceMin, _shotForceAccel)
	if Input.is_action_pressed("ShotPowerUp"):
		_throwForce = move_toward(_throwForce, _shotForceMax, _shotForceAccel)

	# Calculate throw direction
	# Character forward (basis -z) rotated up or down (basis x)
	var forward_dir = -transform.basis.z
	var angle_rad = deg_to_rad(_throwAngle)
	var rotation_axis = transform.basis.x
	_throw_dir = forward_dir.rotated(rotation_axis, angle_rad).normalized()

	# Predict throw path based on direction and draw it
	var path = predict_ball_path(_ballVisual.global_position, _throw_dir*_throwForce)
	_line3D.curve.clear_points()
	for p in path:
		_line3D.curve.add_point(to_local(p))

func DoShot() -> void:
	SpawnBall()
	_currentBall.apply_central_impulse(_throw_dir * _throwForce)
	BallShot.emit(_currentBall, _currentBall.global_position, _throw_dir, _currentBall.linear_velocity, _spawnedTimestamp, _throwPressedTimestamp, _throwReleasedTimestamp)
	_ballVisual.visible = false
	_line3D.visible = false
	_throwAngle = _defaultShotAngle
	_throwForce = _defaultShotForce

func predict_ball_path(start_position: Vector3, initial_velocity: Vector3, steps: int = 50, delta_t: float = 0.02) -> PackedVector3Array:
	var GRAVITY: Vector3 = Vector3.DOWN * -get_gravity()
	var path := PackedVector3Array()
	var current_position := start_position
	var current_velocity := initial_velocity
	var time_step := delta_t

	for i in range(steps):
		current_position += current_velocity * time_step
		current_velocity += GRAVITY * time_step
		path.push_back(current_position)
	return path
