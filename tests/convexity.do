version 16.0
clear
input str10 plant double(hours sales)
"South site" 8 8
"North site" 2 2
"Third"      4 6
"Other"      6 4
"North site" 1 99
end
gen long id = _n
datasignature set
graphdea sales if id<5, inputs(hours) view(convexity) dmu(plant) ///
    pair("North site" "South site") share(.75)
assert r(N)==4 & "`r(technologies)'"=="vrs fdh"
assert "`r(first)'"=="North site" & "`r(second)'"=="South site"
matrix m=r(mixture)
local cols : colnames m
assert "`cols'"=="share1 share2 x_mix y_mix y_max feasible"
matrix expected = (.75,.25,3.5,3.5,5,1 \ .75,.25,3.5,3.5,2,0)
mata: assert(mreldif(st_matrix("m"),st_matrix("expected"))<1e-14)
datasignature confirm

* Third makes the midpoint attainable under FDH. Reversing IDs complements share.
graphdea hours=sales in 1/4, view(convexity) dmu(id) pair(1 2) ///
    compare(fdh crs vrs) focus(4)
matrix m=r(mixture)
matrix expected = (.5,.5,5,5,6,1 \ .5,.5,5,5,7.5,1 \ .5,.5,5,5,6.5,1)
mata: assert(mreldif(st_matrix("m"),st_matrix("expected"))<1e-14)
matrix radial=r(projections)
assert rowsof(radial)==3
graphdea hours=sales if id<=2, view(convexity) model(fdh) dmu(id) pair(1 2)
matrix m=r(mixture)
assert m[1,5]==2 & m[1,6]==0
graphdea hours=sales in 1/4, view(convexity) model(fdh) dmu(id) pair(1 2) share(.25)
matrix m=r(mixture)
assert m[1,3]==3.5 & m[1,6]==0
foreach share in 0 1 {
    graphdea hours=sales in 1/4, view(convexity) model(fdh) dmu(id) pair(2 1) share(`share')
    matrix m=r(mixture)
    assert m[1,3]==cond(`share',2,8) & m[1,3]==m[1,4] & m[1,6]==1
}
capture graphdea hours=sales, view(convexity) dmu(plant) pair("North site" Third)
assert _rc==459
capture graphdea hours=sales in 1/2, view(convexity) dmu(id) pair(1 3)
assert _rc==459
capture graphdea hours=sales, view(convexity) dmu(id) pair(1 01)
assert _rc==459
capture graphdea hours=sales, view(convexity) dmu(id) pair(1)
assert _rc==198
capture graphdea hours=sales, view(convexity) dmu(id) pair(1 2) share(1.01)
assert _rc==125 | _rc==198
capture graphdea hours=sales, dmu(id) pair(1 2)
assert _rc==198
datasignature confirm

* Distinct units may have identical quantities, or the same input on an FDH step.
replace hours=8 in 2
graphdea hours=sales in 1/2, view(convexity) dmu(id) pair(1 2)
matrix m=r(mixture)
assert m[2,3]==8 & m[2,4]==5 & m[2,5]==8 & m[2,6]==1
replace sales=8 in 2
graphdea hours=sales in 1/2, view(convexity) dmu(id) pair(2 1)
matrix m=r(mixture)
assert m[1,5]==8 & m[2,6]==1
di "convexity checks passed"
