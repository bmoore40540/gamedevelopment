extends Area3D

@export var speed: float = 80.0
@export var lifetime: float = 10.0
var move_direction: Vector3 = Vector3.ZERO

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    await get_tree().create_timer(lifetime).timeout
    queue_free()

func _physics_process(delta: float) -> void:
    if move_direction != Vector3.ZERO:
        global_position += move_direction * speed * delta

func _on_body_entered(body: Node3D) -> void:
    if body.is_in_group("enemies") and body.has_method("die_by_divine_fire"):
        body.die_by_divine_fire()

    if body.is_in_group("buildings") and body.has_method("crumble_to_dust"):
        body.crumble_to_dust(global_position)
