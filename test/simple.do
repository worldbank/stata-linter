set obs 3
gen x = _n

summary x, det

exit, clear