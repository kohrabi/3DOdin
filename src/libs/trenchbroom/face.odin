package trenchbroom
 
import raylib "vendor:raylib"

@(private = "package")
_Face :: struct {
    plane: Plane,
    texturePath: string,
    rotation: f32,
    uvOffset: raylib.Vector2,
    uvScale: raylib.Vector2,
    // Polys
    polys: []_Polygon,
}

Face :: struct {
    plane: Plane,
    texturePath: string,
    rotation: f32,
    uvOffset: raylib.Vector2,
    uvScale: raylib.Vector2,
    // Polys
    polys: []Polygon,
}

face_to_public :: proc(face: _Face) -> Face {
    publicFace := Face{
        plane = face.plane,
        texturePath = face.texturePath,
        rotation = face.rotation,
        uvOffset = face.uvOffset,
        uvScale = face.uvScale,
        polys = make([]Polygon, len(face.polys)),
    };
    for i in 0..<len(face.polys) {
        publicFace.polys[i] = to_public(face.polys[i]);
    }
    return publicFace;
}

_face_clean_up :: proc(face: _Face) {
    if (face.polys != nil) {
        for poly in face.polys {
            clean_up(poly);
        }
        delete(face.polys);
    }
}

face_clean_up :: proc(face: Face) {
    if (face.polys != nil) {
        for poly in face.polys {
            clean_up(poly);
        }
        delete(face.polys);
    }
}