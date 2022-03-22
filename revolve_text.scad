
include <MCAD/constants.scad>

module revolve_text(radius, chars, font_size, thickness, arc_fraction=1, internal_rotation=[0,0,0]) {
    circumference = 2 * PI * radius;
    chars_len = len(chars);
    step_angle = 360 / chars_len * arc_fraction;
    for(i = [0 : chars_len - 1]) {
        rotate(-i * step_angle)
            translate([0, radius + font_size / 2, 0]) 
                rotate(internal_rotation)
                  linear_extrude(thickness)
                    text(
                        chars[i], 
                        font = "Courier New; Style = Bold", 
                        size = font_size, 
                        valign = "bottom", halign = "center"
                    );
    }
}
