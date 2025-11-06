package trenchbroom

import raylib "vendor:raylib"

@(private = "package")
_TrenchbroomMap :: struct {
    entities: [dynamic]_Entity,
}

TrenchbroomMap :: struct {
    entities: []Entity,
}

map_to_public :: proc(src: _TrenchbroomMap) -> TrenchbroomMap {
    result : TrenchbroomMap = {
        entities = make([]Entity, len(src.entities)),
    };
    for &entity, i in src.entities {
        result.entities[i] = to_public(entity);
    }
    return result;
}

_map_clean_up :: proc (src: _TrenchbroomMap) {
    for entity in src.entities {
        clean_up(entity);
    }
}

map_clean_up :: proc (src: TrenchbroomMap) {
    for entity in src.entities {
        clean_up(entity);
    }
}