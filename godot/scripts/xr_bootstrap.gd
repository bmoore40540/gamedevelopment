extends Node

@export var auto_enable_xr := true

func _ready() -> void:
	if not auto_enable_xr:
		return

	var xr_interface := XRServer.find_interface("OpenXR")
	if xr_interface == null:
		push_warning("OpenXR interface not found. Enable the OpenXR plugin in Project Settings.")
		return

	if not xr_interface.is_initialized():
		if not xr_interface.initialize():
			push_warning("Failed to initialize OpenXR.")
			return

	get_viewport().use_xr = true

