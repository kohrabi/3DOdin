package components

EntityGroupEnum :: enum {
    Renderable,
    Collidable,
    Interactive,
}
EntityGroup :: bit_set[EntityGroupEnum];