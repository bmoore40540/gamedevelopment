extends CharacterBody3D

@export var kill_radius: float = 150.0
@export var wind_force: float = 50.0
@export var tsunami_scene: PackedScene
@export var earthquake_scene: PackedScene
@export var targeting_reticle_path: NodePath

@onready var targeting: Node3D = get_node_or_null(targeting_reticle_path)

func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("smite_enemies"):
        trigger_mass_slaughter()

    if Input.is_action_just_pressed("disintegrate_building"):
        destroy_targeted_building()

    if Input.is_action_just_pressed("spawn_tsunami"):
        spawn_tsunami()

    if Input.is_action_just_pressed("spawn_earthquake"):
        spawn_earthquake()

func trigger_mass_slaughter() -> void:
    var armies := get_tree().get_nodes_in_group("enemies")
    for enemy in armies:
        if enemy is Node3D and global_position.distance_to(enemy.global_position) <= kill_radius:
            if enemy.has_method("die_by_divine_fire"):
                enemy.die_by_divine_fire()

func destroy_targeted_building() -> void:
    var camera := get_viewport().get_camera_3d()
    if camera == null:
        return

    var mouse_pos := get_viewport().get_mouse_position()
    var ray_origin := camera.project_ray_origin(mouse_pos)
    var ray_end := ray_origin + camera.project_ray_normal(mouse_pos) * 2000.0

    var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
    var space_state := get_world_3d().direct_space_state
    var intersection := space_state.intersect_ray(query)

    if intersection.is_empty():
        return

    var target := intersection["collider"]
    if target is Node and target.is_in_group("buildings") and target.has_method("crumble_to_dust"):
        target.crumble_to_dust(ray_origin)

func spawn_tsunami() -> void:
    if tsunami_scene == null:
        return
    if targeting == null or not targeting.has_method("get_current_target_position"):
        return

    var wave := tsunami_scene.instantiate()
    get_parent().add_child(wave)
    if wave is Node3D:
        wave.global_position = global_position

    var target_position: Vector3 = targeting.get_current_target_position()
    var direction := (target_position - global_position).normalized()
    direction.y = 0.0

    _set_property_if_exists(wave, "move_direction", direction)
    if wave is Node3D:
        wave.look_at(target_position, Vector3.UP)

func spawn_earthquake() -> void:
    if earthquake_scene == null:
        return
    if targeting == null or not targeting.has_method("get_current_target_position"):
        return

    var fissure := earthquake_scene.instantiate()
    get_parent().add_child(fissure)
    if fissure is Node3D:
        fissure.global_position = targeting.get_current_target_position()

func _set_property_if_exists(obj: Object, property_name: StringName, value: Variant) -> void:
    for property_info in obj.get_property_list():
        if property_info.get("name", "") == String(property_name):
            obj.set(property_name, value)
            return
