version 16.0
clear
input str12 plant year double(labor machine units)
"North" 2023 2 8 4
"East"  2023 6 3 4
"South" 2023 5 6 4
"West site"  2023 5 5 3
"Old"   2023 4 4 4
"East"  2024 6 3 4
"New"   2024 1 8 4
"North" 2024 2 8 5
"West site"  2024 5 6 4
"South" 2024 5 5 4
"omit"  2024 1 1 50
"North" 2024 . 3 7
end
encode plant, gen(id)
quietly summarize id if plant=="West site", meanonly
local west = r(min)
local opts view(malmquist) time(year) dmu(plant) focus("West site")
datasignature set
graphdea units if plant!="omit", inputs(labor machine) `opts' orientation(input)
matrix din=r(distances)
matrix chart=r(ratio_targets)
assert r(N_base)==5 & r(N_followup)==5 & r(N)==10 & "`r(orientation)'"=="input"
matrix expected=(5/3,65/42 \ 4/3,31/24)
mata: assert(mreldif(st_matrix("din"),st_matrix("expected"))<1e-12)
matrix expected=(5/3,5/3,1,1,14/13,14/13 \ 1.25,1.5,15/16,9/8,30/31,36/31)
mata: assert(mreldif(st_matrix("chart"),st_matrix("expected"))<1e-12)
assert reldif(r(malmquist),1.223803845611936)<1e-12
foreach spec in "labor machine=units" "labor=machine units" {
    foreach dir in input output {
        local common time(year) dmu(id) orientation(`dir') decompose periods(2024 2023)
        graphdea `spec' in 1/10, model(malmquist) overview `common'
        matrix summary=r(overview)
        local row=rownumb(summary,"West_site")
        graphdea `spec' in 1/10, model(malmquist) focus(`west') `common' ///
            title("Two periods") xtitle("First ratio") ytitle("Second ratio")
        matrix d=r(distances)
        matrix p=r(ratio_targets)
        matrix e=r(period_efficiency)
        assert r(base)==2024 & r(followup)==2023 & "`r(technologies)'"=="crs vrs"
        local j=2
        foreach f in malmquist efficiency_change technical_change pure_efficiency_change scale_efficiency_change {
            local ++j
            assert reldif(r(`f'),summary[`row',`j'])<1e-12
        }
        forvalues obs=1/2 {
            forvalues tech=1/2 {
                local radial=d[`obs',`tech']
                if ("`spec'"=="labor machine=units")==("`dir'"=="input") local radial=1/`radial'
                assert reldif(p[`obs',2*`tech'+1],p[`obs',1]*`radial')<1e-12
                assert reldif(p[`obs',2*`tech'+2],p[`obs',2]*`radial')<1e-12
            }
            local vrs=e[`obs',1]
            if "`spec'"=="labor=machine units" local vrs=1/`vrs'
            assert reldif(p[`obs',7],p[`obs',1]*`vrs')<1e-12
            assert reldif(p[`obs',8],p[`obs',2]*`vrs')<1e-12
        }
    }
}
capture graphdea labor=machine units if year!=2024 | plant!="West site", `opts' periods(2023 2024)
assert _rc==459
datasignature confirm
* One peer per period and coincident own-period targets.
graphdea labor=machine units if plant=="West site", `opts' decompose
matrix d=r(distances)
assert r(N)==2 & abs(d[1,1]-1)<1e-12 & abs(d[2,2]-1)<1e-12
di "Two-period multidimensional frontier checks passed"
