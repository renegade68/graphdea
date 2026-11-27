version 16.0
clear
input str10 plant double(hours units)
"A" 2 4
"North site" 4 6
"C" 7 7
"D" 6 3
"omit" 1 12
"missing" 1 .
end
gen id=_n
datasignature set
foreach dir in input output {
    graphdea units if id!=5, inputs(hours) model(super) dmu(plant) ///
        focus("North site") compare(fdh crs vrs) orientation(`dir')
    assert r(N)==4 & r(N_ref)==3 & "`r(orientation)'"=="`dir'"
    matrix m=r(super)
    local names : rownames m
    assert "`names'"=="fdh crs vrs"
    if "`dir'"=="input" {
        matrix expected=(1,7/4,7/4,7,6,1 \ .75,.75,.75,3,6,1 \ 1,4/3,4/3,16/3,6,1)
    }
    else {
        matrix expected=(1,2/3,1.5,4,4,1 \ .75,4/3,.75,4,8,1 \ 1,13/15,15/13,4,26/5,1)
    }
    mata: assert(mreldif(st_matrix("m"),st_matrix("expected"))<1e-13)
    datasignature confirm
}
* The highest output cannot be attained by VRS or FDH peers even at larger input.
graphdea hours=units in 1/4, view(super) dmu(id) focus(3) compare(vrs crs fdh)
matrix m=r(super)
assert m[1,6]==0 & missing(m[1,3]) & missing(m[1,4]) & missing(m[1,5]) & m[1,1]==1
assert m[2,6]==1 & m[3,6]==0
* One remaining reference unit. The VRS output problem has no feasible target.
graphdea hours=units in 1/2, view(super) rts(vrs) dmu(id) focus(1) orientation(output)
assert missing(r(super_score)) & r(N_ref)==1
matrix m=r(super)
assert m[1,6]==0 & missing(m[1,2]) & m[1,1]==1
* CRS input can intersect far beyond the observed input range.
replace units=.5 if id==2
graphdea hours=units in 1/2, view(super) dmu(id) focus(1)
matrix m=r(super)
assert r(super_score)==16 & m[1,4]==32 & m[1,5]==4 & "`r(technologies)'"=="crs"
* A different unit at the same coordinates remains in the peer technology.
replace hours=2 if id==2
replace units=4 if id==2
graphdea hours=units in 1/2, view(super) dmu(id) focus(1) compare(vrs fdh crs) show(frontier)
matrix m=r(super)
mata: assert(st_matrix("m")==J(3,1,1)*(1,1,1,2,4,1))
* Preserve the sampling rule, and reject unrelated layers.
capture graphdea hours=units in 1, view(super) dmu(id) focus(1)
assert _rc==459
capture graphdea hours=units, view(super) dmu(id) focus(1) show(slacks)
assert _rc==198
capture graphdea hours=units, view(super)
assert _rc==198
datasignature clear
di "Super-efficiency checks passed"
