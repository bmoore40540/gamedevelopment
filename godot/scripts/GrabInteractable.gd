extends RigidBody3D

# Basic grab interaction for VR controllers
var grabbed := false
var grabber := null

func _process(_delta):
	if grabbed and grabber:
		global_transform.origin = grabber.global_transform.origin

func _input_event(camera, event, position, normal, shape_idx):
	if event is InputEventXRController:
		if event.is_action_pressed("grab_object"):
			grabbed = true
			grabber = event.controller
		elif event.is_action_released("grab_object"):
			grabbed = false
			grabber = null
