* Run from the graphdea directory in Stata 16+.
version 16.0
clear
input str1 firm double(hours a b pa pb)
"A" 10 1 8 . .
"B" 10 3 7 . .
"C" 10 7 3 . .
"E" 10 8 1 . .
"D" 10 3 3 3 2
end
datasignature set
graphdea hours = a b, view(outputset) orientation(output) model(allocative) ///
    dmu(firm) focus("D") at(focus) rts(vrs) p(pa pb) show(pps radialout isorevenue revenuemax)
assert r(input)==10 & r(N)==5 & abs(r(phi)-5/3)<1e-12 & abs(r(te)-3/5)<1e-12
assert abs(r(ae)-25/27)<1e-12 & abs(r(re)-15/27)<1e-12 & abs(r(te)*r(ae)-r(re))<1e-12
matrix actual = r(targets)
matrix expected = (3,3,15 \ 5,5,25 \ 7,3,27)
mata: assert(max(abs(st_matrix("actual")-st_matrix("expected")))<1e-12)
datasignature confirm

* Every mix of B and C maximizes revenue at equal prices; select B.
replace pa = 2 in 5
graphdea a b, inputs(hours) dmu(firm) focus("D") p(pa pb) rts(vrs)
matrix actual = r(targets)
assert actual[3,1]==3 & actual[3,2]==7 & abs(r(re)-r(te))<1e-12
graphdea hours = a b if firm=="D", dmu(firm) focus("D") p(pa pb) rts(vrs)
assert r(phi)==1 & r(ae)==1 & r(re)==1

* Heterogeneous input: VRS frontier vertex at 10 mixes units at 5 and 15.
clear
input double(id x a b pa pb)
1  5  3 1 . .
2 15  7 5 . .
3 10  2 1 1 2
end
graphdea a b, inputs(x) at(x=10) dmu(id) focus(3) rts(vrs) p(pa pb)
matrix actual = r(targets)
assert abs(r(phi)-2.5)<1e-12 & abs(r(ae)-10/11)<1e-12 & abs(r(re)-4/11)<1e-12
assert abs(actual[2,1]-5)<1e-12 & abs(actual[2,2]-2.5)<1e-12
assert abs(actual[3,1]-5)<1e-12 & abs(actual[3,2]-3)<1e-12
graphdea x = a b, dmu(id) focus(3) rts(crs) p(pa pb)
assert abs(r(phi)-8/3)<1e-12 & abs(r(re)-6/17)<1e-12
graphdea x = a b in 2/3, dmu(id) focus(3) rts(vrs)
assert r(te)==1 & r(N)==2
graphdea x = a b, rts(vrs) at(x=7) show(frontier)
assert r(input)==7 & r(N)==3
capture graphdea x = a b, rts(vrs) at(x=4)
assert _rc==459
capture graphdea x = a b, orientation(input) at(x=10)
assert _rc==198
capture graphdea x = a b, at(x=10) w(pa pb)
assert _rc==198
capture graphdea x = a b, at(x=10) dmu(id) focus(3) model(allocative)
assert _rc==198
replace pb = 0 in 3
capture graphdea x = a b, dmu(id) focus(3) p(pa pb)
assert _rc==459
di "outputset checks passed"
