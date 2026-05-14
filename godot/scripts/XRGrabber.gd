extends XRController3D
class_name XRGrabber

@export var grab_button: StringName = &"grip_click"
@export var grab_area_path: NodePath = NodePath("GrabArea")

var _held: GrabInteractable = null

func _ready() -> void:
	button_pressed.connect(_on_button_pressed)
	button_released.connect(_on_button_released)

func _on_button_pressed(button_name: StringName) -> void:
	if button_name != grab_button:
		return
	if _held != null and is_instance_valid(_held):
		return

	var target := _find_best_interactable()
	if target == null:
		return

	_held = target
	_held.grab(self)

func _on_button_released(button_name: StringName) -> void:
	if button_name != grab_button:
		return
	if _held == null:
		return

	if is_instance_valid(_held):
		_held.release()
	_held = null

func _find_best_interactable() -> GrabInteractable:
	var grab_area := get_node_or_null(grab_area_path) as Area3D
	if grab_area == null:
		return null

	var best: GrabInteractable = null
	var best_distance_squared := INF

	for body in grab_area.get_overlapping_bodies():
		var interactable := body as GrabInteractable
		if interactable == null:
			continue
		if interactable.is_grabbed():
			continue

		var distance_squared := global_position.distance_squared_to(interactable.global_position)
		if distance_squared < best_distance_squared:
			best_distance_squared = distance_squared
			best = interactable

	return best
