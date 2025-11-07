package ecs

import "core:crypto/_aes/ct64"
import glm "core:math/linalg/glsl"
import "core:mem"

Entity :: distinct u32;

System :: struct {
    requiredComponents : []typeid,
    update: proc(ecs: ^Registry, entity : Entity),
    draw: proc(ecs: ^Registry, entity : Entity),
}

ComponentStorage :: struct($T : typeid) {
    components: map[Entity]T,
}

Registry :: struct {
    entities: [dynamic]Entity,
    components:  map[typeid]rawptr,
    next_entity_id: Entity,
    systems: [dynamic]System,
}

ecs_create :: proc() -> Registry {
    return Registry {
        next_entity_id = 1,
        components = make(map[typeid]rawptr),
        entities = make([dynamic]Entity, 0),
    };
}

ecs_destroy :: proc(ecs: ^Registry) {
    for type_id, component_map in ecs.components {
        storage := cast(^ComponentStorage(any))component_map;
        delete(storage.components);
        free(component_map)
    }
    delete(ecs.components)
    delete(ecs.entities)
}

ecs_component_register :: proc(ecs: ^Registry, $compType : typeid) {
    if compType not_in ecs.components {
        storage := new(ComponentStorage(compType));
        storage^.components = make(map[Entity]compType);
        ecs.components[compType] = storage;
    }
}

ecs_component_get_storage :: proc(ecs: ^Registry, $compType : typeid) -> ^ComponentStorage(compType) {
    if compType in ecs.components {
        return cast(^ComponentStorage(compType))ecs.components[compType];
    }
    return nil;
}

ecs_entity_create :: proc(ecs: ^Registry) -> Entity {
    entity : Entity = ecs.next_entity_id;
    append(&ecs.entities, entity);
    ecs.next_entity_id += 1;

    return entity;
}

ecs_entity_add_component :: proc(ecs: ^Registry, entity: Entity, component: $compType) {
    if compType not_in ecs.components {
        ecs_component_register(ecs, compType);
    }
    storage := ecs_component_get_storage(ecs, compType);
    storage.components[entity] = component;
}

ecs_entity_get_component :: proc(ecs: ^Registry, entity: Entity, $compType: typeid) -> (compType, bool) {
    component, ok := ecs_entity_get_component_reference(ecs, entity, compType);
    if ok {
        return component^, ok;
    }
    return {}, ok;
}


ecs_entity_get_component_reference :: proc(ecs: ^Registry, entity: Entity, $compType: typeid) -> (^compType, bool) {
    storage := ecs_component_get_storage(ecs, compType);
    if storage != nil {
        if entity in storage.components {
            return &storage.components[entity], true;
        }
    }
    return nil, false
}

@(private="file")
_ecs_system_get_entities :: proc(ecs: ^Registry, system: System) -> []Entity {
    
    get_storage :: proc(ecs: ^Registry, compType : typeid) -> ^ComponentStorage(any) {
        if compType in ecs.components {
            return cast(^ComponentStorage(any))ecs.components[compType];
        }
        return nil;
    }
    
    entities : [dynamic]Entity;
    // If it doesn't require any elements return the full entities list.
    // Not Recommended
    if (system.requiredComponents == nil || len(system.requiredComponents) == 0) {
        entities := make([dynamic]Entity, len(ecs.entities));
        copy(entities[:], ecs.entities[:]);
        return entities[:]; 
    }

    // Use first component entities as base 
    storage := get_storage(ecs, system.requiredComponents[0]);
    for entity, _ in storage.components {
        append(&entities, entity);
    }
    for i in 1..<len(system.requiredComponents) {
        storage = get_storage(ecs, system.requiredComponents[i]);
        if (len(entities) == 0) {
            break;
        }
        for j := 0; j < len(entities); {
            if (entities[j] not_in storage.components) {
                unordered_remove(&entities, j);   
            }
            else {
                j += 1;
            }
        } 
    }

    return entities[:];
}

ecs_system_register :: proc(ecs: ^Registry, system: System) {
    append(&ecs.systems, system);
}

ecs_system_run_updates :: proc(ecs: ^Registry) {
    for system in ecs.systems {
        if system.update != nil {
            entities := _ecs_system_get_entities(ecs, system);
            for entity in entities {
                system.update(ecs, entity);
            }
            delete(entities);
        }
    }
}

ecs_system_run_renders :: proc(ecs: ^Registry) {
    for system in ecs.systems {
        if system.draw != nil {
            entities := _ecs_system_get_entities(ecs, system);
            for entity in entities {
                system.draw(ecs, entity);
            }
            delete(entities);
        }
    }
}
