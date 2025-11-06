package trenchbroom

import raylib "vendor:raylib"

to_public :: proc {
    face_to_public,
    poly_to_public,
    brush_to_public,
    map_to_public,
    entity_to_public,
}

clean_up :: proc {
    face_clean_up,
    _face_clean_up,
    brush_clean_up,
    _brush_clean_up,
    map_clean_up,
    _map_clean_up,
    entity_clean_up,
    _entity_clean_up,
    polygon_clean_up,
    _polygon_clean_up,
}


@(private="package")
_get_intersection :: proc(plane1: Plane, plane2: Plane, plane3: Plane) -> (p: raylib.Vector3, ok: bool) {
    denom := raylib.Vector3DotProduct(plane1.normal, raylib.Vector3CrossProduct(plane2.normal, plane3.normal));
    if (abs(denom) < raylib.EPSILON) {
        return raylib.Vector3{}, false;
    }
    p = (-plane1.dist * raylib.Vector3CrossProduct(plane2.normal, plane3.normal) - 
        plane2.dist * raylib.Vector3CrossProduct(plane3.normal, plane1.normal) - 
        plane3.dist * raylib.Vector3CrossProduct(plane1.normal, plane2.normal)) / denom;
    return p, true;
}