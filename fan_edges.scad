// Height / width in mm
fan_size=92;

module fan_edges(radius=45, screw_hole_radius=2, hole_offset=3) {
    difference() {
        cube([fan_size, fan_size, 3]);
        
        // Center large cylinder in the middle
        translate([fan_size/2, fan_size/2, -1])
            cylinder(h=10, r=radius, center=true);
        
        // Small cylinders at each corner
        for (x = [hole_offset, fan_size-hole_offset], y = [hole_offset, fan_size-hole_offset]) {
            translate([x, y, -1])
                cylinder(h=10, r=screw_hole_radius);
        }
    }
}

module repeated_fan_edges(radius=45, n_fans=2, screw_hole_radius=2) {
    for (i = [0:n_fans-1]) {
        translate([i * fan_size, 0, 0])
            fan_edges(radius=radius, screw_hole_radius=screw_hole_radius);
    }
}

module frame(radius=45, n_fans=2, screw_hole_radius=2) {
    length = 100 * n_fans - 5;

    difference() {
        cube([length, 100, 14]);
        translate([(length - n_fans*fan_size) / 2, (100 - fan_size) / 2, -1])
            cube([3*fan_size, fan_size, 16]);
    }
    
    difference() {
        translate([0, 0, 14])
        cube([length, 100, 3]);
        translate([(length - n_fans*fan_size) / 2, (100 - fan_size) / 2, -1])
            cube([3*fan_size, fan_size, 20]);
    }
    translate([(length - n_fans*fan_size) / 2, (100 - fan_size) / 2, 14])
      repeated_fan_edges(radius=radius, n_fans=n_fans, screw_hole_radius=screw_hole_radius);
    
}

