package trenchbroom

import raylib "vendor:raylib"
import rlgl "vendor:raylib/rlgl"
import "core:fmt"


@(private="package")
_Brush :: struct {
    faces: [dynamic]_Face,
}

@(private="package")
Brush :: struct {
    faces: []Face,
}

brush_to_public :: proc(src: _Brush) -> Brush {
    result : Brush = {
        faces = make([]Face, len(src.faces)),
    };
    for &face, i in src.faces {
        result.faces[i] = to_public(face);
    }
    return result;
}

_brush_clean_up :: proc(src: _Brush) {
    if (src.faces != nil) {
        for face in src.faces {
            clean_up(face);
        }
        delete(src.faces);
    }
}

brush_clean_up :: proc(src: Brush) {
    if (src.faces != nil) {
        for face in src.faces {
            clean_up(face);
        }
        delete(src.faces);
    }
}

brush_generate_polys :: proc(brush: ^_Brush) {
    facesSize := len(brush.faces);
    for &face in brush.faces {
        if (face.polys != nil) {
            delete(face.polys);
        }
        face.polys = make([]_Polygon, 1);
    }
    for i in 0..<facesSize - 2 {
        for j in i + 1..<facesSize - 1 {
            for k in j + 1..<facesSize {
                if (i == j || j == k || i == k) {
                    continue;
                }
                iFace := &brush.faces[i];
                jFace := &brush.faces[j];
                kFace := &brush.faces[k];
                
                if p, ok := _get_intersection(iFace.plane, jFace.plane, kFace.plane); ok {
                    if (point_inside_brush(brush, p)) {
                        append(&iFace.polys[0].vertices, Vertex{position = p});
                        append(&jFace.polys[0].vertices, Vertex{position = p});
                        append(&kFace.polys[0].vertices, Vertex{position = p});
                        continue;
                    }
                }
            }
        }
    }
    // fmt.println(brush);
}

brush_to_mesh :: proc (brush: Brush) -> raylib.Mesh {
    vertexCount := 0;
    triangleCount := 0;
    vertices : [dynamic]f32;
    verticesMap : map[Vertex]u16;
    defer delete(verticesMap);
    
    texcoords : [dynamic]f32;
    normal : [dynamic]f32;
    indices : [dynamic]u16;
    for face in brush.faces {
        for poly in face.polys {
            for vertex in poly.vertices {
                if (vertex not_in verticesMap) {
                    verticesMap[vertex] = cast(u16)vertexCount;

                    vertexPosition := vertex.position / RAYLIB_UNIT;
                    append(&vertices, vertexPosition.x, vertexPosition.y, vertexPosition.z);
                    append(&normal, poly.plane.normal.x, poly.plane.normal.y, poly.plane.normal.z);
                    append(&texcoords, vertex.uv.x, vertex.uv.y);
                    
                    vertexCount += 1;
                }
            }

            for i in 1..<len(poly.vertices) - 1 {
                triangleCount += 1;
                append(&indices, 
                    verticesMap[poly.vertices[0]], 
                    verticesMap[poly.vertices[i]], 
                    verticesMap[poly.vertices[i + 1]],
                );
            }
        }
    }

    return raylib.Mesh{
        vertexCount = cast(i32)vertexCount,
        triangleCount =  cast(i32)triangleCount,
        vertices = raw_data(vertices[:]),
        texcoords = raw_data(texcoords[:]),
        indices = raw_data(indices[:])
    };
}

point_inside_brush :: proc(brush: ^_Brush, point: raylib.Vector3) -> bool {
    for face in brush.faces {
        if (plane_classify_point(face.plane, point) == PointClassification.Front) {
            return false;
        }
    }
    return true;
}
