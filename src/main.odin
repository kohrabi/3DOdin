package main

import "core:fmt"
import raylib "vendor:raylib"
import ecs "libs/ecs"
import rlgl "vendor:raylib/rlgl"
import trenchbroom "libs/trenchbroom"

import components "components"

ecsRegistry : ecs.Registry;

cameraEntity : ecs.Entity;

CameraControllerSystem := ecs.System {
    requiredComponents = { raylib.Camera3D },
    update = proc(registry : ^ecs.Registry, entity : ecs.Entity) {  
        camera, _ := ecs.ecs_entity_get_component_reference(registry, cameraEntity, raylib.Camera3D);

        raylib.UpdateCamera(camera, raylib.CameraMode.FREE);

        if (raylib.IsKeyPressed(raylib.KeyboardKey.Z)) {
            camera.target = (raylib.Vector3){ 0.0, 0.0, 0.0 };
        }
    } 
}

ModelDrawSystem := ecs.System {
    draw = proc(registry: ^ecs.Registry, entity: ecs.Entity) {
        camera, _ := ecs.ecs_entity_get_component(registry, cameraEntity, raylib.Camera3D);
        
        raylib.BeginMode3D(camera);

        raylib.DrawGrid(10, 1.0);
        trenchbroomModelStorage := ecs.ecs_component_get_storage(registry, components.TrenchBroomModel);
        for entity, component in trenchbroomModelStorage.components {
            raylib.DrawModel(component.model, raylib.Vector3(0), 1.0, raylib.WHITE);
        }

        raylib.EndMode3D();
     }
}


init :: proc () {
    ecsRegistry = ecs.ecs_create();
    ecs.ecs_component_register(&ecsRegistry, ecs.Group(components.EntityGroup));
    ecs.ecs_component_register(&ecsRegistry, ecs.Tag(components.EntityTag));
    ecs.ecs_component_register(&ecsRegistry, ecs.Transform);
    ecs.ecs_component_register(&ecsRegistry, raylib.Camera3D);
    ecs.ecs_component_register(&ecsRegistry, components.TrenchBroomModel);
 
    ecs.ecs_system_register(&ecsRegistry, CameraControllerSystem);
    ecs.ecs_system_register(&ecsRegistry, ModelDrawSystem);

    cameraEntity = ecs.ecs_entity_create(&ecsRegistry); 
    ecs.ecs_entity_add_component(&ecsRegistry, cameraEntity, raylib.Camera3D {
        position = raylib.Vector3{ 0, 10, 10 },
        target = raylib.Vector3{ 0, 0, 0 },
        up = raylib.Vector3{ 0, 1, 0 },
        fovy = 45.0,
        projection = raylib.CameraProjection.PERSPECTIVE,
    });

    testMap, _ := trenchbroom.trenchbroom_load("content/maps/unnamed.map");
    mapModel := trenchbroom.trenchbroom_to_model(testMap);

    trenchbroomEntity := ecs.ecs_entity_create(&ecsRegistry);
    ecs.ecs_entity_add_component(&ecsRegistry, trenchbroomEntity, components.TrenchBroomModel{
        model = mapModel,
        trenchbroomMap = testMap
    })

    raylib.DisableCursor()
}

update :: proc() {
    ecs.ecs_system_run_updates(&ecsRegistry);
}

draw :: proc () {

    raylib.ClearBackground(raylib.RAYWHITE);

    ecs.ecs_system_run_renders(&ecsRegistry);

    raylib.DrawRectangle( 10, 10, 320, 93, raylib.Fade(raylib.SKYBLUE, 0.5));
    raylib.DrawRectangleLines( 10, 10, 320, 93, raylib.BLUE);

    raylib.DrawText("Free camera default controls:", 20, 20, 10, raylib.BLACK);
    raylib.DrawText("- Mouse Wheel to Zoom in-out", 40, 40, 10, raylib.DARKGRAY);
    raylib.DrawText("- Mouse Wheel Pressed to Pan", 40, 60, 10, raylib.DARKGRAY);
    raylib.DrawText("- Z to zoom to (0, 0, 0)", 40, 80, 10, raylib.DARKGRAY);
}

main :: proc() {
    SCREEN_WIDTH :: 800;
    SCREEN_HEIGHT :: 600;

    raylib.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib [core] example - basic window");
    defer raylib.CloseWindow();

    init();
    
    for !raylib.WindowShouldClose() {
        
        update();

        raylib.BeginDrawing();

        draw();

        raylib.EndDrawing();
    }

    return;
}
