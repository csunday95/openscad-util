module locking_lug_profile_L(width, height) {
  points = [
    [0, 0],
    [0, height],
    [width, height],
    [width, height * 2],
    [width * 2, height * 2],
    [width * 2, 0]
  ];
  polygon(points);
}

module square_locking_lug_L(width, height, thickness) {
  linear_extrude(thickness)
    locking_lug_profile_L(width, height);
}

module cylinder_locking_lug_L(height, sector_angle, inner_radius, socket=false, chamfer_angle=5) {
  dims_mult = socket ? 1.15 : 1;
  difference() {
    rotate_extrude(angle=sector_angle * (socket ? 1.65 : 1))
      translate([inner_radius, 0, 0])
        square([height * dims_mult, height * dims_mult]);
    if (!socket) {
      rotate([0, 0, socket ? sector_angle : sector_angle / 2])
        translate([inner_radius - height / 2, 0, height])
          rotate([-chamfer_angle, 0, 0])
            cube([height * 2, height * 2, height]);
      rotate([0, 0, socket ? sector_angle : sector_angle / 2])
        translate([inner_radius - height / 2, 0, height])
          cube([height * 2, height * 2, height]);
    }
  }
  
  translate([0, 0, height])
    rotate_extrude(angle=socket ? 1.05 * sector_angle : sector_angle / 2)
      translate([inner_radius, 0, 0])
        square([height * dims_mult, height * dims_mult]);
}

//$fs = 0.1;
//$fa = 0.1;
//cylinder_locking_lug_L(2, 60, 5, socket=false);
