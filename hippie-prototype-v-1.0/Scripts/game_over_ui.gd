extends CanvasLayer

signal restart_requested

@onready var restart_button: Button = $MarginContainer/VBoxContainer/RestartButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # keep UI responsive while the game tree is paused
	hide()

	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	else:
		push_error("RestartButton not found under GameOverUI")

func show_ui() -> void:
	show()

func hide_ui() -> void:
	hide()

func _on_restart_pressed() -> void:
	restart_requested.emit()
