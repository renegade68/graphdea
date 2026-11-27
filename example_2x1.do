* Example for the installed graphdea command. Restores the current dataset.
version 16.0
args technology
local heading "Figure 2. Technical and allocative efficiency of DMU D"
local specification model(allocative) rts(vrs)
if "`technology'" == "vrs" local heading "Variable returns to scale"
if "`technology'" == "fdh" {
    local heading "Free disposal hull"
    local specification model(fdh)
}
local graphname dea_2x1
if "`technology'" == "compare" {
    local heading "Input requirements at fixed output"
    local specification compare(vrs fdh)
    local graphname dea_fdh_2x1
}
if !inlist("`technology'","","vrs","fdh","compare") exit 198
preserve
clear
input str1 firm double(labor capital output wage rent)
"A" 1 7 10 2 1
"B" 2 4 10 2 1
"E" 4 2 10 2 1
"F" 7 1 10 2 1
"D" 6 6 10 2 1
end
label variable labor "Labor (hours)"
label variable capital "Capital (machine-hours)"

graphdea labor capital = output, dmu(firm) focus("D") ///
    `specification' w(wage rent) view(isoquant) at(focus) ///
    title("{stSerif:`heading'}") ///
    name(`graphname', replace)
matrix list r(targets)
if "`technology'" == "compare" matrix list r(efficiency)
else display "TE = " %6.4f r(te) "    AE = " %6.4f r(ae) "    CE = " %6.4f r(ce)
restore
