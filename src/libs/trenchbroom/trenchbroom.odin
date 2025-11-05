package trenchbroom

import "core:fmt"
import "core:os"
import "core:strings"

trenchbroom_load :: proc(path: string) -> bool {
    // Placeholder for loading a TrenchBroom map file
    data, ok := os.read_entire_file(path, context.allocator);
    if !ok {
        return false;
    }
	defer delete(data, context.allocator)

    it := string(data);
    for line in strings.split_lines_iterator(&it) {
        
    }

    return true;
}