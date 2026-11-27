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
    graphdea x=y, dmu(id) focus("D") view(scale) orientation(`direction') title("") ///
        xtitle("Labor") ytitle("Production") name(scale_test, replace)
    assert r(N)==4 & "`r(technologies)'"=="crs vrs" & "`r(orientation)'"=="`direction'"
    assert abs(r(te_crs)-4/9)<1e-12
    if "`direction'"=="input" {
        assert "`r(rts)'"=="irs" & abs(r(te_nirs)-4/9)<1e-12
        assert abs(r(te_vrs)-1/2)<1e-12 & abs(r(se)-8/9)<1e-12
    }
    else {
        assert "`r(rts)'"=="drs" & abs(r(te_nirs)-4/7)<1e-12
        assert abs(r(te_vrs)-4/7)<1e-12 & abs(r(se)-7/9)<1e-12
    }
    matrix target = r(projections)
    graphdea x=y, dmu(id) focus("D") compare(crs vrs)
    matrix production = r(projections)
    mata: assert(all(st_matrix("target"):==st_matrix("production")))
}
datasignature confirm
* CRS and VRS projections can coincide away from, or at, the selected DMU.
replace y = 6 in 4
gen seq = _n
graphdea y if seq>=2, inputs(x) dmu(seq) focus(4) view(scale)
assert r(N)==3 & abs(r(se)-1)<1e-12 & r(te_crs)<1
assert "`r(rts)'"=="crs" & abs(r(te_nirs)-r(te_vrs))<1e-12
graphdea x=y in 2, dmu(seq) focus(2) view(scale) orientation(output)
assert r(N)==1 & r(se)==1 & r(te_crs)==1 & r(te_vrs)==1
assert "`r(rts)'"=="crs" & r(te_nirs)==1
capture graphdea x=y, view(scale)
assert _rc==198
capture graphdea x=y, dmu(seq) focus(4) view(scale) rts(vrs)
assert _rc==198
capture graphdea x=y, dmu(seq) focus(4) view(scale) orientation(both)
assert _rc==198
* Even when SE displays as 1.000 the full-precision scores can imply DRS.
clear
input double(x y id)
1 1 1
2 1.999998 2
4 3 3
end
graphdea x=y, view(scale) model(te) dmu(id) focus(2)
assert "`r(rts)'"=="drs" & abs(r(se)-.999999)<1e-12

* A whole segment on the most productive ray has constant returns.
replace y = 2 in 2
replace y = 4 in 3
foreach direction in input output {
    graphdea x=y, view(scale) dmu(id) focus(2) orientation(`direction')
    assert "`r(rts)'"=="crs" & r(te_nirs)==1
}
di "scale checks passed"
