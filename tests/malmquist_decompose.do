version 16.0
clear
input str10 plant double(year hours units)
"E"          2023 2 1
"A"          2024 4 5
"B"          2023 5 3
"North site" 2024 5 5
"A"          2023 4 4
"C"          2024 2 2
"North site" 2023 3 2
"North site" 2025 0 9
"ignore"     2023 3 15
"North site" 2024 . 80
end
encode plant, gen(id)
quietly summarize id if plant=="North site", meanonly
local site=r(min)
datasignature set
graphdea units if plant!="ignore", inputs(hours) model(malmquist) decompose ///
    time(year) periods(2023 2024) dmu(plant) focus("North site")
assert r(N_base)==4 & r(N_followup)==3 & "`r(technologies)'"=="crs vrs"
matrix p=r(period_efficiency)
matrix distances=r(distances)
local rows : rownames p
local cols : colnames p
assert "`rows'"=="base followup" & "`cols'"=="y_observed y_vrs y_crs te_vrs te_crs scale_eff"
matrix expected=(2,2.5,3,.8,2/3,5/6 \ 5,5,6.25,1,.8,.8)
mata: assert(mreldif(st_matrix("p"),st_matrix("expected"))<1e-14)
assert abs(r(pure_efficiency_change)-1.25)<1e-13 & abs(r(scale_efficiency_change)-.96)<1e-13
assert abs(r(efficiency_change)-r(pure_efficiency_change)*r(scale_efficiency_change))<1e-13
assert abs(r(malmquist)-r(efficiency_change)*r(technical_change))<1e-13
datasignature confirm
graphdea hours=units in 1/7, view(malmquist) dmu(id) focus(`site') time(year)
matrix plain=r(distances)
mata: assert(st_matrix("plain")==st_matrix("distances"))
assert "`r(technologies)'"=="crs"
graphdea hours=units in 1/7, view(malmquist) decompose dmu(id) focus(`site') time(year) periods(2024 2023)
assert abs(r(pure_efficiency_change)-1/1.25)<1e-13 & abs(r(scale_efficiency_change)-1/.96)<1e-13
replace hours=2*hours
replace units=units/2
graphdea hours=units in 1/7, view(malmquist) decompose dmu(id) focus(`site') time(year)
matrix scaled=r(period_efficiency)
mata: assert(mreldif(st_matrix("scaled"),st_matrix("expected"):*(.5,.5,.5,1,1,1))<1e-13)
capture graphdea hours=units in 1/7, decompose
assert _rc==198
* A single observed scale per period; VRS and CRS targets coincide.
clear
input id year x y
1 1 3 2
1 2 5 5
end
graphdea x=y, view(malmquist) decompose dmu(id) focus(1) time(year)
assert r(pure_efficiency_change)==1 & r(scale_efficiency_change)==1
assert abs(r(malmquist)-1.5)<1e-13
di "Malmquist decomposition checks passed"
