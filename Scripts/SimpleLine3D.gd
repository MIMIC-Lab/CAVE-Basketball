class_name SimpleLine3D
extends MeshInstance3D

var _immediate_mesh: ImmediateMesh

func _ready() -> void:
    _immediate_mesh = ImmediateMesh.new()
    self.mesh = _immediate_mesh

func draw_trajectory(points: PackedVector3Array) -> void:
    _immediate_mesh.clear_surfaces()
    _immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
    _immediate_mesh.surface_set_color(Color.WHITE)
    for point in points:
        _immediate_mesh.surface_add_vertex(point)
    _immediate_mesh.surface_end()
    self.mesh = _immediate_mesh