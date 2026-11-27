* Run from the graphdea directory. Start Stata afresh to also exercise ado discovery.
version 16.0
clear
input str1 firm double(labor capital output wage rent)
"A" 1 7 10 . .
"B" 2 4 10 . .
"E" 4 2 10 . .
"F" 7 1 10 . .
"D" 6 6 10 2 1
end
datasignature set
graphdea labor capital = output, dmu(firm) focus("D") w(wage rent) rts(vrs) ///
    at(focus) show(radial isocost costmin) model(allocative) name(farrell, replace)
assert r(N) == 5 & r(output) == 10
assert reldif(r(te),1/2)<1e-14 & reldif(r(ae),8/9)<1e-14 & reldif(r(ce),4/9)<1e-14
matrix targets = r(targets)
matrix expected = (6,6,18 \ 3,3,9 \ 2,4,8)
mata: assert(max(abs(st_matrix("targets")-st_matrix("expected")))<1e-13)
datasignature confirm

* Prices only affect allocative efficiency. Tied cost optima select the left vertex.
replace wage = 1 in 5
graphdea output, inputs(labor capital) dmu(firm) focus("D") w(wage rent) rts(vrs)
matrix targets = r(targets)
assert r(te) == .5 & r(ae) == 1 & targets[3,1] == 2

* Cross-section at 10 needs a convex combination of units at outputs 5 and 15.
clear
input double(x1 x2 y id p1 p2)
1 1 5  1 . .
5 3 15 2 . .
6 6 10 3 2 1
end
graphdea y, inputs(x1 x2) dmu(id) focus(3) rts(vrs) w(p1 p2) at(y=10)
matrix targets = r(targets)
assert abs(r(te)-.5)<1e-12 & abs(r(ae)-8/9)<1e-12
assert targets[2,1]==3 & targets[2,2]==3 & targets[3,1]==3 & targets[3,2]==2
* Multiple observations above the slice contribute a column of mixing fractions.
quietly set obs 5
foreach v in x1 x2 {
    quietly replace `v' = 40 in 4/5
}
quietly replace y = 14 in 4
quietly replace y = 12 in 5
graphdea y, inputs(x1 x2) rts(vrs) dmu(id) focus(3) w(p1 p2)
assert abs(r(te)-.5)<1e-12 & abs(r(ce)-4/9)<1e-12
quietly drop in 4/5
graphdea x1 x2 = y if id != 2, dmu(id) focus(3) rts(vrs) w(p1 p2)
assert r(te)==1 & r(ce)==1
graphdea x1 x2 = y, dmu(id) focus(3) rts(crs) w(p1 p2)
assert abs(r(te)-1/3)<1e-12 & abs(r(ce)-1/3)<1e-12
matrix targets = r(targets)
assert targets[3,1]==2 & targets[3,2]==2
graphdea y, inputs(x1 x2) view(isoquant) rts(vrs) at(y=12)
assert r(output)==12 & r(N)==3
capture graphdea y, inputs(x1 x2) rts(vrs) at(y=16)
assert _rc==459
capture graphdea y, inputs(x1 x2) dmu(id) focus(3) at(y=11)
assert _rc==198
capture graphdea y, inputs(x1 x2) dmu(id) focus(3) model(allocative)
assert _rc==198
replace p1 = 0 in 3
capture graphdea y, inputs(x1 x2) dmu(id) focus(3) w(p1 p2)
assert _rc==459
di "isoquant checks passed"
