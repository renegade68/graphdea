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
gen long id = _n
datasignature set
graphdea units if id!=6, inputs(hours) view(additive) dmu(plant) focus("North site") compare(fdh vrs crs)
assert r(N)==5 & "`r(technologies)'"=="fdh vrs crs"
assert r(w_input)==1 & r(w_output)==1
matrix m=r(additive)
local rows : rowfullnames m
assert "`rows'"=="fdh:target1 fdh:target2 vrs:target1 vrs:target2 crs:target1"
matrix expected=(2,4,4,1,5 \ 4,6,2,3,5 \ 2,4,4,1,5 \ 4,6,2,3,5 \ 6,12,0,9,9)
mata: assert(mreldif(st_matrix("m"),st_matrix("expected"))<1e-14)
datasignature confirm

graphdea hours=units in 1/5, model(additive) dmu(id) focus(4) slackweights(2 1)
matrix m=r(additive)
assert "`r(technologies)'"=="vrs" & rowsof(m)==1 & m[1,1]==2 & m[1,5]==9
graphdea hours=units in 1/5, view(additive) dmu(id) focus(4) rts(crs) slackweights(2 1)
matrix m=r(additive)
matrix expected=(1.5,3,4.5,0,9 \ 6,12,0,9,9)
mata: assert(mreldif(st_matrix("m"),st_matrix("expected"))<1e-14)

* Both ends of the admissible VRS edge are interpolated.
replace units=5 in 4
graphdea hours=units in 2/4, view(additive) dmu(id) focus(4) rts(vrs) slackweights(1 4)
matrix m=r(additive)
assert rowsof(m)==1 & m[1,1]==6 & reldif(m[1,2],6+2/3)<1e-14
replace hours=3 in 2
replace units=3 in 2
graphdea hours=units in 2/4, view(additive) dmu(id) focus(4) slackweights(1 1)
matrix m=r(additive)
matrix expected=(5,5,1,0,1 \ 6,6,0,1,1)
mata: assert(mreldif(st_matrix("m"),st_matrix("expected"))<1e-14)

* Horizontal and vertical disposal edges, and efficiency at an observed vertex.
clear
input double(x y)
3 6
3 4
5 6
end
gen id=_n
forvalues i=1/3 {
    graphdea x=y, view(additive) dmu(id) focus(`i') compare(vrs fdh)
    matrix m=r(additive)
    assert rowsof(m)==2 & m[1,1]==3 & m[1,2]==6 & m[2,5]==cond(`i'==1,0,2)
}
capture graphdea x=y, view(additive)
assert _rc==198
capture graphdea x=y, dmu(id) focus(2) slackweights(1 2)
assert _rc==198
capture graphdea x=y, view(additive) dmu(id) focus(2) orientation(input)
assert _rc==198
capture graphdea x=y, view(additive) dmu(id) focus(2) slackweights(0 1)
assert _rc!=0
capture graphdea x=y, view(additive) dmu(id) focus(2) slackweights(1 .)
assert _rc!=0

* All three discrete optima, but only the two endpoints of the convex face.
clear
input double(x y)
1 3
2 4
3 5
4 1
end
gen id=_n
graphdea x=y, view(additive) dmu(id) focus(4) compare(fdh vrs) show(frontier)
matrix m=r(additive)
assert rowsof(m)==5 & m[2,1]==2 & m[4,1]==1 & m[5,1]==3
matrix expected=m
replace x=2*x
graphdea x=y, view(additive) dmu(id) focus(4) compare(fdh vrs) slackweights(.5 1)
matrix m=r(additive)
mata: assert(mreldif(st_matrix("m"),st_matrix("expected"):*(2,1,2,1,1))<1e-14)
di "additive checks passed"
