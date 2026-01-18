extends CanvasLayer

@export var gameplay_scene: PackedScene

@onready var play_button: Button = $MarginContainer/VBoxContainer/PlayButton
@onready var quit_button: Button = $MarginContainer/VBoxContainer/QuitButton


func _ready() -> void:
	play_button.pressed.connect(_on_play)
	quit_button.pressed.connect(_on_quit)

func _on_play() -> void:
	if gameplay_scene:
		get_tree().change_scene_to_packed(gameplay_scene)
	else:
		print("MainMenu: gameplay_scene not assigned")

func _on_quit() -> void:
	get_tree().quit()  # on mobile/web this may no-op; you can log instead
