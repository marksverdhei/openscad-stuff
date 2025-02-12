


$fn = 50;  // High resolution for smooth curves

// ======================================
// PARAMETERS
// ======================================

// Shroud dimensions
shroud_length = 320;
shroud_width  = 110;
shroud_thick  = 20;   // 20 mm thick (3D printed plastic)

// Fan cutout parameters (each fan is 92x92 mm)
fan_size       = 92;
margin_left    = 10;
margin_right   = 10;
available_length = shroud_length - margin_left - margin_right;
gap_between    = ( available_length - 3 * fan_size ) / 2;
margin_top     = ( shroud_width - fan_size ) / 2;

// Fan mounting screw-hole parameters
screw_dia   = 4;       // mm diameter
screw_depth = shroud_thick + 1;  // mm (ensures complete through-cut)
screw_inset = 6;       // mm inset from fan cutout edges

// -------------------------------
// Pop‑on Hook (Half‑Spade) Parameters
// -------------------------------
hook_width       = 50;   // Horizontal extent of the hook (in its 2D profile)
hook_depth       = 15;   // Depth of the 2D profile (controls the pointed tip)
hook_y_thickness = 20;   // Thickness (extrusion) of the hook along its original y direction

// ======================================
// MODULES
// ======================================

// Base shroud: a rectangular plate.
module base_plate() {
  cube([shroud_length, shroud_width, shroud_thick]);
}

// Fan cutouts: three square openings.
module fan_cutouts() {
  union() {
    for(i = [0:2]) {
      translate([ margin_left + i*(fan_size + gap_between), margin_top, -1 ])
        // Extra height ensures a complete through-cut.
        cube([fan_size, fan_size, shroud_thick + 2]);
    }
  }
}

// Fan mounting screw holes: one at each corner of every fan cutout.
module fan_screw_holes() {
  union() {
    for(i = [0:2]) {
      fan_origin = margin_left + i*(fan_size + gap_between);
      for(x_off = [screw_inset, fan_size - screw_inset])
        for(y_off = [margin_top + screw_inset, margin_top + fan_size - screw_inset])
          translate([ fan_origin + x_off, y_off, 0 ])
            cylinder(h = screw_depth, r = screw_dia/2, center = false);
    }
  }
}

// Pop‑on hook defined as half a spade.
// The 2D polygon is drawn in the XY plane (with y negative meaning “downward”).
// We then extrude it and reorient it so that it extends downward (negative z).
module pop_hook_half_spade() {
    triangle = [
      [0, 0], [hook_width, 0], [hook_width/2, hook_depth]
    ];    
    linear_extrude(height = hook_y_thickness)
      rotate([90, 0, 0])
        translate([0, -hook_depth, 0])
          polygon(triangle);
}

// Combine the base plate with the pop‑on hook.
module shroud_with_hook() {
  union() {
    base_plate();
    pop_hook_half_spade();
  }
}

// Final shroud: subtract fan cutouts and screw holes.
module final_shroud() {
  difference() {
    shroud_with_hook();
    fan_cutouts();
    fan_screw_holes();
  }
}

// ======================================
// RENDER THE MODEL
// ======================================
final_shroud();
