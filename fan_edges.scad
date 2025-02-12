module fan_edges(radius=46) {
    difference() {
        cube([92, 92, 3]);
        
        // Center large cylinder in the middle
        translate([46, 46, -1])
            cylinder(h=10, r=radius, center=true);
        
        // Small cylinders at each corner
        for (x = [6, 92-6], y = [6, 92-6]) {
            translate([x, y, -1])
                cylinder(h=10, r=4.5);
        }
    }
}

module repeated_fan_edges(radius=46) {
    for (i = [0:2]) {
        translate([i * 92, 0, 0])
            fan_edges(radius=radius);
    }
}

// Call the module to render it
// repeated_fan_edges(radius=49);
module frame(radius=46) {
    length = 295;

    difference() {
        cube([length, 100, 14]);
        translate([(length - 3*92) / 2, (100 - 92) / 2, -1])
            cube([3*92, 92, 16]);
    }
    
    difference() {
        translate([0, 0, 14])
        cube([length, 100, 3]);
        translate([(length - 3*92) / 2, (100 - 92) / 2, -1])
            cube([3*92, 92, 20]);
    }
    translate([(length - 3*92) / 2, (100 - 92) / 2, 14])
      repeated_fan_edges(radius=radius);
    
}
// Render the frame with cutouts
// frame(radius=45.2);