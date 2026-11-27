version 16.0
clear
input str10 plant double(hours output)
"A"          2 2
"North site" 4 6
"C"          8 8
"D"          6 4
"North site" 1 11
end
gen long id = _n
datasignature set
graphdea output if id<5, inputs(hours) view(disposability) ///
    dmu(plant) focus("North site") plan(7 6.5)
assert r(N)==4 & "`r(technologies)'"=="vrs fdh"
matrix m=r(disposal)
local names : colnames m
assert "`names'"=="x_focus y_focus x_plan y_plan from_focus y_max feasible"
matrix expected = (4,6,7,6.5,0,7.5,1 \ 4,6,7,6.5,0,6,0)
mata: assert(mreldif(st_matrix("m"),st_matrix("expected"))<1e-14)
datasignature confirm

* Direct disposal, equality on each edge, and the selected point itself.
foreach plan in "7 5" "4 0" "6 6" "4 6" {
    graphdea hours=output in 1/4, view(disposability) dmu(id) focus(2) ///
        compare(fdh crs vrs) plan(`plan')
    matrix m=r(disposal)
    mata: assert(all(st_matrix("m")[,(5,7)]:==1))
}
* Another observed DMU can establish feasibility outside the focus rectangle.
graphdea hours=output in 1/4, view(disposability) model(fdh) dmu(id) focus(2) plan(2 2)
matrix m=r(disposal)
assert m[1,5]==0 & m[1,6]==2 & m[1,7]==1
* Below the minimum input, no VRS or FDH plan exists, even at zero output.
foreach x in 0 1 {
    graphdea hours=output in 1/4, view(disposability) dmu(id) focus(2) ///
        compare(crs vrs fdh) plan(`x' 0)
    matrix m=r(disposal)
    assert m[1,6]==1.5*`x' & m[1,7]==1
    assert missing(m[2,6]) & missing(m[3,6]) & m[2,7]==0 & m[3,7]==0
}
* Extend the plot and evaluate the frontier beyond the observed data range.
graphdea hours=output in 1/4, view(disposability) dmu(id) focus(2) ///
    compare(crs vrs fdh) plan(12 18) show(pps frontier radial)
matrix m=r(disposal)
matrix radial=r(projections)
assert rowsof(radial)==3
matrix expected = (4,6,12,18,0,18,1 \ 4,6,12,18,0,8,0 \ 4,6,12,18,0,8,0)
mata: assert(mreldif(st_matrix("m"),st_matrix("expected"))<1e-14)
graphdea hours=output in 2, view(disposability) dmu(id) focus(2)
matrix m=r(disposal)
mata: assert(all(st_matrix("m")[,3..7]:==.))
capture graphdea hours=output, view(disposability)
assert _rc==198
capture graphdea hours=output, dmu(id) focus(2) plan(2 3)
assert _rc==198
capture graphdea hours=output, view(disposability) dmu(id) focus(2) plan(-1 2)
assert _rc!=0
capture graphdea hours=output, view(disposability) dmu(id) focus(2) plan(1 .)
assert _rc!=0
capture graphdea hours=output, view(disposability) dmu(id) focus(2) plan(2)
assert _rc!=0
capture graphdea hours=output id, view(disposability) dmu(id) focus(2)
assert _rc==198
datasignature confirm
di "disposability checks passed"
