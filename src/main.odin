package main

import raylib "vendor:raylib"
import ecs "libs/ecs"

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

init :: proc () {
    ecsRegistry = ecs.ecs_create();
    ecs.ecs_component_register(&ecsRegistry, ecs.Group(EntityGroup));
    ecs.ecs_component_register(&ecsRegistry, ecs.Tag(EntityTag));
    ecs.ecs_component_register(&ecsRegistry, ecs.Transform);

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

        raylib.DrawCube(cubePosition, 2.0, 2.0, 2.0, raylib.RED);
        raylib.DrawCubeWires(cubePosition, 2.0, 2.0, 2.0, raylib.MAROON);

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
