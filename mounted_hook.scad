module hook(arm_length=1, arm_thickness=16, hook_length=5, hook_thickness=2, hook_width=23) {
    // Arm
    translate([0, -arm_thickness, 0])
    cube([arm_length, arm_thickness, hook_width]);

    // Small block
    translate([0, -16, 0])
    cube([2, 13, hook_width]);

    // Hook
    translate([0, 0, 0])
    linear_extrude(height = hook_width)
    polygon([[0, hook_length], [0, 0], [hook_thickness, 0]]);
}

// Wrapper module that applies transformations
module mounted_hook() {
    translate([20, 0, -2])
    rotate([90, 180, 270])
    hook();
}

// Call the new module
// mounted_hook();
