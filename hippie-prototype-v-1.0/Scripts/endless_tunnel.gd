extends Node3D

@export var player_path: NodePath = NodePath("../Player")
@export var segments_root_path: NodePath = NodePath("../Segments")
@export var segment_variants: Array[PackedScene] = []
@export var collectibles_manager_path: NodePath

@export var active_segments: int = 4
@export var segment_length: float = 200.0
@export var direction: Vector3 = Vector3(0, -1, 0)
@export var recycle_margin: float = 0.5
@export var align_first_to_player: bool = true
@export var enable_debug_logs: bool = false
@export var max_recycles_per_frame: int = 8

var _player: Node3D
var _root: Node
var _segments: Array[Node3D] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _dir: Vector3 = Vector3(0, -1, 0)
var _spawn_basis: Basis = Basis.IDENTITY
var _collectibles_manager: Node = null

func _ready() -> void:
	_player = get_node_or_null(player_path) as Node3D
	_root = get_node_or_null(segments_root_path) as Node
	_collectibles_manager = get_node_or_null(collectibles_manager_path)

	if _player == null:
		push_error("SimpleNumericTunnelSpawner: player_path invalid.")
		return
	if _root == null:
		push_error("SimpleNumericTunnelSpawner: segments_root_path invalid.")
		return
	if segment_variants.is_empty():
		push_error("SimpleNumericTunnelSpawner: assign segment_variants.")
		return
	if active_segments < 2:
		active_segments = 2

	_rng.randomize()
	var dir_len: float = direction.length()
	if dir_len <= 0.0001:
		_dir = Vector3(0, -1, 0)
	else:
		_dir = direction / dir_len

	_spawn_basis = global_basis.orthonormalized()

	var base_pos: Vector3 = global_position
	if align_first_to_player:
		base_pos = _player.global_position

	for i in range(active_segments):
		var seg: Node3D = _instantiate_random()
		_root.add_child(seg)
		_segments.append(seg)
		var pos_i: Vector3 = base_pos + _dir * segment_length * float(i)
		seg.global_transform = Transform3D(_spawn_basis, pos_i)
		if enable_debug_logs:
			print("init seg ", i, " at ", pos_i)
		_spawn_collectibles(seg)

func _spawn_collectibles(seg: Node3D) -> void:
	if _collectibles_manager and _collectibles_manager.has_method("spawn_on_segment"):
		_collectibles_manager.call("spawn_on_segment", seg, _spawn_basis)

func _physics_process(delta: float) -> void:
	if _segments.is_empty():
		return

	var recycled: int = 0
	while recycled < max_recycles_per_frame:
		var front: Node3D = _segments[0]
		var start_pos: Vector3 = front.global_position
		var t: float = (_player.global_position - start_pos).dot(_dir)
		if t <= (segment_length - recycle_margin):
			break
		_recycle_move_front_to_tail()
		recycled += 1

	if recycled >= max_recycles_per_frame and enable_debug_logs:
		print("recycle cap hit this frame: ", recycled)

func _recycle_move_front_to_tail() -> void:
	if _segments.size() < 2:
		return

	var front: Node3D = _segments[0]
	_segments.remove_at(0)
	var tail: Node3D = _segments[_segments.size() - 1]
	var new_pos: Vector3 = tail.global_position + _dir * segment_length
	front.global_transform = Transform3D(_spawn_basis, new_pos)
	_segments.append(front)
	_reset_segment_recursive(front)
	_spawn_collectibles(front)

	if enable_debug_logs:
		print("recycle -> moved front to ", new_pos)

func _instantiate_random() -> Node3D:
	var idx: int = int(_rng.randi() % segment_variants.size())
	var scene: PackedScene = segment_variants[idx]
	var inst: Node = scene.instantiate()
	return inst as Node3D

func _reset_segment_recursive(n: Node) -> void:
	if n.has_method("recycle_reset"):
		n.call("recycle_reset")
	for c in n.get_children():
		_reset_segment_recursive(c)
