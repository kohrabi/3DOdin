package trenchbroom
 
import "core:sort"
import raylib "vendor:raylib"
import "core:math"
import "core:slice"
import "core:fmt"

PolyClassification :: enum {
    SPLIT, FRONT, BACK, ON_PLANE
}

@(private = "package")
_Polygon :: struct {
    vertices: [dynamic]Vertex,
    plane: Plane,
}

Polygon :: struct {
    vertices: []Vertex,
    plane: Plane,
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

polygon_classify :: proc (poly: Polygon) -> PolyClassification {
    front, back := false, false;
    for vert in poly.vertices {
        distance := raylib.Vector3DotProduct(poly.plane.normal, vert.position) + poly.plane.dist;
        if (distance > 0.001) {
            if (back) {
                return PolyClassification.SPLIT;
            }
            front = true;
        }
        else if (distance < -0.001) {
            if (front) {
                return PolyClassification.SPLIT;
            }
            back = true;
        }
    }
    if (front) {
        return PolyClassification.FRONT;
    }
    if (back) {
        return PolyClassification.BACK;
    }
    return PolyClassification.ON_PLANE;
}

polygon_calculate_uv :: proc(polygon: ^_Polygon, texture: raylib.Texture, u : raylib.Vector4, v : raylib.Vector4, scale: raylib.Vector2) {
    axisU := raylib.Vector3{ u.x, u.y, u.z };
    axisV := raylib.Vector3{ v.x, v.y, v.z };
    for &vertex in polygon.vertices {
        vertex.uv.x = raylib.Vector3DotProduct(axisU, vertex.position);
        vertex.uv.x /= (cast(f32)texture.width / scale.x);
        vertex.uv.x += u.w / cast(f32)texture.width;

        vertex.uv.y = raylib.Vector3DotProduct(axisV, vertex.position);
        vertex.uv.y /= (cast(f32)texture.height / scale.y);
        vertex.uv.y += v.w / cast(f32)texture.height;

        fmt.println(vertex.uv);
    }
    doU := true;
    doV := true;
    
    for vertex in polygon.vertices {
        if (vertex.uv.x < 1 && vertex.uv.x > -1) {
            doU = false;
        }
        if (vertex.uv.y < 1 && vertex.uv.y > -1) {
            doV = false;
        }
    }
    if (doU || doV) {
        nearestU : f32 = 0.0;
        nearestV : f32 = 0.0;
        if (doU) {
            if (polygon.vertices[0].uv.x > 1.0) {
                nearestU = math.floor(polygon.vertices[0].uv.x);
            }
            else {
                nearestU = math.ceil(polygon.vertices[0].uv.x);
            }
        }
        if (doV) {
            if (polygon.vertices[0].uv.y > 1.0) {
                nearestV = math.floor(polygon.vertices[0].uv.y);
            }
            else {
                nearestV = math.ceil(polygon.vertices[0].uv.y);
            }
        }

        for vertex in polygon.vertices {
            if (doU) {
                if (abs(vertex.uv.x) < abs(nearestU)) {
                    if (vertex.uv.x > 1.0) {
                        nearestU = math.floor(vertex.uv.x);
                    }
                    else {
                        nearestU = math.ceil(vertex.uv.x);
                    }
                }
            }
            if (doV) {
                if (abs(vertex.uv.y) < abs(nearestV)) {
                    if (vertex.uv.y > 1.0) {
                        nearestV = math.floor(vertex.uv.y);
                    }
                    else {
                        nearestV = math.ceil(vertex.uv.y);
                    }
                }
            }
        }

        for &vertex in polygon.vertices {
            vertex.uv.x -= nearestU;
            vertex.uv.y -= nearestV;
        }
    }
}

polygon_sort_cw :: proc(polygon : ^_Polygon) {
    using polygon;

    center : raylib.Vector3 = raylib.Vector3{ 0, 0, 0 };
    for vertex in vertices {
        center += vertex.position;
    }
    center = center / cast(f32)len(vertices);

    for i in 0..<len(vertices) - 2 {
        vertex := vertices[i];
        smallestAngle : f32 = -1.0;
        smallest := -1;

        a := raylib.Vector3Normalize(vertex.position - center);
        p : Plane = plane_create(vertex.position, center, center + plane.normal);

        for j in i + 1..<len(vertices) {
            if (plane_classify_point(p, vertices[j].position) != PointClassification.Back) {
                b := raylib.Vector3Normalize(vertices[j].position - center);
                angle := raylib.Vector3DotProduct(a, b);
                if (angle > smallestAngle) {
                    smallestAngle = angle;
                    smallest = j;
                }
            }
        }
        if (smallest == -1) {
            return;
        }
        
        t := vertices[smallest];
        vertices[smallest] = vertices[i + 1];
        vertices[i + 1] = t;
    }

    oldPlane := plane;
    calculate_plane(polygon);
    if (raylib.Vector3DotProduct(plane.normal, oldPlane.normal) < 0.0) {
        j := len(vertices);
        for i in 0..<j/2 {
            t := vertices[i];
            vertices[i] = vertices[j - i];
            vertices[j - i] = t;
        }
    }
}

calculate_plane :: proc(polygon: ^_Polygon) -> (bool) {
    using polygon;

    if (len(vertices) < 3) {
        return false;
    }

    plane.normal = raylib.Vector3{ 0, 0, 0 };
    centerOfMass := raylib.Vector3{ 0, 0, 0 };

    for i in 0..<len(vertices) {
        j := i + 1;
        if (j >= len(vertices)) {
            j = 0;
        }
        
        normal := plane.normal;
        normal.x += (vertices[i].position.y - vertices[j].position.y) * (vertices[i].position.z + vertices[j].position.z);
        normal.y += (vertices[i].position.z - vertices[j].position.z) * (vertices[i].position.x + vertices[j].position.x);
        normal.z += (vertices[i].position.x - vertices[j].position.x) * (vertices[i].position.y + vertices[j].position.y);

        plane.normal = normal;
        
        centerOfMass += vertices[i].position;
    }

    if (abs(plane.normal.x) < raylib.EPSILON && abs(plane.normal.y) < raylib.EPSILON && abs(plane.normal.z) < raylib.EPSILON) {
        return false;
    }

    magnitude := raylib.Vector3Length(plane.normal);
    if (magnitude < raylib.EPSILON) {
        return false;
    }

    plane.normal = raylib.Vector3Normalize(plane.normal);

    centerOfMass /= cast(f32)len(vertices);
    plane.dist = -raylib.Vector3DotProduct(centerOfMass, plane.normal);
    

    return true;
}