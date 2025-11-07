package trenchbroom

import "core:os"
import "core:strings"
import raylib "vendor:raylib"

RAYLIB_UNIT :: 100
TRENCHBROOM_AXIS :: raylib.Vector3 { -1, 1, 1 }

trenchbroom_load :: proc(path: string) -> (TrenchbroomMap, bool) {
    // Placeholder for loading a TrenchBroom map file
    data, ok := os.read_entire_file(path);
    if !ok {
        return TrenchbroomMap{ nil }, false;
    }
	defer delete(data);
    
    mapData := string(data);
    entitiesMap := _trenchbroom_parse(mapData);

    textureDict : map[cstring]raylib.Texture;
    defer delete(textureDict);
    // Gotta remember that this will operate on x axis reversed
    for entity in entitiesMap.entities {
        for &brush in entity.brushes {
            brush_generate_polys(&brush);

            // Process Polygon
            for &face in brush.faces {
                texturePath := strings.unsafe_string_to_cstring("content/textures/wall.jpg");
                if (face.texturePath == "") {
                    continue;
                }
                if (texturePath not_in textureDict) {
                    textureDict[texturePath] = raylib.LoadTexture(texturePath);
                }
                face.texture = textureDict[texturePath];

                face.plane.normal *= TRENCHBROOM_AXIS;
                for &poly in face.polys {
                    // Has to do first because this will break because of something i dont know
                    polygon_calculate_uv(&poly, face.texture, face.u, face.v, face.scale);
                
                    poly.plane = face.plane;
                    for &vertex in poly.vertices {
                        vertex.position *= TRENCHBROOM_AXIS;
                    }
                    polygon_sort_cw(&poly);
                }
            }
        }
    }

    // Deep copy to public struct
    // Is this fucking stupid?
    result := to_public(entitiesMap);
    clean_up(entitiesMap);

    return result, true;
}

trenchbroom_to_model :: proc (src: TrenchbroomMap) -> raylib.Model {
    meshes : [dynamic]raylib.Mesh;
    materials : [dynamic]raylib.Material;
    meshMaterials : [dynamic]i32;
    for entity in src.entities {
        if (entity.brushes == nil) {
            continue;
        }
        
        for brush in entity.brushes {
            mesh := brush_to_mesh(brush);
            raylib.UploadMesh(&mesh, false);
            material := raylib.LoadMaterialDefault();
            raylib.SetMaterialTexture(&material, raylib.MaterialMapIndex.ALBEDO, brush.faces[0].texture);
            append(&meshes, mesh);
            append(&materials, material);
            append(&meshMaterials, cast(i32)len(materials) - 1);    
        }
    }
    return raylib.Model {
        transform = raylib.Matrix(1),
        meshCount = cast(i32)len(meshes),
        materialCount = cast(i32)len(materials),
        meshes = raw_data(meshes[:]),
        materials = raw_data(materials[:]),
        meshMaterial = raw_data(meshMaterials[:]),
    };
}
