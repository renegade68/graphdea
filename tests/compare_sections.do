* Run from the project directory in a fresh Stata session.
version 16.0
clear
input long(branch survey) double(hours phones routers unitp unitt)
10 2022 0 100 100 . .
21 2024 1 4 1 . .
22 2024 4 1 8 . .
23 2024 8 12 10 . .
24 2024 6 2 2 3 2
25 2024 . 999 999 . .
26 2024 3 999 999 . .
end
gen str16 site = "North Plant" if branch==24
label variable phones "Handsets shipped"
label var routers "Routers shipped"
datasignature set
graphdea phones routers if survey==2024 in 1/6, inputs(hours) dmu(site) focus("North Plant") ///
    compare(fdh crs vrs) p(unitp unitt) name(factory, replace)
assert r(N)==4 & r(input)==6 & "`r(technologies)'"=="fdh crs vrs"
matrix summary = r(efficiency)
matrix stacked = r(targets)
matrix axes = r(axes)
assert rowsof(summary)==3 & colsof(summary)==4 & rowsof(stacked)==9
assert axes[1,1]>=24 & axes[1,1]<100 & axes[2,1]>=12
local i=0
foreach tech in fdh crs vrs {
    local ++i
    local spec rts(`tech')
    if "`tech'"=="fdh" local spec model(fdh)
    graphdea hours = phones routers if survey==2024 in 1/6, dmu(branch) focus(24) `spec' p(unitp unitt)
    assert abs(summary[`i',1]-r(te))<1e-12 & abs(summary[`i',2]-r(phi))<1e-12
    assert abs(summary[`i',3]-r(ae))<1e-12 & abs(summary[`i',4]-r(re))<1e-12
    matrix one=r(targets)
    mata: assert(mreldif(st_matrix("one"),st_matrix("stacked")[((`i'-1)*3+1)..(`i'*3),.])<1e-12)
}
local groups : roweq stacked
assert "`groups'"=="fdh fdh fdh crs crs crs vrs vrs vrs"
graphdea phones routers = hours if survey==2024 in 1/6, compare(vrs fdh) dmu(branch) focus(24) w(unitp unitt)
assert r(output)==6 & r(N)==4
matrix summary=r(efficiency)
local names : colnames summary
assert "`names'"=="te ae ce"
graphdea hours = phones routers in 2/4, compare(vrs fdh) at(hours=4) show(frontier)
assert r(input)==4 & r(N)==3
mata: assert(rows(st_matrix("r(efficiency)"))==0)
graphdea phones routers = hours if branch==24, compare(fdh) dmu(branch) focus(24)
matrix summary=r(efficiency)
assert summary[1,1]==1 & colsof(summary)==1
capture graphdea hours = phones routers in 2/4, compare(crs vrs) at(hours=.5)
assert _rc==459
capture graphdea hours = phones routers in 2/4, compare(vrs vrs) at(hours=4)
assert _rc==198
capture graphdea hours = phones routers in 2/4, compare(vrs fdh) at(hours=4) rts(crs)
assert _rc==198
capture graphdea hours = phones routers in 2/4, compare(vrs fdh) at(hours=4) view(surface)
assert _rc==198
datasignature confirm
di "Section comparison checks passed"
