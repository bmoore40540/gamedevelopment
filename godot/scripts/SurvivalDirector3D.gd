class_name SurvivalDirector3D
extends Area3D

signal health_pressure_changed(value: float)
signal resilience_value_changed(value: float)
signal resilience_depleted()

@export_group("Tuning")
@export_range(0.0, 1000.0, 0.1) var max_health_pressure: float = 100.0
@export_range(0.0, 1000.0, 0.1) var pressure_per_enemy: float = 15.0
@export_range(0.0, 1000.0, 0.1) var pressure_rise_rate: float = 60.0
@export_range(0.0, 1000.0, 0.1) var pressure_decay_rate: float = 30.0

@export_range(0.0, 1000.0, 0.1) var impact_pressure_boost: float = 20.0
@export_range(0.0, 1000.0, 0.1) var impact_pressure_decay_rate: float = 40.0
@export_range(0.0, 1000.0, 0.1) var impact_resilience_damage: float = 10.0

@export_range(0.0, 1000.0, 0.1) var max_resilience_value: float = 100.0
@export_range(0.0, 1000.0, 0.1) var resilience_recovery_rate: float = 8.0
@export_range(0.0, 1000.0, 0.1) var resilience_drain_rate: float = 20.0
@export_range(0.0, 1000.0, 0.1) var pressure_safe_threshold: float = 25.0

@export_group("Detection")
@export var enemy_group: StringName = &"enemies"
@export var projectile_group: StringName = &"projectiles"
@export var consume_projectiles_on_hit: bool = false

var health_pressure: float = 0.0
var resilience_value: float = 0.0

var _impact_pressure: float = 0.0
var _is_depleted: bool = false

var _nearby_enemies: Dictionary[int, Node3D] = {}

func _ready() -> void:
	resilience_value = max_resilience_value
	_emit_state_changed()

	var body_entered_cb: Callable = Callable(self, "_on_body_entered")
	if not body_entered.is_connected(body_entered_cb):
		body_entered.connect(body_entered_cb)

	var body_exited_cb: Callable = Callable(self, "_on_body_exited")
	if not body_exited.is_connected(body_exited_cb):
		body_exited.connect(body_exited_cb)

	var area_entered_cb: Callable = Callable(self, "_on_area_entered")
	if not area_entered.is_connected(area_entered_cb):
		area_entered.connect(area_entered_cb)

	var area_exited_cb: Callable = Callable(self, "_on_area_exited")
	if not area_exited.is_connected(area_exited_cb):
		area_exited.connect(area_exited_cb)

func _physics_process(delta: float) -> void:
	if _is_depleted:
		return

	_cleanup_nearby_enemies()

	_impact_pressure = move_toward(_impact_pressure, 0.0, impact_pressure_decay_rate * delta)

	var target_pressure: float = _compute_target_pressure()
	var rate: float = pressure_rise_rate if target_pressure > health_pressure else pressure_decay_rate
	var new_pressure: float = move_toward(health_pressure, target_pressure, rate * delta)
	_set_health_pressure(new_pressure)

	_update_resilience(delta)

func apply_projectile_impact(impact_strength: float = 1.0) -> void:
	if _is_depleted:
		return
	_impact_pressure = clampf(_impact_pressure + impact_pressure_boost * maxf(impact_strength, 0.0), 0.0, max_health_pressure)
	_set_resilience_value(resilience_value - impact_resilience_damage * maxf(impact_strength, 0.0))

func reset_to_full() -> void:
	_nearby_enemies.clear()
	_impact_pressure = 0.0
	_is_depleted = false
	_set_health_pressure(0.0)
	_set_resilience_value(max_resilience_value)

func _compute_target_pressure() -> float:
	var enemy_pressure: float = float(_nearby_enemies.size()) * pressure_per_enemy
	return clampf(enemy_pressure + _impact_pressure, 0.0, max_health_pressure)

func _update_resilience(delta: float) -> void:
	var safe_threshold: float = clampf(pressure_safe_threshold, 0.0, max_health_pressure)
	if health_pressure <= safe_threshold:
		_set_resilience_value(resilience_value + resilience_recovery_rate * delta)
		return

	var effective_range: float = maxf(1.0, max_health_pressure - safe_threshold)
	var over_ratio: float = clampf((health_pressure - safe_threshold) / effective_range, 0.0, 1.0)
	_set_resilience_value(resilience_value - (resilience_drain_rate * over_ratio * delta))

func _on_body_entered(body: Node3D) -> void:
	_handle_enter(body)

func _on_body_exited(body: Node3D) -> void:
	_handle_exit(body)

func _on_area_entered(area: Area3D) -> void:
	_handle_enter(area)

func _on_area_exited(area: Area3D) -> void:
	_handle_exit(area)

func _handle_enter(node: Node) -> void:
	if node.is_in_group(projectile_group):
		_register_impact_from(node)
		return

	if node is Node3D and node.is_in_group(enemy_group):
		_nearby_enemies[node.get_instance_id()] = node

func _handle_exit(node: Node) -> void:
	if node is Node3D and node.is_in_group(enemy_group):
		_nearby_enemies.erase(node.get_instance_id())

func _register_impact_from(node: Node) -> void:
	apply_projectile_impact(1.0)
	if consume_projectiles_on_hit and node.has_method("queue_free"):
		node.queue_free()

func _cleanup_nearby_enemies() -> void:
	if _nearby_enemies.is_empty():
		return

	var ids_to_remove: Array[int] = []
	for id: int in _nearby_enemies.keys():
		var enemy: Node3D = _nearby_enemies[id]
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			ids_to_remove.append(id)

	for id: int in ids_to_remove:
		_nearby_enemies.erase(id)

func _set_health_pressure(value: float) -> void:
	var clamped: float = clampf(value, 0.0, max_health_pressure)
	if is_equal_approx(clamped, health_pressure):
		return
	health_pressure = clamped
	health_pressure_changed.emit(health_pressure)

func _set_resilience_value(value: float) -> void:
	var clamped: float = clampf(value, 0.0, max_resilience_value)
	if is_equal_approx(clamped, resilience_value):
		return
	resilience_value = clamped
	resilience_value_changed.emit(resilience_value)

	if not _is_depleted and resilience_value <= 0.0:
		_is_depleted = true
		resilience_depleted.emit()

func _emit_state_changed() -> void:
	health_pressure_changed.emit(health_pressure)
	resilience_value_changed.emit(resilience_value)
