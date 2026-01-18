extends CanvasLayer  # or Control/Node, whatever your HUD root is

@export var player_path: NodePath
@export var depth_label_path: NodePath

@onready var player := get_node(player_path)
@onready var depth_label: Label = get_node(depth_label_path)


var start_y: float = 0.0

func _ready() -> void:
	if player:
		start_y = player.global_transform.origin.y
	else:
		push_error("HUD: player_path not set")
	_update_depth_label(0.0)

func _process(_delta: float) -> void:
	if not player:
		return
	var depth = start_y - player.global_transform.origin.y  # Y goes down = smaller Y
	if depth < 0.0:
		depth = 0.0
	_update_depth_label(depth)

func reset_depth(new_start: float = INF) -> void:
	if new_start == INF and player:
		start_y = player.global_transform.origin.y
	else:
		start_y = new_start
	_update_depth_label(0.0)

func _update_depth_label(depth: float) -> void:
	depth_label.text = "DEPTH: %.1f m" % depth
