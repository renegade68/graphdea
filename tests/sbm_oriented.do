version 16.0
clear
input str10 plant double(hours units)
"A"          2 4
"B"          4 6
"C"          7 7
"North site" 6 3
"A copy"     2 4
"omit"       1 20
"missing"    . 30
end
gen id = _n
datasignature set
foreach direction in input output {
    graphdea units if id!=6, inputs(hours) model(sbm) dmu(plant) ///
        focus("North site") orientation(`direction') compare(fdh crs vrs)
    assert r(N)==5 & "`r(orientation)'"=="`direction'"
    matrix m=r(sbm)
    local names : rowfullnames m
    assert "`names'"=="fdh:target1 crs:target1 vrs:target1"
    if "`direction'"=="input" {
        matrix expected=(2,4,4,1,2/3,1/3,1/3 \ 1.5,3,4.5,0,.75,0,.25 \ 2,4,4,1,2/3,1/3,1/3)
    }
    else {
        matrix expected=(4,6,2,3,1/3,1,.5 \ 6,12,0,9,0,3,.25 \ 6,20/3,0,11/3,0,11/9,.45)
    }
    mata: assert(mreldif(st_matrix("m"),st_matrix("expected"))<1e-14)
    datasignature confirm
}
* Weak boundary: score one may coexist with a gain on the unscored axis.
replace units=2 if id==1
graphdea hours=units in 1/5, view(sbm) dmu(id) focus(1) orientation(input)
matrix m=r(sbm)
assert r(rho)==1 & m[1,4]==2 & m[1,1]==2 & m[1,2]==4
replace hours=8 if id==4
replace units=7 if id==4
graphdea hours=units in 1/5, view(sbm) dmu(id) focus(4) orientation(output) show(frontier)
matrix m=r(sbm)
assert r(rho)==1 & m[1,3]==1 & m[1,1]==7 & m[1,2]==7
* The nonoriented default and its explicit spelling agree.
graphdea hours=units in 1/5, view(sbm) dmu(id) focus(4)
assert "`r(orientation)'"=="nonoriented"
matrix expected=r(sbm)
graphdea hours=units in 1/5, view(sbm) dmu(id) focus(4) orientation(nonoriented)
matrix m=r(sbm)
mata: assert(st_matrix("m")==st_matrix("expected"))
capture graphdea hours=units, view(additive) dmu(id) focus(4) orientation(input)
assert _rc==198
di "Oriented SBM checks passed"
