
include <zero_finders.scad>

function epicycloid_point(r, kp1, theta) = [
  r * (kp1 * cos(theta) - cos(kp1 * theta)),
  r * (kp1 * sin(theta) - sin(kp1 * theta))
];

function epicycloid_profile_points(r, k, step, max_theta=360, theta_offset=0) = [
  for (theta = [0:step:max_theta]) epicycloid_point(r, k + 1, theta + theta_offset)
];

function epicycloid_profile_points_R(r, k, step, max_theta=360, theta_offset=0) = [
  for (theta = [0:-step:-max_theta]) epicycloid_point(r, k + 1, theta + theta_offset)
];

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
      polygon(epicycloid_profile_points(pinion_r / 2, 2 * gear_ratio , 0.1, generating_angle, 0));
    rotate([0, 0, tooth_angle_subtend / 2])
      polygon(epicycloid_profile_points_R(pinion_r / 2, 2 * gear_ratio, 0.1, generating_angle, 0));
    polygon([
      [0, 0],
      [wheel_r + pinion_r, -pinion_r],
      [wheel_r + pinion_r, pinion_r],
    ]);
  }
}

module epicycloid_wheel_profile(pitch_diameter, tooth_count, pinion_gear_ratio) {
  wheel_radius = pitch_diameter / 2;
  pinion_radius = wheel_radius / pinion_gear_ratio;
  tooth_angle_subtend = 360 / tooth_count;
  pitch_circumferance = pitch_diameter * PI;
  circular_pitch = pitch_circumferance / tooth_count;
  dedendum_depth = circular_pitch / 2;
  dedendum_eff_radius = 2 * wheel_radius;
  dedendum_upper_width = 2 * dedendum_eff_radius * sin(tooth_angle_subtend / 4);
  dedenum_lower_width = 2 * (wheel_radius - dedendum_depth) * sin(tooth_angle_subtend / 4);
  dedenum_outward_shift =  wheel_radius * cos(tooth_angle_subtend / 4);
  difference() {
    circle(r=wheel_radius);
    for (a = [0:tooth_angle_subtend:360 - tooth_angle_subtend]) {
      rotate([0, 0, a + tooth_angle_subtend / 2])
        translate([dedenum_outward_shift, 0])
          polygon([
            [wheel_radius, -dedendum_upper_width / 2],
            [wheel_radius, dedendum_upper_width / 2],
            [-dedendum_depth, dedenum_lower_width / 2],
            [-dedendum_depth, -dedenum_lower_width / 2]
          ]);
      }
  }
  for (a = [0:tooth_angle_subtend:360 - tooth_angle_subtend]) {
    rotate([0, 0, a])
      epicycloid_tooth_profile(pitch_diameter, tooth_count, pinion_gear_ratio);
  }
}

module pinion_profile(pitch_diameter, leaf_count, dedendum_depth) {
  // actual dedendum depth should be computed based on wheel addendum
  pitch_radius = pitch_diameter / 2;
  leaf_angle_subtend = 360 / leaf_count;
  pitch_circumferance = pitch_diameter * PI;
  // use 2x radius here to ensure we subtract entire trapezoid
  dedendum_upper_width = 2 * pitch_diameter * sin(leaf_angle_subtend / 4);
  dedendum_lower_width = 2 * (pitch_radius - dedendum_depth) * sin(leaf_angle_subtend / 4);
  dedenum_outward_shift =  pitch_radius * cos(leaf_angle_subtend / 4);
  addendum_radius = pitch_radius * sin(leaf_angle_subtend / 4);
  difference() {
    circle(r=pitch_radius);
    for (a = [0:leaf_angle_subtend:360 - leaf_angle_subtend]) {
      rotate([0, 0, a]) 
        translate([dedenum_outward_shift, 0, 0])
          polygon([
            [pitch_radius, -dedendum_upper_width / 2],
            [pitch_radius, dedendum_upper_width / 2],
            [-dedendum_depth, dedendum_lower_width / 2],
            [-dedendum_depth, -dedendum_lower_width / 2]
          ]);
    }
  }
  for (a = [0:leaf_angle_subtend:360 - leaf_angle_subtend]) {
    rotate([0, 0, a + leaf_angle_subtend / 2])
      translate([pitch_radius, 0, 0])
        circle(r=addendum_radius);
  }
}

$fs = 0.2;
$fa = 0.2;

wheel_diameter = 80;
wheel_tooth_count = 96;
gear_ratio = 8;

rotate([0, 0, $t*360/gear_ratio])
epicycloid_wheel_profile(
  pitch_diameter=wheel_diameter,
  tooth_count=wheel_tooth_count,
  pinion_gear_ratio=gear_ratio
);

tooth_angle = 360 / wheel_tooth_count / 2;
generating_radius = wheel_diameter / 2 / gear_ratio / 2;
obj_func = function(t)  
  epicycloid_point(generating_radius, 2 * gear_ratio, t)[1] - 
  sin(tooth_angle / 2) * wheel_diameter / 2;

addendum_t = find_zero_bisect(
  f=obj_func,
  [tooth_angle, 30],
  iterations=30
);

addendum_len = 1.3 * abs(
  epicycloid_point(generating_radius, 2 * gear_ratio, 0)[0] - 
  epicycloid_point(generating_radius, 2 * gear_ratio, addendum_t)[0]
);

cyl_point(epicycloid_point(wheel_diameter / 2 / gear_ratio, gear_ratio, 19), r=0.2);
//cyl_point(epicycloid_point(wheel_diameter / 2 / gear_ratio, gear_ratio, addendum_t - tooth_angle), r=0.2);

// TODO: compute dedendum based on wheel addendum
translate([wheel_diameter / 2 + wheel_diameter / 2 / gear_ratio, 0, 0])
 rotate([0, 0, -$t*360])
 pinion_profile(
    pitch_diameter=wheel_diameter / gear_ratio,
    leaf_count=wheel_tooth_count / gear_ratio,
    dedendum_depth=addendum_len
  );
