extends Node3D

@export var reticle: Node3D
var current_target_position: Vector3 = Vector3.ZERO

func _physics_process(_delta: float) -> void:
    update_targeting_reticle()

func update_targeting_reticle() -> void:
    var camera := get_viewport().get_camera_3d()
    if camera == null or reticle == null:
        return

    var screen_center := get_viewport().get_visible_rect().size / 2.0
    var ray_origin := camera.project_ray_origin(screen_center)
    var ray_end := ray_origin + camera.project_ray_normal(screen_center) * 5000.0

    var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
    var space_state := get_world_3d().direct_space_state
    var hit := space_state.intersect_ray(query)

    if hit.is_empty():
        reticle.hide()
        return

    current_target_position = hit["position"]
    reticle.global_position = current_target_position
    reticle.show()

func get_current_target_position() -> Vector3:
    return current_target_position
