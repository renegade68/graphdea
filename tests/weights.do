version 16.0
clear
input str1 id double(x y)
"A" 2 2
"B" 4 6
"C" 8 8
"D" 6 4
end
datasignature set
foreach direction in input output {
    graphdea x=y, dmu(id) focus("D") compare(crs vrs) orientation(`direction') ///
        show(frontier radial weights lambda) name(dea_test_weights, replace)
    matrix m = r(multipliers)
    matrix p = r(projections)
    assert "`r(orientation)'" == "`direction'"
    if "`direction'"=="input" matrix expected = (1/6,1/9,0,4/9 \ 1/6,1/12,1/6,.5)
    else matrix expected = (3/8,1/4,0,9/4 \ 1/8,1/4,-1,7/4)
    mata: assert(mreldif(st_matrix("m"),st_matrix("expected"))<1e-13)
    forvalues j=1/2 {
        assert m[`j',2]*y - m[`j',1]*x + m[`j',3] < 1e-12
        if "`direction'"=="input" {
            assert abs(m[`j',2]*4 - m[`j',1]*p[`j',1] + m[`j',3])<1e-12
        }
        else {
            assert abs(m[`j',2]*p[`j',3] - m[`j',1]*6 + m[`j',3])<1e-12
        }
    }
}
datasignature confirm
* At B the selected incident facet follows the projection direction.
graphdea x=y, dmu(id) focus("B") rts(vrs) show(weights)
matrix m = r(multipliers)
assert abs(m[1,1]/m[1,2]-2)<1e-12 & abs(m[1,4]-1)<1e-12
graphdea x=y, dmu(id) focus("B") rts(vrs) show(radialout weights)
matrix m = r(multipliers)
assert abs(m[1,1]/m[1,2]-.5)<1e-12 & "`r(orientation)'"=="output"
capture graphdea x=y, rts(vrs) show(weights)
assert _rc==198
capture graphdea x=y, compare(vrs fdh) dmu(id) focus("D") show(weights)
assert _rc==198

* Vertical and horizontal supports on disposal faces, plus original-unit scaling.
clear
input double(id x y)
1 2 8
2 6 4
3 2 8
end
graphdea y in 2/3, inputs(x) dmu(id) focus(2) rts(vrs) show(weights)
matrix m = r(multipliers)
assert abs(m[1,1]-1/6)<1e-12 & m[1,2]==0 & abs(m[1,3]-1/3)<1e-12
graphdea x=y, dmu(id) focus(2) rts(vrs) orientation(output) show(weights)
matrix m = r(multipliers)
assert m[1,1]==0 & m[1,2]==.25 & m[1,3]==-2 & m[1,4]==2
replace x = 10*x
replace y = 2*y
graphdea x=y, dmu(id) focus(2) compare(vrs crs) orientation(output) show(weights)
matrix m = r(multipliers)
assert m[1,2]==.125 & m[1,4]==2 & abs(m[2,1]-0.1)<1e-12 & abs(m[2,4]-6)<1e-12
graphdea x=y in 1, dmu(id) focus(1) rts(vrs) show(weights)
matrix m = r(multipliers)
assert m[1,2]==0 & m[1,4]==1
di "weights checks passed"
