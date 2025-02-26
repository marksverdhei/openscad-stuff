include <mounted_hook.scad>
include <fan_edges.scad>

module testbridge(hook_gap=1.6) {    
    translate([100+5, 0, 12])
    cube([20, 100, 2]);

    translate([106,0,0])
    mounted_hook();
    translate([106,0,0])
    rotate([0, 0, 180])
    translate([-17, -2-100, 0])
    mounted_hook();
}

shroud(hook_gap=1.6);