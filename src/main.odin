package main

import raylib "vendor:raylib"
import ecs "libs/ecs"
import trenchbroom "libs/trenchbroom"

ecsRegistry : ecs.Registry;

EntityTag :: enum {
    Player,
    Enemy,
    NPC,
}

EntityGroupEnum :: enum {
    Renderable,
    Collidable,
    Interactive,
}
EntityGroup :: bit_set[EntityGroupEnum];

cubePosition :: raylib.Vector3 { 0, 0, 0 };
camera : raylib.Camera3D = raylib.Camera3D {
    position = raylib.Vector3{ 0, 10, 10 },
    target = raylib.Vector3{ 0, 0, 0 },
    up = raylib.Vector3{ 0, 1, 0 },
    fovy = 45.0,
    projection = raylib.CameraProjection.PERSPECTIVE,
}
testMap : trenchbroom.TrenchbroomMap;

init :: proc () {
    ecsRegistry = ecs.ecs_create();
    ecs.ecs_component_register(&ecsRegistry, ecs.Group(EntityGroup));
    ecs.ecs_component_register(&ecsRegistry, ecs.Tag(EntityTag));
    ecs.ecs_component_register(&ecsRegistry, ecs.Transform);

    testMap, _ = trenchbroom.trenchbroom_load("content/maps/unnamed.map");

    raylib.DisableCursor()
}

update :: proc() {
    raylib.UpdateCamera(&camera, raylib.CameraMode.FREE);

    if (raylib.IsKeyPressed(raylib.KeyboardKey.Z)) {
        camera.target = (raylib.Vector3){ 0.0, 0.0, 0.0 };
    }
}

draw :: proc () {

    raylib.ClearBackground(raylib.RAYWHITE);

    raylib.BeginMode3D(camera);

        // raylib.DrawCube(cubePosition, 2.0, 2.0, 2.0, raylib.RED);
        // raylib.DrawCubeWires(cubePosition, 2.0, 2.0, 2.0, raylib.MAROON);


        for entity in testMap.entities {
            if (entity.brushes == nil || len(entity.brushes) == 0) {
                continue;
            }
            i := 0;
            for brush in entity.brushes {
                if (brush.faces == nil || len(brush.faces) == 0) {
                    continue;
                }
                for face in brush.faces {
                    for poly in face.polys {
                        for vertex in poly.vertices {
                            test := vertex.position / 100;
                            raylib.DrawSphere(test, 0.1 * cast(f32)i, raylib.GREEN);
                            i += 1;
                        }
                    }
                }
            }
        }

        raylib.DrawGrid(10, 1.0);

    raylib.EndMode3D();

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
