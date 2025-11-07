package trenchbroom

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import raylib "vendor:raylib"

@(private="package")
_trenchbroom_parse :: proc(data : string) -> _TrenchbroomMap {

    result : _TrenchbroomMap = {
        entities = make([dynamic]_Entity),
    };
    currentEntity : _Entity = {};
    currentBrush : _Brush = {};

    it := string(data);
    nested := 0;

    for line in strings.split_lines_iterator(&it) {
        if strings.starts_with(line, "//") {
            continue;
        }
        if strings.starts_with(line, "{") {
            nested += 1;
            if (nested == 1) {
                currentEntity = _Entity {
                    values = nil,
                    brushes = nil,
                };
            }
            if (nested == 2) {
                currentBrush = _Brush{ faces = nil, };
            }
            continue;
        }
        if strings.starts_with(line, "}") {
            nested -= 1;
            if (nested == 0) {
                append(&result.entities, currentEntity);
            }
            else if (nested == 1) {
                append(&currentEntity.brushes, currentBrush);
            }
            continue;
        }
        trimmed := strings.trim(line, "\t ");

        if (nested == 1) {
            // Parse Entity
            if (currentEntity.values == nil) {
                currentEntity.values = make(map[string]string);
            }
            tokens := strings.split_n(trimmed, " ", 2);
            tokens[0] = strings.trim(tokens[0], "\"");
            tokens[1] = strings.trim(tokens[1], "\"");
            currentEntity.values[tokens[0]] = tokens[1];
        }
        else if (nested == 2) {
            // Parse Brush
            if (currentEntity.brushes == nil) {
                currentEntity.brushes = make([dynamic]_Brush);
            }
            tokens := strings.split(trimmed, " ");

            plane := Plane {
                points = {
                    raylib.Vector3{ 
                        cast(f32)strconv.atof(tokens[1]), 
                        cast(f32)strconv.atof(tokens[3]), 
                        cast(f32)strconv.atof(tokens[2]) 
                    },
                    raylib.Vector3{ 
                        cast(f32)strconv.atof(tokens[6]), 
                        cast(f32)strconv.atof(tokens[8]), 
                        cast(f32)strconv.atof(tokens[7]) 
                    },
                    raylib.Vector3{
                        cast(f32)strconv.atof(tokens[11]), 
                        cast(f32)strconv.atof(tokens[13]), 
                        cast(f32)strconv.atof(tokens[12]) 
                    },
                }
            };
            plane.normal = raylib.Vector3CrossProduct(
                (plane.points[0] - plane.points[1]),
                (plane.points[0] - plane.points[2]),
            );
            plane.dist = -raylib.Vector3DotProduct(plane.normal, plane.points[0]);

            face : _Face = {
                plane = plane,
                texturePath = tokens[15],
                u = raylib.Vector4{ 
                    cast(f32)strconv.atof(tokens[17]), 
                    cast(f32)strconv.atof(tokens[19]), 
                    cast(f32)strconv.atof(tokens[18]), 
                    cast(f32)strconv.atof(tokens[20]), 
                },
                v = raylib.Vector4{ 
                    cast(f32)strconv.atof(tokens[23]), 
                    cast(f32)strconv.atof(tokens[25]), 
                    cast(f32)strconv.atof(tokens[24]), 
                    cast(f32)strconv.atof(tokens[26]), 
                },
                rotation = cast(f32)strconv.atof(tokens[28]),
                scale = raylib.Vector2{ cast(f32)strconv.atof(tokens[29]), cast(f32)strconv.atof(tokens[30]) },
            }
            if (currentBrush.faces == nil) {
                currentBrush.faces = make([dynamic]_Face);
            }
            append(&currentBrush.faces, face);
        }
        else {
            continue;
        }
    }

    return result;
}
