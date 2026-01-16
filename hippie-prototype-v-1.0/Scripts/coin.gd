extends Area3D

@export var spin_rpm: float = 180.0 / 2
@export var sway_distance: float = 0.6
@export var sway_speed: float = 1.6
@export var bob_height: float = 0.15
@export var bob_speed: float = 2.0
@export var enable_debug_logs: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _t := 0.0
var _base_local_pos: Vector3 = Vector3.ZERO
var _mesh: Node3D
var _stopped := false
var _collected := false
var _debug_cooldown := 0.5

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	set_process(true)
	_base_local_pos = position
	_mesh = _find_mesh()
	add_to_group("collectible")
	body_entered.connect(_on_body_entered)

	if animation_player:
		animation_player.animation_finished.connect(_on_animation_finished)

	if _mesh == null and enable_debug_logs:
		print("coin.gd: no MeshInstance3D found under Coin")

func _process(delta: float) -> void:
	if _stopped or _collected:
		return

	_t += delta

	if _mesh:
		_mesh.rotate_z(spin_rpm * TAU / 60.0 * delta)

	var sway := sin(_t * sway_speed) * sway_distance
	var bob := sin(_t * bob_speed) * bob_height
	position = _base_local_pos + Vector3(sway, bob, 0.0)

	if enable_debug_logs:
		_debug_cooldown -= delta
		if _debug_cooldown <= 0.0:
			_debug_cooldown = 0.5
			if _mesh:
				print("coin rot deg: ", _mesh.rotation_degrees)
			else:
				print("coin: no mesh to rotate")

func stop_motion() -> void:
	_stopped = true
	set_process(false)

func _on_body_entered(body: Node) -> void:
	if body == null or _collected:
		return
	_collect(body)

func _collect(body: Node) -> void:
	_collected = true
	set_deferred("monitoring", false)
	stop_motion()

	var mgr = get_tree().get_first_node_in_group("collectibles_manager")
	if mgr:
		mgr.call_deferred("on_coin_collected")

	if animation_player and animation_player.has_animation("PICKUP"):
		animation_player.play("PICKUP")
	else:
		queue_free()

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "PICKUP":
		queue_free()

func _find_mesh() -> Node3D:
	var m = get_node_or_null("MeshInstance3D")
	if m:
		return m as Node3D
	for c in get_children():
		if c is MeshInstance3D:
			return c
	return null
