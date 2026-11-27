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
graphdea units if id!=6, inputs(hours) model(sbm) dmu(plant) focus("North site") compare(vrs fdh crs)
assert r(N)==5 & "`r(technologies)'"=="vrs fdh crs"
matrix m=r(sbm)
local names : rowfullnames m
assert "`names'"=="vrs:target1 fdh:target1 crs:target1 crs:target2"
matrix expected=(2,4,4,1,2/3,1/3,.25 \ 2,4,4,1,2/3,1/3,.25 \ 1.5,3,4.5,0,.75,0,.25 \ 6,12,0,9,0,3,.25)
mata: assert(mreldif(st_matrix("m"),st_matrix("expected"))<1e-14)
datasignature confirm
graphdea hours=units in 1/5, view(sbm) dmu(id) focus(1)
assert r(rho)==1 & "`r(technologies)'"=="vrs"

* A VRS optimum can be a mixture where the output constraint binds.
clear
input double(x y)
2 6
6 10
4 7
end
gen id=_n
graphdea x=y, view(sbm) dmu(id) focus(3) compare(crs vrs fdh) show(frontier)
matrix m=r(sbm)
assert rowsof(m)==4
assert m[3,1]==3 & m[3,2]==7 & m[3,7]==.75
assert m[4,5]==0 & m[4,6]==0 & m[4,7]==1
matrix expected=m
replace x=4*x
replace y=.5*y
graphdea x=y, view(sbm) dmu(id) focus(3) compare(crs vrs fdh)
matrix m=r(sbm)
mata: assert(mreldif(st_matrix("m"),st_matrix("expected"):*(4,.5,4,.5,1,1,1))<1e-14)

* Constant productivity gives a convex optimal edge and three discrete FDH bundles.
clear
input double(x y)
2 4
3 6
4 8
5 3
5 8
end
gen id=_n
graphdea x=y, view(sbm) dmu(id) focus(4) compare(fdh vrs)
matrix m=r(sbm)
assert rowsof(m)==5 & m[2,1]==3 & m[4,1]==2 & m[5,1]==4
mata: assert(max(abs(st_matrix("m")[,7]:-.3))<1e-14)
graphdea x=y, view(sbm) model(fdh) dmu(id) focus(5)
assert reldif(r(rho),.8)<1e-14
capture graphdea x=y, view(sbm)
assert _rc==198
capture graphdea x=y, view(sbm) dmu(id) focus(5) slackweights(1 2)
assert _rc==198
capture graphdea x=y, view(sbm) dmu(id) focus(5) orientation(sideways)
assert _rc==198
capture graphdea x=y, view(additive) model(sbm) dmu(id) focus(5)
assert _rc==198
di "SBM checks passed"
