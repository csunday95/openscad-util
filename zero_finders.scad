
//function brent_next_guess(prev_bracket, mean_value) = 
//  let (mean = (prev_bracket[0] + prev_bracket[1]) / 2)
//    f(mean) > 0 ? 
//    [prev_bracket[0], mean] : 
//    [mean, prev_bracket[1]];

//echo(brent_next_guess([0, 1], 1));

// basic secant method root finder
function find_zero_bisect(f, bracket, iterations=15, eps=1e-20) = 
  let (mean = (bracket[0] + bracket[1]) / 2)
  //let(temp = echo(f(mean)))
    let (next_bracket = sign(f(mean)) == sign(f(bracket[0])) ? [mean, bracket[1]] : [bracket[0], mean])
      iterations > 0 && abs(bracket[0] - bracket[1]) >= eps ? 
      find_zero_bisect(f, next_bracket, iterations - 1) : 
      mean;

//function epicycloid_point(r, kp1, theta) = [
//  r * (kp1 * cos(theta) - cos(kp1 * theta)),
//  r * (kp1 * sin(theta) - sin(kp1 * theta))
//];
//      
//obj = function(x) sin(10 * x) / sin(x) - sin(5) / sin(10 * 5);
//
//obj_func = function(t)  
//  epicycloid_point(80 / 2 / 8 / 2, 8, t - 2)[0] - 
//  epicycloid_point(80 / 2 / 8 / 2, 8, t + 2)[0];
//
//eps = 1e-20;
//result_t = find_zero_bisect(obj_func, [eps, 30], 30);
//echo(result_t);
//echo(epicycloid_point(80 / 2 / 8 / 2, 8, result_t - 2));
//
module cyl_point(pt, r=1, h=20) {
  translate(pt)
    cylinder(r=r, h=h);
}

//$fs = 0.01;
//$fa = 0.01;
//
//for (lim = [5:1:15]) {
//  result = find_zero_bisect(obj, [eps, 30], lim);
//  cyl_point([result, obj(result)], r=0.05 + 0.1 * lim / 20, h=2);
//}
  