
module cylinder_pt2pt3D(p1, p2, radius) {
  dist = norm(p2 - p1);
  dir_vector = (p2 - p1) / dist;
  // azimuth angle
  az = atan2(dir_vector[1], dir_vector[0]);
  // altitude angle
  alt = atan2(dir_vector[2], norm([dir_vector[0], dir_vector[1]]));
  echo([alt, az]);
  // rotate about y axis and z axis, translate to p1
  translate(p1)
    rotate([0, 90 - alt, az])
      cylinder(r=radius, h=dist);
}

module bar_point2_point(p1, p2, width, thickness, intrinsic_translation=[0,0]) {
  length = norm(p2 - p1);
  direction_vec = (p2 - p1) / length;
  rot = atan2(direction_vec[1], direction_vec[0]);
  linear_extrude(thickness)
    translate(p1)
      rotate([0, 0, rot - 90])
        translate([-width/2, 0] + intrinsic_translation)
          square([width, length]);
}

module rounded_bar_profile(width, length) {
  translate([-width/2, 0]) {
    square([width, length]);
    translate([width/2, 0])
      circle(r=width / 2);
    translate([width / 2, length])
      circle(r=width / 2);
  }
}

module rounded_bar(width, length, thickness) {
  linear_extrude(thickness) {
    rounded_bar_profile(width, length);
  }
}

module rounded_bar_point2point_profile(p1, p2, width) {
  length = sqrt((p1[0] - p2[0]) ^ 2 + (p1[1] - p2[1]) ^ 2);
  direction_vec = [(p2[0] - p1[0]) / length, (p2[1] - p1[1]) / length];
  rot = atan2(direction_vec[1], direction_vec[0]);
  translate(p1)
    rotate([0, 0, rot - 90])
  rounded_bar_profile(width, length);
}

module rounded_bar_point2point(p1, p2, width, thickness) {
  length = sqrt((p1[0] - p2[0]) ^ 2 + (p1[1] - p2[1]) ^ 2);
  direction_vec = [(p2[0] - p1[0]) / length, (p2[1] - p1[1]) / length];
  rot = atan2(direction_vec[1], direction_vec[0]);
  translate(p1)
    rotate([0, 0, rot - 90])
      rounded_bar(width, length, thickness);
}

module rounded_bar_with_pegs(width, length, thickness, peg_radius, peg_length, collar_thickness, collar_proportion=1.3, both_ends=false) {
  rounded_bar(width, length, thickness);
  cylinder(r=peg_radius, h=peg_length + thickness);
  cylinder(r=peg_radius * collar_proportion, h=thickness + collar_thickness);
  if (both_ends) {
    translate([0, length, 0]) {
      cylinder(r=peg_radius, h=peg_length + thickness);
      cylinder(r=peg_radius * collar_proportion, h=thickness + collar_thickness);
    }
  }
}

module rounded_bar_with_pegs_point2point(p1, p2, width, thickness, peg_radius, peg_length, collar_thickness, collar_proportion=1.3, both_ends=false) {
  length = sqrt((p1[0] - p2[0]) ^ 2 + (p1[1] - p2[1]) ^ 2);
  direction_vec = [(p2[0] - p1[0]) / length, (p2[1] - p1[1]) / length];
  rot = atan2(direction_vec[1], direction_vec[0]);
  translate(p1)
    rotate([0, 0, rot - 90])
      rounded_bar_with_pegs(
        width=width, 
        length=length,
        thickness=thickness,
        peg_radius=peg_radius,
        peg_length=peg_length, 
        collar_thickness=collar_thickness, 
        collar_proportion=collar_proportion, 
        both_ends=both_ends
      );
}
