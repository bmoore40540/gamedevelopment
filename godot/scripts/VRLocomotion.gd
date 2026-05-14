extends XROrigin3D

enum MovementReference {
	HEAD,
	ORIGIN,
}

@export var left_controller_path: NodePath
@export var right_controller_path: NodePath
@export var xr_camera_path: NodePath

@export var movement_reference: MovementReference = MovementReference.HEAD
@export var move_speed_mps: float = 2.0
@export var strafe_multiplier: float = 1.0
@export var acceleration_mps2: float = 12.0
@export var input_deadzone: float = 0.2

@export var snap_turn_degrees: float = 30.0
@export var snap_turn_threshold: float = 0.75
@export var snap_turn_release_threshold: float = 0.35
@export var invert_snap_turn: bool = false

@export var left_stick_x_axis: int = JOY_AXIS_LEFT_X
@export var left_stick_y_axis: int = JOY_AXIS_LEFT_Y
@export var right_stick_x_axis: int = JOY_AXIS_LEFT_X

var _planar_velocity: Vector3 = Vector3.ZERO
var _snap_turn_armed: bool = true

@onready var _left_controller: XRController3D = get_node_or_null(left_controller_path) as XRController3D
@onready var _right_controller: XRController3D = get_node_or_null(right_controller_path) as XRController3D
@onready var _xr_camera: XRCamera3D = get_node_or_null(xr_camera_path) as XRCamera3D

func _physics_process(delta: float) -> void:
	_update_smooth_locomotion(delta)
	_update_snap_turn()

func _update_smooth_locomotion(delta: float) -> void:
	if _left_controller == null:
		return

	var joystick_id: int = _left_controller.get_joystick_id()
	if joystick_id < 0:
		return

	var raw_x: float = Input.get_joy_axis(joystick_id, left_stick_x_axis)
	var raw_y: float = -Input.get_joy_axis(joystick_id, left_stick_y_axis)

	var input_vec: Vector2 = Vector2(raw_x, raw_y)
	if input_vec.length() < input_deadzone:
		input_vec = Vector2.ZERO
	else:
		input_vec = input_vec.normalized() * remap(input_vec.length(), input_deadzone, 1.0, 0.0, 1.0)

	var reference_basis: Basis = global_transform.basis
	if movement_reference == MovementReference.HEAD and _xr_camera != null:
		reference_basis = _xr_camera.global_transform.basis

	var forward: Vector3 = -reference_basis.z
	forward.y = 0.0
	forward = forward.normalized()

	var right: Vector3 = reference_basis.x
	right.y = 0.0
	right = right.normalized()

	var desired_dir: Vector3 = (right * (input_vec.x * strafe_multiplier) + forward * input_vec.y)
	if desired_dir.length_squared() > 1e-6:
		desired_dir = desired_dir.normalized()

	var target_velocity: Vector3 = desired_dir * move_speed_mps
	_planar_velocity = _planar_velocity.move_toward(target_velocity, acceleration_mps2 * delta)
	global_position += _planar_velocity * delta

func _update_snap_turn() -> void:
	if _right_controller == null:
		return

	var joystick_id: int = _right_controller.get_joystick_id()
	if joystick_id < 0:
		return

	var axis_x: float = Input.get_joy_axis(joystick_id, right_stick_x_axis)
	var abs_x: float = absf(axis_x)

	if _snap_turn_armed and abs_x >= snap_turn_threshold:
		var sign_x: float = signf(axis_x)
		var yaw_degrees: float = -sign_x * snap_turn_degrees
		if invert_snap_turn:
			yaw_degrees = -yaw_degrees
		_apply_yaw_around_head(deg_to_rad(yaw_degrees))
		_snap_turn_armed = false
	elif not _snap_turn_armed and abs_x <= snap_turn_release_threshold:
		_snap_turn_armed = true

func _apply_yaw_around_head(yaw_radians: float) -> void:
	if _xr_camera == null:
		rotate_y(yaw_radians)
		return

	var before: Vector3 = _xr_camera.global_position
	rotate_y(yaw_radians)
	var after: Vector3 = _xr_camera.global_position
	global_position += before - after
