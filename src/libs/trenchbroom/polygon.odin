package trenchbroom
 
import raylib "vendor:raylib"

@(private = "package")
_Polygon :: struct {
    vertices: [dynamic]Vertex,
    plane: Plane
}

Polygon :: struct {
    vertices: []Vertex,
    plane: Plane
}

poly_to_public :: proc(poly: _Polygon) -> Polygon {
    publicPoly := Polygon{
        vertices = make([]Vertex, len(poly.vertices)),
        plane = poly.plane,
    };
    copy(publicPoly.vertices, poly.vertices[:]);
    return publicPoly;
}

_polygon_clean_up :: proc(poly: _Polygon) {
    if (poly.vertices != nil) {
        delete(poly.vertices);
    }
}

polygon_clean_up :: proc(poly: Polygon) {
    if (poly.vertices != nil) {
        delete(poly.vertices);
    }
}