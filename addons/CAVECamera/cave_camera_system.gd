@tool
@icon("res://addons/CAVECamera/videocam_icon.svg")
extends Node3D

# Origin of coordinates is at center of front screen
@export var screen_width: float = 4.064
@export var screen_height: float = 2.286
@export var view_depth: float = 2.032
@export var view_height: float = 1.65
@export var far_plane: float = 50
@export var near_plane_divisor: float = 1.0

var front_window: Window
var left_window : Window
var right_window : Window
var frontCam : Camera3D
var leftCam: Camera3D
var rightCam: Camera3D

var viewport_size: Vector2i
var eye_position: Vector3

func _ready() -> void:
	front_window = $FrontWindow
	left_window = %LeftWindow
	right_window = %RightWindow
	frontCam = %FrontCam
	leftCam = %LeftCam
	rightCam = %RightCam
	viewport_size = get_viewport().size
	eye_position = Vector3(screen_width/2, view_height, view_depth)
	
	_init_windows()
	_update_cameras()

func _init_windows() -> void:
	left_window.size = viewport_size
	right_window.size = viewport_size
	var window_pos = get_window().position
	left_window.position = window_pos
	right_window.position = window_pos

func _update_cameras() -> void:
	### FRONT WALL ###
	var pa := Vector3(0, 0, 0)
	var pb := Vector3(screen_width, 0, 0)
	var pc := Vector3(0, screen_height, 0)
	_configure_camera(frontCam, pa, pb, pc, eye_position)
	
	### LEFT WALL ###
	pa = Vector3(0, 0, screen_width)
	pb = Vector3(0, 0, 0)
	pc = Vector3(0, screen_height, screen_width)
	_configure_camera(leftCam, pa, pb, pc, eye_position)
	
	### RIGHT WALL ###
	pa = Vector3(screen_width, 0, 0)
	pb = Vector3(screen_width, 0, screen_width)
	pc = Vector3(screen_width, screen_height, 0)
	_configure_camera(rightCam, pa, pb, pc, eye_position)

func _configure_camera(cam: Camera3D, pa: Vector3, pb: Vector3, pc: Vector3, pe: Vector3) -> void:
	var vr := (pb - pa).normalized()
	var vu := (pc - pa).normalized()
	var vn := (vr.cross(vu)).normalized()

	var va := pa - pe
	var vb := pb - pe
	var vc := pc - pe
	
	var d := -vn.dot(va)
	var n := d/near_plane_divisor # distance to near clipping plane, default to screen distance
	
	var l := vr.dot(va) * n / d
	var r := vr.dot(vb) * n / d
	var b := vu.dot(va) * n / d
	var t := vu.dot(vc) * n / d
	
	cam.projection = Camera3D.PROJECTION_FRUSTUM
	cam.size = t - b
	cam.frustum_offset = Vector2((l + r)/2.0, (t + b)/2.0)
	cam.near = n
	cam.far = far_plane
