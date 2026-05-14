extends Node3D

@export var dust_particle_scene: PackedScene

func crumble_to_dust(source_position: Vector3) -> void:
    var collision := get_node_or_null("CollisionShape3D") as CollisionShape3D
    if collision:
        collision.set_deferred("disabled", true)

    var blast_direction := (global_position - source_position).normalized()

    if dust_particle_scene:
        var dust := dust_particle_scene.instantiate()
        get_parent().add_child(dust)
        if dust is Node3D:
            dust.global_position = global_position

        # If your particle material exposes direction, set it here.
        if dust.has_method("set"):
            dust.set("blast_direction", blast_direction)

    var mesh := get_node_or_null("MeshInstance3D") as MeshInstance3D
    if mesh:
        mesh.hide()

    await get_tree().create_timer(3.0).timeout
    queue_free()
