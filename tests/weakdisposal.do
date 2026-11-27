version 16.0
clear
input str10 plant double(hours emissions units)
"A"          10 2 5
"B"          10 4 7
"North site" 10 6 8
"E"          10 8 5
"North site" 10 3 99
"omit"       10 . 42
end
gen id = _n
datasignature set
graphdea units if id!=5, inputs(hours) bad(emissions) dmu(plant) focus("North site") plan(3 6)
assert r(N)==4 & r(input)==10 & "`r(technologies)'"=="vrs"
assert "`r(bad)'"=="emissions" & "`r(good)'"=="units"
matrix h = r(frontier)
matrix expected = (0,0 \ 2,5 \ 4,7 \ 6,8 \ 8,5)
mata: assert(mreldif(st_matrix("h"),st_matrix("expected"))<1e-14)
matrix p = r(plan)
assert p[1,3]==6 & p[1,4]==1 & p[1,5]==4
datasignature confirm
graphdea hours=units in 1/4, bad(emissions) at(hours=10) plan(7 7)
matrix p = r(plan)
assert p[1,3]==6.5 & p[1,4]==0
graphdea hours=units in 1/4, bad(emissions) at(hours=10) plan(9 0)
matrix p = r(plan)
assert missing(p[1,3]) & p[1,4]==0

* Only an idle low-input DMU mixed with the active high-input DMU
* can attain the low-emissions frontier in this VRS slice.
clear
input double(x b y)
2 10  2
6  2 10
4  8  1
end
gen id = _n
graphdea x=y, view(weakdisposal) bad(b) rts(vrs) at(x=4) plan(1 5)
matrix p = r(plan)
assert p[1,3]==5 & p[1,4]==1
graphdea x=y, bad(b) rts(crs) at(x=1) plan(.25 1.25)
matrix p = r(plan)
assert reldif(p[1,3],1.25)<1e-14 & p[1,4]==1
capture graphdea x=y, bad(b) at(x=1)
assert _rc==459
capture graphdea x=y, bad(b) model(fdh) at(x=4)
assert _rc==198
capture graphdea x=y, bad(x) at(x=4)
assert _rc==198
capture graphdea x=y, bad(b) at(x=4) show(contraction)
assert _rc==198
capture graphdea x=y, bad(b) at(x=4) plan(0 .)
assert _rc!=0
* Clean production at zero emissions, ties, and a degenerate all-zero slice.
replace b=0
graphdea x=y, bad(b) at(x=6) plan(0 10)
matrix h=r(frontier)
matrix p=r(plan)
assert rowsof(h)==1 & h[1,1]==0 & h[1,2]==10 & p[1,4]==1
replace y=0
graphdea x=y in 1, bad(b) dmu(id) focus(1) plan(0 0)
matrix p=r(plan)
assert p[1,3]==0 & p[1,4]==1
replace b=-1 in 1
capture graphdea x=y, bad(b) at(x=4)
assert _rc==459
di "weak disposal checks passed"
