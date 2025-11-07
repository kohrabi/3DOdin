package components

import raylib "vendor:raylib"
import trenchbroom "../libs/trenchbroom"

TrenchBroomModel :: struct {
    model: raylib.Model,
    trenchbroomMap: trenchbroom.TrenchbroomMap
}