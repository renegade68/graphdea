version 16.0
clear
input str12 plant int year double(hours units)
"North site" 2023 3 2
"South site" 2023 5 4
"West site"  2023 4 4
"East site"  2023 4 3
"Old site"   2023 2 2
"South site" 2024 5 3
"West site"  2024 4 4
"North site" 2024 5 5
"East site"  2024 4 3.6
"New site"   2024 4 5
"omit"       2024 1 50
"North site" 2024 . 10
"Old site"   2025 -1 4
end
local pair time(year) periods(2023 2024) dmu(plant)
datasignature set
graphdea units if plant!="omit", inputs(hours) model(malmquist) overview `pair'
matrix allrows=r(overview)
assert r(N_matched)==4 & r(N_shown)==4 & r(N_base)==5 & r(N_followup)==5 & r(N)==10
assert r(base)==2023 & r(followup)==2024 & abs(r(technical_change)-1.25)<1e-12
assert "`r(orientation)'"=="output" & "`r(technologies)'"=="crs" & "`r(dmu)'"=="plant"
matrix expected=(1,8,1.5,1.2,1.25 \ 4,9,1.2,.96,1.25 \ 3,7,1,.8,1.25 \ 2,6,.75,.6,1.25)
mata: assert(mreldif(st_matrix("allrows"),st_matrix("expected"))<1e-12)
foreach dir in input output {
    graphdea hours=units if plant!="omit", view(malmquist) overview `pair' orientation(`dir') decompose top(2)
    matrix scores=r(overview)
    assert r(N_matched)==4 & r(N_shown)==2 & rowsof(scores)==4
    local cols : colnames scores
    assert "`cols'"=="base_obs followup_obs malmquist efficiency_change technical_change pure_efficiency_change scale_efficiency_change"
    assert "`r(technologies)'"=="crs vrs" & "`r(orientation)'"=="`dir'"
    forvalues i=1/4 {
        local id = plant[scores[`i',1]]
        graphdea hours=units if plant!="omit", view(malmquist) focus("`id'") `pair' orientation(`dir') decompose
        local col=2
        foreach v in malmquist efficiency_change technical_change pure_efficiency_change scale_efficiency_change {
            local ++col
            assert reldif(scores[`i',`col'],r(`v'))<1e-12
        }
    }
}
graphdea hours=units in 1/10, view(malmquist) overview time(year) periods(2024 2023) dmu(plant)
matrix rev=r(overview)
forvalues i=1/4 {
    local j=5-`i'
    assert rev[`i',1]==allrows[`j',2] & rev[`i',2]==allrows[`j',1]
    forvalues k=3/5 {
        assert reldif(rev[`i',`k'],1/allrows[`j',`k'])<1e-12
    }
}
foreach bad in "chain" "focus(Old)" {
    capture graphdea hours=units, view(malmquist) overview `pair' `bad'
    assert _rc==198
}
capture graphdea hours=units, view(malmquist) overview `pair' top(0)
assert _rc==125
capture graphdea hours=units, top(1)
assert _rc==198
capture graphdea hours=units if inlist(plant,"Old site","New site"), view(malmquist) overview `pair'
assert _rc==459
datasignature confirm
expand 2 if plant=="New site"
capture graphdea hours=units, view(malmquist) overview `pair'
assert _rc==459
clear
input id t x y
1 1 2 3
1 2 2 3
2 1 3 4
2 2 3 4
end
label define plants 1 "Alpha"
label values id plants
graphdea x=y, view(malmquist) overview dmu(id) time(t) top(1) decompose
matrix tied=r(overview)
assert r(N_shown)==1 & r(N_matched)==2 & tied[1,1]==1 & tied[2,1]==3
gen strL site="Plant "+string(id)
graphdea x=y if id==2, view(malmquist) overview dmu(site) time(t) top(10)
assert r(N_shown)==1 & r(N_matched)==1 & r(technical_change)==1
di "Malmquist overview checks passed"
