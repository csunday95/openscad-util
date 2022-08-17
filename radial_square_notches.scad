
module radial_square_notches_profile(side_length=1, notches=1, radius=1) {
  for(a=[0:360/notches:360]) {
    rotate([0, 0, a]) {
      translate([radius, 0, 0])
        square([side_length * 2, side_length], center=true);
    }
  }
}

module radial_square_notches(side_length=1, length=1, notches=1, radius=1) {
  for(a=[0:360/notches:360]) {
    rotate([0, 0, a]) {
      translate([radius, 0, 0])
        cube([side_length * 2, side_length, length], center=true);
    }
  }
}
