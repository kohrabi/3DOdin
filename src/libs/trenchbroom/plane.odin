package trenchbroom

import raylib "vendor:raylib"

Plane :: struct {
    points: [3]raylib.Vector3,
    normal: raylib.Vector3,
    dist: f32,
}

PointClassification :: enum {
    Front,
    Back,
    OnPlane,
}

plane_distance_to_point :: proc(plane: Plane, point : raylib.Vector3) -> f32 {
    return raylib.Vector3DotProduct(plane.normal, point) + plane.dist;
}

plane_classify_point :: proc(plane: Plane, point : raylib.Vector3) -> PointClassification {
    d := plane_distance_to_point(plane, point);
    if (d > raylib.EPSILON) {
        return PointClassification.Front;
    } else if (d < -raylib.EPSILON) {
        return PointClassification.Back;
    } else {
        return PointClassification.OnPlane;
    }
}