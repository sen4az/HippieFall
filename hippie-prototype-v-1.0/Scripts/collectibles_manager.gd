extends Node3D

@export var collectibles: Array[PackedScene] = []
@export var spawn_chance: float = 0.70
@export var offset: Vector3 = Vector3(0, 2, 0)
@export var skip_initial_spawns: int = 2  # how many spawn calls to skip at start
@export var enable_debug_logs: bool = false

var rng := RandomNumberGenerator.new()
var collected_count: int = 0
var spawn_attempts: int = 0

func _ready() -> void:
	rng.randomize()
	add_to_group("collectibles_manager")

func spawn_on_segment(seg: Node3D, basis: Basis) -> void:
	spawn_attempts += 1
	if spawn_attempts <= skip_initial_spawns:
		if enable_debug_logs:
			print("spawn: skipping initial spawn ", spawn_attempts, "/", skip_initial_spawns)
		return

	if collectibles.is_empty():
		return
	for c in seg.get_children():
		if c.is_in_group("collectible"):
			c.queue_free()
	if rng.randf() > spawn_chance:
		return
	var inst := collectibles[0].instantiate() as Node3D
	if inst == null:
		return
	seg.add_child(inst)
	var origin: Vector3 = seg.global_transform.origin + seg.global_transform.basis * offset
	inst.global_transform = Transform3D(seg.global_transform.basis, origin)
	if enable_debug_logs:
		print("Collectible spawned on ", seg.name, " at ", origin)

func on_coin_collected() -> void:
	collected_count += 1
	print("Coins collected: ", collected_count)
