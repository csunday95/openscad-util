
function value_scan(idx, target, count, throw=0.1) =
  target * ((1 - throw) + 2 * (idx / count) * throw);
