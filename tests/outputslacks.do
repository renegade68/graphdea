version 16.0
clear
input int(plant year) double(budget units parts p1 p2)
11 2024 10  1 8 . .
12 2024 10  3 7 . .
13 2024 10  7 3 . .
14 2024 10  8 1 . .
15 2024 10  3 3 3 2
16 2024 11  9 9 . .
17 2022  5 90 90 . .
18 2024  . 99 99 . .
19 2024  5 80 80 . .
end
datasignature set
graphdea units parts if year==2024 in 1/8, inputs(budget) dmu(plant) focus(15) ///
    compare(fdh vrs) p(p1 p2) show(pps slacks revenuemax)
matrix s = r(slacks)
matrix expected = (3,3,7,3,4,0 \ 3,3,3,7,0,4)
* VRS can mix the higher-budget unit with a cheaper unit only when one exists.
matrix expected = expected \ (5,5,5,5,0,0)
mata: assert(mreldif(st_matrix("s"),st_matrix("expected"))<1e-13)
local names : rowfullnames s
assert "`names'"=="fdh:more1 fdh:more2 vrs:radial"
assert r(N)==6 & "`r(outputs)'"=="units parts" & r(input)==10
capture graphdea budget=units parts, model(fdh) at(budget=10) show(slacks)
assert _rc==198
capture graphdea units parts=budget, model(fdh) dmu(plant) focus(15) show(slacks)
assert _rc==198
datasignature confirm

* Weak radial target after expansion, with an actual mixed VRS vertex and units of different sizes.
clear
input str10 site double(hours product shipments)
"Small"      5  4 2000
"Large"     15  8 2000
"North Hub" 10  1 1000
end
graphdea hours=product shipments, dmu(site) focus("North Hub") compare(crs vrs fdh) show(slacks)
matrix s = r(slacks)
matrix expected = (4,4000,8,4000,4,0 \ 2,2000,6,2000,4,0 \ 2,2000,4,2000,2,0)
mata: assert(mreldif(st_matrix("s"),st_matrix("expected"))<1e-12)
graphdea shipments product, inputs(hours) dmu(site) focus("North Hub") model(fdh) show(slacks)
matrix s = r(slacks)
assert s[1,5]==0 & s[1,6]==2
graphdea hours=product shipments if site=="North Hub", model(fdh) dmu(site) focus("North Hub") show(slacks)
matrix s = r(slacks)
assert rowsof(s)==1 & s[1,5]==0 & s[1,6]==0
graphdea hours=product shipments, view(surface) rts(vrs) dmu(site) focus("North Hub") show(slacks)
matrix s = r(slacks)
assert abs(s[1,5]-4)<1e-12 & s[1,6]==0

* Exact tie in original data can round differently on separately normalized axes.
clear
input double(id x a b)
1 1 29 9
2 1 12 14
3 1 4  3
end
graphdea x=a b, model(fdh) dmu(id) focus(3) show(slacks)
matrix s = r(slacks)
matrix expected = (12,9,29,9,17,0 \ 12,9,12,14,0,5)
mata: assert(all(st_matrix("s"):==st_matrix("expected")))
graphdea x=a b, model(fdh) dmu(id) focus(3)
mata: assert(rows(st_matrix("r(slacks)"))==0)
di "Output slack checks passed"
