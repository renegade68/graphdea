version 16.0
clear
input str10 plant double(year hours units)
"A"          2022 4 4
"B"          2022 5 3
"E"          2022 2 1
"North site" 2022 3 2
"A"          2023 4 5
"C"          2023 2 2
"North site" 2023 5 5
"A"          2024 4 6
"C"          2024 2 2
"North site" 2024 5 4
"A"          2025 4 6
"E"          2025 2 2
"North site" 2025 5 6
"omit"       2025 1 30
"North site" 2025 . 12
"North site" 2026 -1 1
end
encode plant, gen(id)
quietly summarize id if plant=="North site", meanonly
local site=r(min)
datasignature set
graphdea units in 1/13, inputs(hours) model(malmquist) time(year) chain dmu(plant) focus("North site")
matrix l=r(chain)
matrix c=r(cumulative)
matrix expect=(2022,4,.,.,. \ 2023,3,1.5,1.2,1.25 \ 2024,3,.8,2/3,1.2 \ 2025,3,1.5,1.5,1)
mata: assert(mreldif(st_matrix("l"),st_matrix("expect"))<1e-12)
assert r(N)==13 & r(N_periods)==4 & r(N_base)==4 & r(N_followup)==3
assert r(base)==2022 & r(followup)==2025 & abs(r(malmquist)-1.8)<1e-12
matrix expect=(2022,4,1,1,1 \ 2023,3,1.5,1.2,1.25 \ 2024,3,1.2,.8,1.5 \ 2025,3,1.8,1.2,1.5)
mata: assert(mreldif(st_matrix("c"),st_matrix("expect"))<1e-12)
datasignature confirm
foreach dir in input output {
    graphdea hours=units if plant!="omit", view(malmquist) time(year) periods(2025 2023 2022) ///
        dmu(id) focus(`site') orientation(`dir') chain decompose
    matrix l=r(chain)
    matrix c=r(cumulative)
    local cols : colnames l
    assert "`cols'"=="period n_ref malmquist efficiency_change technical_change pure_efficiency_change scale_efficiency_change"
    assert r(N)==10 & r(N_periods)==3 & r(base)==2025 & r(followup)==2022 & "`r(orientation)'"=="`dir'"
    assert abs(r(malmquist)-1/1.8)<1e-12 & abs(r(pure_efficiency_change)*r(scale_efficiency_change)-r(efficiency_change))<1e-12
    forvalues j=2/3 {
        local a=l[`j'-1,1]
        local b=l[`j',1]
        graphdea hours=units if plant!="omit", view(malmquist) time(year) periods(`a' `b') ///
            dmu(id) focus(`site') orientation(`dir') decompose
        local col=2
        foreach v in malmquist efficiency_change technical_change pure_efficiency_change scale_efficiency_change {
            local ++col
            assert reldif(l[`j',`col'],r(`v'))<1e-12 & reldif(c[`j',`col'],c[`j'-1,`col']*l[`j',`col'])<1e-12
        }
    }
}
capture graphdea hours=units, chain
assert _rc==198
foreach bad in "2023 2023" "2022 2024 2023" {
    capture graphdea hours=units, view(malmquist) chain periods(`bad') time(year) dmu(id) focus(`site')
    assert _rc==198
}
capture graphdea hours=units, view(malmquist) periods(2022/2024) time(year) dmu(id) focus(`site')
assert _rc==198
capture graphdea hours=units, view(malmquist) chain periods(2022 2027) time(year) dmu(id) focus(`site')
assert _rc==459
capture graphdea hours=units if !(year==2024 & id==`site') in 1/13, view(malmquist) chain time(year) dmu(id) focus(`site')
assert _rc==459
expand 2 if year==2024 & id==`site'
capture graphdea hours=units if year<=2025, view(malmquist) chain time(year) dmu(id) focus(`site')
assert _rc==459
clear
input id month x y
1 702 1 2
1 700 1 1
end
format month %tm
graphdea x=y, view(malmquist) chain dmu(id) focus(1) time(month) xtitle("Month") ytitle("Index")
assert r(N_periods)==2 & r(malmquist)==2
di "Malmquist chain checks passed"
