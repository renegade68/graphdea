* Run from the graphdea directory with: do tests/graphdea.do
version 16.0
clear
input str1 id double(x y)
"A" 2 2
"B" 4 6
"C" 8 8
"D" 6 4
end
label var x "Input"
label var y "Output"
datasignature set
graphdea x = y, dmu(id) focus("D") compare(crs vrs fdh) ///
    show(pps frontier radialin radialout) name(comparison, replace)
assert r(N) == 4
matrix actual = r(projections)
matrix expected = (8/3,4/9,9,9/4,4/9 \ 3,1/2,7,7/4,4/7 \ 4,2/3,6,3/2,2/3)
mata: assert(max(abs(st_matrix("actual")-st_matrix("expected"))) < 1e-12)
datasignature confirm

* Restrict the reference sample, then focus separately, using numeric IDs.
gen long seq = _n
graphdea y if seq > 1 in 1/4, inputs(x) dmu(seq) focus(4) ///
    rts(vrs) orientation(output)
assert r(N) == 3
matrix subset = r(projections)
assert subset[1,1] == 4 & subset[1,3] == 7

* Repeated inputs, dominated/collinear points, and rightward free disposal.
clear
input str7 id double(x y)
"first"   1 3
"tied"    1 2
"same"    1 3
"below"   2 3.5
"on line" 3 5
"peak"    4 6
"focus"   5 4
"missing" . 20
end
graphdea x=y, compare(fdh vrs) dmu(id) focus("focus")
matrix actual = r(projections)
assert r(N) == 7
assert actual[1,1] == 3 & actual[1,3] == 6
assert abs(actual[2,1]-2) < 1e-12 & actual[2,3] == 6
graphdea y if id == "on line", inputs(x) dmu(id) focus("on line") compare(crs vrs fdh)
matrix actual = r(projections)
mata: assert(all(st_matrix("actual")[,(2,4,5)] :== 1))

graphdea x = y if id == "peak", model(fdh)
assert r(N) == 1
capture noisily graphdea x = y, compare(crs crs)
assert _rc == 198
capture noisily graphdea x = y, show(radial)
assert _rc == 198
capture noisily graphdea x = y, dmu(id) focus("absent")
assert _rc == 459
replace x = 0 in 1
capture noisily graphdea x = y
assert _rc == 459
assert _N == 8 & x[1] == 0
di "graphdea checks passed"
