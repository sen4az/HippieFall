extends CSGBox3D

@export var rpm: float = 60.0          # rotations per minute
@export var axis: Vector3 = Vector3.UP # spin axis (Y for top view)

func _physics_process(delta: float) -> void:
	var radians := rpm * TAU / 60.0 * delta
	rotate_object_local(axis.normalized(), radians)
