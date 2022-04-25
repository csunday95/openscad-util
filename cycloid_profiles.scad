
function epicycloid_point(r, kp1, theta) = [
  r * (kp1 * cos(theta) - cos(kp1 * theta)),
  r * (kp1 * sin(theta) - sin(kp1 * theta))
];

function epicycloid_profile_points(r, k, step, max_theta=360, theta_offset=0) = concat([
  for (theta = [0:step:max_theta]) epicycloid_point(r, k + 1, theta + theta_offset)
], [epicycloid_point(r, k + 1, max_theta + theta_offset)]);

function epicycloid_profile_points_R(r, k, step, max_theta=360, theta_offset=0) = concat([
  for (theta = [0:-step:-max_theta]) epicycloid_point(r, k + 1, theta + theta_offset)
], [epicycloid_point(r, k + 1, -max_theta + theta_offset)]);

function hypocycloid_points(r, km1, theta) = [
  r * km1 * cos(theta) + r * cos(km1 * theta),
  r * km1 * sin(theta) - r * sin(km1 * theta),
];

function hypocycloid_profile_points(r, k, step=0.1, max_theta=360, theta_offset=0) = [
  for (theta = [0:step:max_theta]) hypocycloid_points(r, k - 1, theta + theta_offset)
];

function hypocycloid_profile_points_R(r, k, step=0.1, max_theta=360, theta_offset=0) = [
  for (theta = [max_theta:-step:0]) hypocycloid_points(r, k - 1, theta + theta_offset)
];

module epicycloid_tooth_profile(wheel_pd, wheel_tooth_count, gear_ratio) {
  wheel_r = wheel_pd / 2;
  pinion_r = wheel_r / gear_ratio;
  tooth_angle_subtend = 360 / wheel_tooth_count / 2;
  generating_angle = 360 / gear_ratio;
  intersection() {
    rotate([0, 0, -tooth_angle_subtend / 2])
      polygon(epicycloid_profile_points(pinion_r / 2, 2 * gear_ratio , 0.05, generating_angle, 0));
    rotate([0, 0, tooth_angle_subtend / 2])
      polygon(epicycloid_profile_points_R(pinion_r / 2, 2 * gear_ratio, 0.05, generating_angle, 0));
//    polygon([
//      [0, 0],
//      [wheel_r + pinion_r, -pinion_r],
//      [wheel_r + pinion_r, pinion_r],
//    ]);
  }
}

module epicycloid_wheel_profile(pitch_diameter, tooth_count, pinion_gear_ratio) {
  wheel_radius = pitch_diameter / 2;
  pinion_radius = wheel_radius / pinion_gear_ratio;
  tooth_angle_subtend = 360 / tooth_count;
  pitch_circumferance = pitch_diameter * PI;
  circular_pitch = pitch_circumferance / tooth_count;
  dedendum_depth = circular_pitch / 2;
  dedendum_upper_width = 2 * wheel_radius * sin(tooth_angle_subtend / 4);
  dedenum_lower_width = 2 * (wheel_radius - dedendum_depth) * sin(tooth_angle_subtend / 4);
  dedenum_outward_shift =  wheel_radius * cos(tooth_angle_subtend / 4);
  circle(r=wheel_radius - dedendum_depth);
  for (a = [0:tooth_angle_subtend:360 - tooth_angle_subtend]) {
    rotate([0, 0, a + tooth_angle_subtend / 2]) {
      translate([dedenum_outward_shift, 0])
        polygon([
          [0, -dedendum_upper_width / 2],
          [0, dedendum_upper_width / 2],
          [-dedendum_depth, dedenum_lower_width / 2],
          [-dedendum_depth, -dedenum_lower_width / 2]
        ]);
      epicycloid_tooth_profile(pitch_diameter, tooth_count, pinion_gear_ratio);
    }
  }
}

module pinion_profile(pitch_diameter, leaf_count, dedendum_depth) {
  // actual dedendum depth should be computed based on wheel addendum
  pitch_radius = pitch_diameter / 2;
  leaf_angle_subtend = 360 / leaf_count;
  pitch_circumferance = pitch_diameter * PI;
  // use 2x radius here to ensure we subtract entire trapezoid
  dedendum_upper_width = pitch_diameter * sin(leaf_angle_subtend / 4);
  dedendum_lower_width = 2 * (pitch_radius - dedendum_depth) * sin(leaf_angle_subtend / 4);
  dedenum_outward_shift =  pitch_radius * cos(leaf_angle_subtend / 4);
  addendum_radius = pitch_radius * tan(leaf_angle_subtend / 4);
  circle(r=pitch_radius - dedendum_depth);
  for (a = [0:leaf_angle_subtend:360 - leaf_angle_subtend]) {
    rotate([0, 0, a]) {
      translate([dedenum_outward_shift, 0, 0])
        polygon([
          [-dedendum_depth, -dedendum_lower_width / 2],
          [-dedendum_depth, dedendum_lower_width / 2],
          [0, dedendum_upper_width / 2],
          [0, -dedendum_upper_width / 2]
        ]);
     translate([pitch_radius / cos(leaf_angle_subtend / 4), 0])
      circle(r=addendum_radius);
    }
  }
}
