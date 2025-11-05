package ecs

import raylib "vendor:raylib"
import intrinsics "base:intrinsics"

Transform :: struct {
    position: raylib.Vector3,
    rotation: raylib.Quaternion,
    scale:    raylib.Vector3,
}

Group :: struct($bitSet : typeid) where intrinsics.type_is_bit_set(bitSet) {
    group_id : bitSet,
}

Tag :: struct ($tagEnum : typeid) where intrinsics.type_is_enum(tagEnum) {
    tags : []tagEnum,
}