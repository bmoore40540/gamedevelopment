extends RigidBody3D
class_name GrabInteractable

signal grabbed(grabber: Node3D)
signal released(grabber: Node3D)

@export var freeze_while_grabbed: bool = true
@export var maintain_grab_offset: bool = true

var _is_grabbed: bool = false
var _grabber: Node3D = null
var _grabber_to_body: Transform3D = Transform3D.IDENTITY

func _ready() -> void:
	add_to_group(&"grab_interactables")

func is_grabbed() -> bool:
	return _is_grabbed

func grab(grabber: Node3D) -> void:
	if _is_grabbed:
		return

	_is_grabbed = true
	_grabber = grabber

	if maintain_grab_offset:
		_grabber_to_body = _grabber.global_transform.affine_inverse() * global_transform
	else:
		_grabber_to_body = Transform3D.IDENTITY

	if freeze_while_grabbed:
		freeze = true
		freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC

	grabbed.emit(grabber)

func release() -> void:
	if not _is_grabbed:
		return

	var previous_grabber := _grabber
	_is_grabbed = false
	_grabber = null

	if freeze_while_grabbed:
		freeze = false

	if previous_grabber != null:
		released.emit(previous_grabber)

func _physics_process(_delta: float) -> void:
	if not _is_grabbed:
		return
	if _grabber == null or not is_instance_valid(_grabber):
		_force_release()
		return

	global_transform = _grabber.global_transform * _grabber_to_body

func _force_release() -> void:
	var previous_grabber := _grabber
	_is_grabbed = false
	_grabber = null

	if freeze_while_grabbed:
		freeze = false

	if previous_grabber != null:
		released.emit(previous_grabber)
