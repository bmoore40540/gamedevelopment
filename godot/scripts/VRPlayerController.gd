extends XROrigin3D

@export var move_speed_mps: float = 3.0
@export var move_deadzone: float = 0.2

@export var snap_turn_degrees: float = 45.0
@export var snap_turn_threshold: float = 0.7
@export var snap_turn_release_threshold: float = 0.3

@export var left_controller_path: NodePath
@export var right_controller_path: NodePath
@export var xr_camera_path: NodePath

var _openxr: XRInterface
var _left_controller: XRController3D
var _right_controller: XRController3D
var _xr_camera: XRCamera3D

var _snap_turn_axis_engaged: bool = false

func _ready() -> void:
	_ensure_openxr_initialized()
	_cache_nodes()

func _physics_process(delta: float) -> void:
	_cache_nodes_if_missing()
	_apply_thumbstick_locomotion(delta)
	_apply_snap_turn()

func _ensure_openxr_initialized() -> void:
	var openxr: XRInterface = XRServer.find_interface("OpenXR") as XRInterface
	if openxr == null:
		return

	_openxr = openxr
	if not _openxr.is_initialized():
		var ok: bool = _openxr.initialize()
		if not ok:
			return

	XRServer.primary_interface = _openxr
	get_viewport().use_xr = true

func _cache_nodes() -> void:
	_left_controller = _get_controller_from_path_or_children(left_controller_path, &"left")
	_right_controller = _get_controller_from_path_or_children(right_controller_path, &"right")
	_xr_camera = _get_camera_from_path_or_children(xr_camera_path)

func _cache_nodes_if_missing() -> void:
	if _left_controller == null or _right_controller == null or _xr_camera == null:
		_cache_nodes()

func _get_controller_from_path_or_children(path: NodePath, hand: StringName) -> XRController3D:
	var from_path: XRController3D = get_node_or_null(path) as XRController3D
	if from_path != null:
		return from_path

	for child: Node in get_children():
		var controller: XRController3D = child as XRController3D
		if controller != null and controller.hand == hand:
			return controller

	return null

func _get_camera_from_path_or_children(path: NodePath) -> XRCamera3D:
	var from_path: XRCamera3D = get_node_or_null(path) as XRCamera3D
	if from_path != null:
		return from_path

	for child: Node in get_children():
		var camera: XRCamera3D = child as XRCamera3D
		if camera != null:
			return camera

	return null

func _apply_thumbstick_locomotion(delta: float) -> void:
	if _left_controller == null or _xr_camera == null:
		return

	var raw: Vector2 = _left_controller.get_vector2("primary")
	var input: Vector2 = Vector2(raw.x, -raw.y)
	var input_len: float = input.length()
	if input_len < move_deadzone:
		return

	var normalized: Vector2 = input / input_len
	var strength: float = clampf((input_len - move_deadzone) / (1.0 - move_deadzone), 0.0, 1.0)
	var scaled: Vector2 = normalized * strength

	var camera_basis: Basis = _xr_camera.global_transform.basis
	var forward: Vector3 = -camera_basis.z
	forward.y = 0.0
	forward = forward.normalized()

	var right: Vector3 = camera_basis.x
	right.y = 0.0
	right = right.normalized()

	var move_dir: Vector3 = (right * scaled.x) + (forward * scaled.y)
	if move_dir.length_squared() == 0.0:
		return

	global_position += move_dir * move_speed_mps * delta

func _apply_snap_turn() -> void:
	if _right_controller == null or _xr_camera == null:
		return

	var axis: float = _right_controller.get_vector2("primary").x
	var abs_axis: float = absf(axis)

	if _snap_turn_axis_engaged:
		if abs_axis <= snap_turn_release_threshold:
			_snap_turn_axis_engaged = false
		return

	if abs_axis < snap_turn_threshold:
		return

	var direction: float = signf(axis)
	if direction == 0.0:
		return

	_do_snap_turn(direction)
	_snap_turn_axis_engaged = true

func _do_snap_turn(direction: float) -> void:
	var pivot: Vector3 = _xr_camera.global_position
	var angle_rad: float = deg_to_rad(snap_turn_degrees * direction)

	var offset: Vector3 = global_position - pivot
	offset = offset.rotated(Vector3.UP, angle_rad)
	global_position = pivot + offset

	rotate_y(angle_rad)
