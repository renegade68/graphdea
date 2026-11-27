* Directional projections, original units, axis-only directions and FDH steps.
version 16.0
clear
input str7 firm double(hours sales)
"A"      2 2
"B"      4 6
"C"      8 8
"plant D" 6 4
"omit"   1 100
end
gen id = _n
gen double savings = 1 if id==4
gen double gain = 1 if id==4
datasignature set
graphdea sales if id<5, inputs(hours) dmu(firm) focus("plant D") ///
    view(ddf) compare(fdh crs vrs) gx(savings) gy(gain)
assert r(N)==4 & "`r(technologies)'"=="fdh crs vrs"
matrix d = r(ddf)
local names : rownames d
assert "`names'"=="fdh crs vrs"
matrix expected = (2,1,1,4,6 \ 2,1,1,4,6 \ 2,1,1,4,6)
mata: assert(mreldif(st_matrix("d"),st_matrix("expected"))<1e-14)
datasignature confirm
capture graphdea hours=sales in 1/4, view(ddf) dmu(id) focus(1) gx(savings)
assert _rc==459

* With observed quantities as directions, the three endpoints differ.
graphdea hours=sales in 1/4, view(ddf) dmu(id) focus(4) compare(crs vrs fdh)
matrix d = r(ddf)
matrix expected = (5/13,6,4,48/13,72/13 \ 3/8,6,4,15/4,11/2 \ 1/3,6,4,4,16/3)
mata: assert(mreldif(st_matrix("d"),st_matrix("expected"))<1e-14)
foreach axis in x y {
    graphdea hours=sales in 1/4, show(frontier ddf radialin radialout) ///
        dmu(id) focus(4) compare(crs vrs fdh) g`axis'(0)
    matrix d = r(ddf)
    matrix radial = r(projections)
    if "`axis'"=="x" {
        mata: assert(mreldif(st_matrix("d")[,1],st_matrix("radial")[,4]:-1)<1e-14)
        mata: assert(all(st_matrix("d")[,4]:==6) & all(st_matrix("d")[,5]:==st_matrix("radial")[,3]))
    }
    else {
        mata: assert(mreldif(st_matrix("d")[,1],1:-st_matrix("radial")[,2])<1e-14)
        mata: assert(all(st_matrix("d")[,5]:==4) & all(st_matrix("d")[,4]:==st_matrix("radial")[,1]))
    }
}

* A weakly efficient FDH corner can move in each axis separately, but not jointly.
clear
input double(x y)
3 5
5 8
5 5
end
gen id=_n
graphdea x=y, view(ddf) model(fdh) dmu(id) focus(3) gx(1) gy(1)
matrix d=r(ddf)
assert d[1,1]==0 & d[1,4]==5 & d[1,5]==5
graphdea x=y, view(ddf) rts(vrs) dmu(id) focus(3) gx(2) gy(2)
matrix d=r(ddf)
assert reldif(d[1,1],.6)<1e-14 & reldif(d[1,4],3.8)<1e-14 & reldif(d[1,5],6.2)<1e-14

* CRS target may extend beyond the highest observed output.
replace x=100 in 3
graphdea x=y, view(ddf) dmu(id) focus(3) gx(1) gy(10)
matrix d = r(ddf)
assert d[1,5]>8 & reldif(d[1,5],(100-d[1,1])*5/3)<1e-14
capture graphdea x=y, view(ddf)
assert _rc==198
capture graphdea x=y, gx(1)
assert _rc==198
capture graphdea x=y, view(ddf) dmu(id) focus(2) gx(0) gy(0)
assert _rc==459
capture graphdea x=y, view(ddf) dmu(id) focus(2) gy(-1)
assert _rc==459
capture graphdea x=y, view(ddf) dmu(id) focus(2) gx(.)
assert _rc==459
capture graphdea x y=id, view(ddf) dmu(id) focus(2)
assert _rc==198
di "ddf checks passed"
