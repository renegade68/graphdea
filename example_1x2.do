* Example for the installed graphdea command. Restores the current dataset.
version 16.0
args technology
local heading "Figure 3. Output expansion and revenue efficiency of DMU D"
local specification model(allocative) rts(vrs)
if "`technology'" == "vrs" local heading "Variable returns to scale"
if "`technology'" == "fdh" {
    local heading "Free disposal hull"
    local specification model(fdh)
}
local graphname dea_1x2
local prices p(price1 price2)
if "`technology'" == "compare" {
    local heading "Output possibilities at fixed input"
    local specification compare(vrs fdh)
    local graphname dea_fdh_1x2
}
if "`technology'" == "slacks" {
    local heading "Output slack after radial expansion"
    local specification compare(vrs fdh) show(pps frontier radial slacks)
    local prices
    local graphname dea_output_slacks
}
if !inlist("`technology'","","vrs","fdh","compare","slacks") exit 198
preserve
clear
input str1 firm double(hours good1 good2 price1 price2)
"A" 10 1 8 3 2
"B" 10 3 7 3 2
"C" 10 7 3 3 2
"E" 10 8 1 3 2
"D" 10 3 3 3 2
end
label variable good1 "Product 1 (units)"
label variable good2 "Product 2 (units)"

graphdea hours = good1 good2, dmu(firm) focus("D") view(outputset) at(focus) ///
    `specification' orientation(output) `prices' ///
    title("{stSerif:`heading'}") ///
    name(`graphname', replace)
matrix list r(targets)
if "`technology'" == "slacks" matrix list r(slacks)
if inlist("`technology'","compare","slacks") matrix list r(efficiency)
else display "phi = " %6.4f r(phi) "    TE = " %6.4f r(te) ///
    "    AE = " %6.4f r(ae) "    RE = " %6.4f r(re)
restore
