extends Node
class_name XRStartup

@export var xr_interface_name: StringName = &"OpenXR"
@export var desktop_camera_path: NodePath

func _ready() -> void:
	var xr_interface := XRServer.find_interface(xr_interface_name)
	if xr_interface == null:
		_enable_desktop_camera()
		return

	if not xr_interface.is_initialized():
		if not xr_interface.initialize():
			_enable_desktop_camera()
			return

	get_viewport().use_xr = true

func _enable_desktop_camera() -> void:
	if desktop_camera_path.is_empty():
		return

	var camera := get_node_or_null(desktop_camera_path) as Camera3D
	if camera == null:
		return

	camera.current = true
