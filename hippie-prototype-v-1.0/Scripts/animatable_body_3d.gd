extends StaticBody3D

@export var rpm: float = 20.0
@export var axis: Vector3 = Vector3.UP

var _base_basis: Basis = Basis.IDENTITY
var _time: float = 0.0

func _ready() -> void:
	scale = Vector3.ONE
	_apply_material_safety(self)
	call_deferred("_capture_base_basis")

func recycle_reset() -> void:
	_time = 0.0
	call_deferred("_capture_base_basis")

func _physics_process(delta: float) -> void:
	_time += delta
	var ang_vel: float = rpm * TAU / 60.0
	var angle: float = ang_vel * _time
	var rot_basis: Basis = Basis(axis.normalized(), angle)
	var new_basis: Basis = _base_basis * rot_basis
	var origin: Vector3 = global_transform.origin
	global_transform = Transform3D(new_basis, origin)

func _capture_base_basis() -> void:
	_base_basis = global_transform.basis.orthonormalized()

func _apply_material_safety(root: Node) -> void:
	for child in root.get_children():
		var mi: MeshInstance3D = child as MeshInstance3D
		if mi != null:
			var mat: BaseMaterial3D = mi.get_active_material(0)
			if mat == null:
				var std: StandardMaterial3D = StandardMaterial3D.new()
				mi.set_surface_override_material(0, std)
				mat = std
			mat.cull_mode = BaseMaterial3D.CULL_DISABLED
			mi.visibility_range_begin = 0.0
			mi.visibility_range_end = 0.0
		_apply_material_safety(child)
