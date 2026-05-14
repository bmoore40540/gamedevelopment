extends Area3D

@export var swallow_speed: float = 15.0
var doomed_enemies: Array[Node3D] = []

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    await get_tree().create_timer(5.0).timeout
    queue_free()

func _physics_process(delta: float) -> void:
    for enemy in doomed_enemies:
        if is_instance_valid(enemy):
            enemy.global_position.y -= swallow_speed * delta

            if enemy.global_position.y < global_position.y - 20.0:
                enemy.queue_free()

func _on_body_entered(body: Node3D) -> void:
    if not body.is_in_group("enemies"):
        return

    if body is CharacterBody3D or body is RigidBody3D:
        var col := body.get_node_or_null("CollisionShape3D") as CollisionShape3D
        if col:
            col.set_deferred("disabled", true)

    if not doomed_enemies.has(body):
        doomed_enemies.append(body)
