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
"omit"       2023 1 20
"North site" 2024 . 10
end
encode plant, gen(id)
quietly summarize id if plant=="North site", meanonly
local site=r(min)
datasignature set
graphdea units if plant!="omit", inputs(hours) model(malmquist) time(year) periods(2023 2024) ///
    dmu(plant) focus("North site") orientation(input) decompose
assert r(N_base)==4 & r(N_followup)==3 & "`r(orientation)'"=="input"
matrix p=r(period_efficiency)
local names : colnames p
assert "`names'"=="x_observed x_vrs x_crs te_vrs te_crs scale_eff"
matrix expected=(3,8/3,2,8/9,2/3,.75 \ 5,4,4,.8,.8,1)
mata: assert(mreldif(st_matrix("p"),st_matrix("expected"))<1e-13)
matrix d=r(distances)
matrix expected=(1.5,15/8 \ 1,1.25)
mata: assert(mreldif(st_matrix("d"),st_matrix("expected"))<1e-13)
assert abs(r(efficiency_change)-1.2)<1e-13 & abs(r(technical_change)-1.25)<1e-13
assert abs(r(pure_efficiency_change)-.9)<1e-13 & abs(r(scale_efficiency_change)-4/3)<1e-13
assert abs(r(malmquist)-1.5)<1e-13
datasignature confirm
graphdea hours=units in 1/7, view(malmquist) time(year) dmu(id) focus(`site') orientation(input)
matrix plain=r(distances)
mata: assert(st_matrix("plain")==st_matrix("d"))
assert "`r(orientation)'"=="input" & "`r(technologies)'"=="crs"
graphdea hours=units in 1/7, view(malmquist) time(year) dmu(id) focus(`site') decompose
matrix out=r(distances)
mata: assert(mreldif(1:/st_matrix("out"),st_matrix("d"))<1e-13)
assert abs(r(pure_efficiency_change)-1.25)<1e-13 & abs(r(scale_efficiency_change)-.96)<1e-13
graphdea hours=units in 1/7, view(malmquist) time(year) periods(2024 2023) ///
    dmu(id) focus(`site') orientation(input) decompose
assert abs(r(pure_efficiency_change)-1/.9)<1e-13 & abs(r(scale_efficiency_change)-.75)<1e-13
assert abs(r(malmquist)-2/3)<1e-13
replace hours=2*hours
replace units=.5*units
graphdea hours=units in 1/7, view(malmquist) time(year) dmu(id) focus(`site') orientation(input) decompose
matrix scaled=r(period_efficiency)
mata: assert(mreldif(st_matrix("scaled"),st_matrix("p"):*(2,2,2,1,1,1))<1e-13)
capture graphdea hours=units in 1/7, view(malmquist) time(year) dmu(id) focus(`site') orientation(nonoriented)
assert _rc==198
* The other period's technology can give an input distance below one.
clear
input id year x y
1 1 2 4
1 2 2 8
end
graphdea x=y, view(malmquist) time(year) dmu(id) focus(1) orientation(input) decompose
matrix d=r(distances)
assert d[2,1]==.5 & d[1,2]==2 & r(malmquist)==2
assert r(pure_efficiency_change)==1 & r(scale_efficiency_change)==1
di "Input-oriented Malmquist checks passed"
