package trenchbroom

import raylib "vendor:raylib"

@(private="package")
_Entity :: struct {
    values: map[string]string,
    // Brushes
    brushes: [dynamic]_Brush,
}

Entity :: struct {
    values: map[string]string,
    brushes: []Brush,
}

entity_to_public :: proc(src: _Entity) -> Entity {
    result : Entity = {
        values = src.values,
        brushes = make([]Brush, len(src.brushes)),
    };
    for &brush, i in src.brushes {
        result.brushes[i] = to_public(brush);
    }

    return result;
}

_entity_clean_up :: proc(src: _Entity) {
    if (src.brushes != nil) {
        for brush in src.brushes {
            clean_up(brush);
        }
        delete(src.brushes);
    }
    if (src.values != nil) {
        delete(src.values);
    }
}

entity_clean_up :: proc(src: Entity) {
    if (src.brushes != nil) {
        for brush in src.brushes {
            clean_up(brush);
        }
        delete(src.brushes);
    }
    if (src.values != nil) {
        delete(src.values);
    }
}