extends Node

@export var player_path: NodePath = NodePath("../Player")
@export var game_over_ui_path: NodePath = NodePath("../GameOverUI")

var _player: Node
var _ui: Node

func _ready() -> void:
	_player = get_node_or_null(player_path)
	_ui = get_node_or_null(game_over_ui_path)
	
	if _player == null:
		push_error("GameOverManager: player_path invalid.")
		return
	if _ui == null:
		push_error("GameOverManager: game_over_ui_path invalid.")
		return

	if _player.has_signal("died"):
		_player.connect("died", Callable(self, "_on_player_died"))
	else:
		push_error("GameOverManager: Player does not have 'died' signal!")

	if _ui.has_method("hide_ui"):
		_ui.call("hide_ui")

	if _ui.has_signal("restart_requested"):
		_ui.connect("restart_requested", Callable(self, "_on_restart_requested"))
	else:
		push_error("GameOverManager: GameOverUI missing restart_requested signal")

func _on_player_died() -> void:
	_stop_collectibles()           # <-- stop coin motion
	get_tree().paused = true
	if _ui.has_method("show_ui"):
		_ui.call("show_ui")

func _stop_collectibles() -> void:
	for c in get_tree().get_nodes_in_group("collectible"):
		c.call_deferred("stop_motion")

func _on_restart_requested():
	get_tree().paused = false
	get_tree().reload_current_scene()
