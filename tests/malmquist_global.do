version 16.0
clear
input str12 clinic int year double(hours visits procedures)
"Harbor" 2022 10 40  8
"East"   2022 10 60  4
"West"   2022  8 16 16
"Harbor" 2023 10 48  9
"East"   2023 10 68  5
"West"   2023  8 20 16
"New"    2023 12 44 19
"Harbor" 2024 11 45 12
"East"   2024 10 65  6
"New"    2024  9 26 20
"Harbor" 2025 10 50 14
"East"   2025 10 70  5
"West"   2025  9 20 18
"omit"   2023  1 99 99
"Harbor" 2023  . 20 15
"Harbor" 2026 -1  1  1
end
local opts view(malmquist) chain dmu(clinic) time(year) focus(Harbor)
datasignature set
graphdea visits procedures in 1/13, inputs(hours) `opts' benchmark(global)
matrix levels=r(global_levels)
matrix links=r(chain)
matrix cum=r(cumulative)
local cols : colnames levels
assert "`cols'"=="period n_ref te_global te_period best_practice_ratio"
assert "`r(benchmark)'"=="global" & r(N)==13 & r(N_base)==3 & r(N_followup)==3 & r(N_periods)==4
assert reldif(levels[1,3],52/73)<1e-12 & abs(levels[4,3]-1)<1e-12
assert reldif(r(malmquist),73/52)<1e-12 & reldif(r(malmquist),levels[4,3]/levels[1,3])<1e-12
assert reldif(r(malmquist),r(efficiency_change)*r(best_practice_change))<1e-12
mata: assert(missing(st_matrix("links")[1,3..5]) & all(st_matrix("cum")[1,3..5]:==1))
foreach dir in input output {
    foreach spec in "hours=visits procedures" "hours visits=procedures" "hours=visits" {
        graphdea `spec' if clinic!="omit", `opts' benchmark(global) periods(2025 2023 2022) orientation(`dir') decompose
        matrix g=r(global_levels)
        matrix l=r(chain)
        matrix c=r(cumulative)
        assert r(N)==10 & r(base)==2025 & r(followup)==2022
        assert "`r(technologies)'"=="crs vrs" & "`r(orientation)'"=="`dir'"
        forvalues j=1/3 {
            assert reldif(g[`j',5],g[`j',3]/g[`j',4])<1e-12
            assert reldif(g[`j',7],g[`j',4]/g[`j',6])<1e-12
            forvalues k=3/7 {
                assert reldif(c[`j',`k'],g[`j',`k']/g[1,`k'])<1e-12
                if `j'>1 assert reldif(l[`j',`k'],g[`j',`k']/g[`j'-1,`k'])<1e-12
            }
        }
        graphdea `spec' if clinic!="omit", `opts' benchmark(contemporaneous) periods(2025 2023 2022) orientation(`dir') decompose
        assert "`r(benchmark)'"=="contemporaneous"
        assert reldif(r(efficiency_change),c[3,4])<1e-12 & reldif(r(pure_efficiency_change),c[3,6])<1e-12
        if "`spec'"=="hours=visits" assert reldif(r(malmquist),c[3,3])<1e-12
    }
}
capture graphdea hours=visits, view(malmquist) benchmark(global) time(year) dmu(clinic) focus(Harbor)
assert _rc==198
capture graphdea hours=visits, `opts' benchmark(other)
assert _rc==198
datasignature confirm

* A specialist observed only in the middle period changes the pooled frontier.
clear
input id year x a b
1 1 1 4 1
1 2 1 3 2
2 2 1 8 1
1 3 1 1 4
end
local opts view(malmquist) chain benchmark(global) dmu(id) focus(1) time(year)
graphdea x=a b, `opts'
matrix full=r(global_levels)
assert full[1,3]<1 & full[3,3]==1 & r(malmquist)>1
graphdea x=a b, `opts' periods(1 3)
assert reldif(r(malmquist),1)<1e-12 & r(N)==2
di "Global Malmquist checks passed"
