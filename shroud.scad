include <mounted_hook.scad>
include <fan_edges.scad>

// frame();
module shroud(radius=45.2) {    
    translate([0, 1, 0])
    frame(radius=radius);
    translate([106,0,0])
    mounted_hook();

    translate([106,0,0])
    rotate([0, 0, 180])
    translate([-17, -2-100, 0])
    mounted_hook();
}

shroud();