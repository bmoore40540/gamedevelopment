extends XROrigin3D

class_name VRPlayerController

enum TurnMode { NONE, SNAP, SMOOTH }

@export var character_body_path: NodePath
@export var xr_camera_path: NodePath

@export_group("Movement")
@export var move_speed_m_s: float = 2.0
@export var move_deadzone: float = 0.2
@export var move_left_action: StringName = &"xr_move_left"
@export var move_right_action: StringName = &"xr_move_right"
@export var move_forward_action: StringName = &"xr_move_forward"
@export var move_back_action: StringName = &"xr_move_back"

@export_group("Turning")
@export var turn_mode: TurnMode = TurnMode.SNAP
@export var snap_turn_degrees: float = 45.0
@export var snap_turn_deadzone: float = 0.7
@export var snap_turn_cooldown_s: float = 0.25
@export var smooth_turn_speed_deg_s: float = 90.0
@export var turn_left_action: StringName = &"xr_turn_left"
@export var turn_right_action: StringName = &"xr_turn_right"

@export_group("System")
@export var recenter_action: StringName = &"xr_recenter"

var _snap_turn_cooldown_remaining_s: float = 0.0

@onready var _character_body: CharacterBody3D = get_node_or_null(character_body_path) as CharacterBody3D
@onready var _xr_camera: XRCamera3D = _resolve_xr_camera()

func _ready() -> void:
	_xr_camera = _resolve_xr_camera()
	_character_body = get_node_or_null(character_body_path) as CharacterBody3D

func _physics_process(delta: float) -> void:
	if _xr_camera == null:
		_xr_camera = _resolve_xr_camera()
		if _xr_camera == null:
			return

	if _snap_turn_cooldown_remaining_s > 0.0:
		_snap_turn_cooldown_remaining_s = maxf(0.0, _snap_turn_cooldown_remaining_s - delta)

	if _action_just_pressed(recenter_action):
		_recenter()

	_apply_turning(delta)
	_apply_movement(delta)

func _resolve_xr_camera() -> XRCamera3D:
	if not character_body_path.is_empty():
		_character_body = get_node_or_null(character_body_path) as CharacterBody3D

	if not xr_camera_path.is_empty():
		return get_node_or_null(xr_camera_path) as XRCamera3D

	for node in get_children():
		if node is XRCamera3D:
			return node

	var found := find_children("*", "XRCamera3D", true, false)
	if not found.is_empty():
		return found[0] as XRCamera3D

	return null

func _apply_movement(delta: float) -> void:
	var move_input := _get_move_vector()
	if move_input.length() < move_deadzone:
		if _character_body != null:
			_character_body.velocity.x = 0.0
			_character_body.velocity.z = 0.0
			_character_body.move_and_slide()
		return

	var desired_dir := _get_world_space_move_dir(move_input)
	var desired_velocity := desired_dir * move_speed_m_s

	if _character_body != null:
		_character_body.velocity.x = desired_velocity.x
		_character_body.velocity.z = desired_velocity.z
		_character_body.move_and_slide()
	else:
		global_position += desired_velocity * delta

func _apply_turning(delta: float) -> void:
	if turn_mode == TurnMode.NONE:
		return

	var turn_axis := _get_turn_axis()

	if turn_mode == TurnMode.SMOOTH:
		if absf(turn_axis) <= 0.001:
			return
		var radians := deg_to_rad(smooth_turn_speed_deg_s) * turn_axis * delta
		_apply_yaw_rotation(radians)
		return

	if turn_mode == TurnMode.SNAP:
		if _snap_turn_cooldown_remaining_s > 0.0:
			return

		if absf(turn_axis) < snap_turn_deadzone:
			return

		var dir := signf(turn_axis)
		_apply_yaw_rotation(dir * deg_to_rad(snap_turn_degrees))
		_snap_turn_cooldown_remaining_s = snap_turn_cooldown_s

func _apply_yaw_rotation(radians: float) -> void:
	if absf(radians) <= 0.00001:
		return

	var prev_cam_pos := _xr_camera.global_position
	rotate_y(radians)
	var new_cam_pos := _xr_camera.global_position
	global_position += prev_cam_pos - new_cam_pos

func _get_world_space_move_dir(move_input: Vector2) -> Vector3:
	var forward := -_xr_camera.global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()

	var right := _xr_camera.global_transform.basis.x
	right.y = 0.0
	right = right.normalized()

	var desired := (right * move_input.x) + (forward * move_input.y)
	if desired.length() <= 0.00001:
		return Vector3.ZERO
	return desired.normalized()

func _get_move_vector() -> Vector2:
	if _has_action(move_left_action) and _has_action(move_right_action) and _has_action(move_forward_action) and _has_action(move_back_action):
		return Input.get_vector(move_left_action, move_right_action, move_back_action, move_forward_action)

	if InputMap.has_action(&"ui_left") and InputMap.has_action(&"ui_right") and InputMap.has_action(&"ui_up") and InputMap.has_action(&"ui_down"):
		return Input.get_vector(&"ui_left", &"ui_right", &"ui_down", &"ui_up")

	return Vector2.ZERO

func _get_turn_axis() -> float:
	if _has_action(turn_left_action) and _has_action(turn_right_action):
		return Input.get_axis(turn_left_action, turn_right_action)
	return 0.0

func _recenter() -> void:
	XRServer.center_on_hmd(XRServer.RESET_BUT_KEEP_TILT, true)

func _has_action(action_name: StringName) -> bool:
	return not String(action_name).is_empty() and InputMap.has_action(action_name)

func _action_just_pressed(action_name: StringName) -> bool:
	return _has_action(action_name) and Input.is_action_just_pressed(action_name)
