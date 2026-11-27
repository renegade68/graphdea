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
"omit"   2024  1 99 99
"Harbor" 2023  . 20 15
"Harbor" 2026 -1  1  1
end
encode clinic, gen(id)
quietly summarize id if clinic=="Harbor", meanonly
local harbor=r(min)
local opts view(malmquist) chain time(year) dmu(clinic) focus(Harbor)
datasignature set
graphdea hours=visits procedures in 1/13, `opts'
matrix chain=r(chain)
matrix cum=r(cumulative)
assert r(N)==13 & r(N_periods)==4 & r(N_base)==3 & r(N_followup)==3
assert r(base)==2022 & r(followup)==2025 & "`r(orientation)'"=="output" & "`r(technologies)'"=="crs"
assert missing(chain[1,3]) & cum[1,3]==1 & reldif(r(malmquist),1.4147814)<1e-7
assert reldif(cum[4,3],chain[2,3]*chain[3,3]*chain[4,3])<1e-12
graphdea hours=visits procedures in 1/13, `opts' periods(2022 2025)
assert abs(cum[4,3]-r(malmquist))>1e-4

* Compare every link and component to the matched row of the two-period overview.
* Both orientations, a skipped year, descending order, numeric IDs, and sample filters.
foreach spec in "hours=visits procedures" "hours visits=procedures" {
    foreach dir in input output {
        local common time(year) dmu(id) orientation(`dir') decompose
        graphdea `spec' if clinic!="omit", model(malmquist) chain focus(`harbor') ///
            `common' periods(2025 2024 2022)
        matrix links=r(chain)
        matrix cum=r(cumulative)
        assert r(N)==9 & r(base)==2025 & r(followup)==2022 & r(N_periods)==3
        assert "`r(technologies)'"=="crs vrs" & reldif(r(malmquist),cum[3,3])<1e-12
        forvalues j=2/3 {
            local a=links[`j'-1,1]
            local b=links[`j',1]
            graphdea `spec' if clinic!="omit", view(malmquist) overview `common' periods(`a' `b')
            matrix pair=r(overview)
            local row=rownumb(pair,"Harbor")
            forvalues col=3/7 {
                assert reldif(links[`j',`col'],pair[`row',`col'])<1e-11
                assert reldif(cum[`j',`col'],cum[`j'-1,`col']*links[`j',`col'])<1e-11
            }
        }
    }
}
graphdea visits procedures in 1/13, inputs(hours) `opts' periods(2025 2024 2023 2022)
assert reldif(r(malmquist),1/1.4147814)<1e-7
capture graphdea hours=visits procedures if !(year==2024 & clinic=="Harbor") in 1/13, `opts'
assert _rc==459
datasignature confirm
di "Multidimensional Malmquist chain checks passed"
