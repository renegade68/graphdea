version 16.0
clear
input str10 plant double(year hours units)
"A"          2023 4 4
"B"          2023 5 3
"North site" 2023 3 2
"A"          2024 4 5
"C"          2024 2 2
"North site" 2024 5 5
"North site" 2025 0 8
"exclude"    2023 1 15
""           2023 1 20
"North site" 2024 . 20
end
gen byte keepobs = plant!="exclude"
encode plant, gen(id)
quietly summarize id if plant=="North site", meanonly
local focusid = r(min)
datasignature set
graphdea units if keepobs, inputs(hours) model(malmquist) dmu(plant) focus("North site") ///
    time(year) periods(2023 2024)
assert r(N_base)==3 & r(N_followup)==3 & r(N)==6
assert r(base)==2023 & r(followup)==2024 & "`r(orientation)'"=="output" & "`r(technologies)'"=="crs"
assert abs(r(efficiency_change)-1.2)<1e-13 & abs(r(technical_change)-1.25)<1e-13
assert abs(r(malmquist)-1.5)<1e-13 & abs(r(malmquist)-r(efficiency_change)*r(technical_change))<1e-13
matrix actual=r(distances)
matrix expected=(2/3,8/15 \ 1,.8)
mata: assert(mreldif(st_matrix("actual"),st_matrix("expected"))<1e-13)
datasignature confirm
graphdea hours=units in 1/6, view(malmquist) dmu(id) focus(`focusid') time(year) rts(crs) orientation(output)
assert abs(r(malmquist)-1.5)<1e-13
graphdea hours=units in 1/6, view(malmquist) dmu(id) focus(`focusid') time(year) periods(2024 2023)
assert abs(r(malmquist)-2/3)<1e-13 & abs(r(technical_change)-.8)<1e-13
assert abs(r(efficiency_change)-1/1.2)<1e-13
capture graphdea hours=units, view(malmquist) dmu(id) focus(`focusid') time(year)
assert _rc==198
capture graphdea hours=units in 1/3, view(malmquist) dmu(id) focus(`focusid') time(year) periods(2023 2024)
assert _rc==459
capture graphdea hours=units in 1/6, view(malmquist) dmu(id) focus(`focusid') time(year) rts(vrs)
assert _rc==198
capture graphdea hours=units in 1/6, dmu(id) focus(`focusid') time(year)
assert _rc==198
replace units=10 if plant=="North site" & year==2024
graphdea hours=units in 1/6, view(malmquist) dmu(id) focus(`focusid') time(year)
matrix m=r(distances)
assert m[2,1]==2 & m[2,2]==1 & abs(r(malmquist)-3)<1e-13
replace hours=4*hours
replace units=2*units
graphdea hours=units in 1/6, view(malmquist) dmu(id) focus(`focusid') time(year)
matrix actual=r(distances)
mata: assert(mreldif(st_matrix("actual"),st_matrix("m"))<1e-13)
expand 2 if year==2024 & plant=="North site" & !missing(hours)
capture graphdea hours=units, view(malmquist) dmu(id) focus(`focusid') time(year) periods(2023 2024)
assert _rc==459
* A single unit in each period can determine both frontiers.
clear
input id double(month x y)
1 700 4 3
1 701 4 3
end
format month %tm
graphdea x=y, view(malmquist) dmu(id) focus(1) time(month) xtitle("Hours") title("Matched plant")
assert r(efficiency_change)==1 & r(technical_change)==1 & r(malmquist)==1
di "Malmquist checks passed"
