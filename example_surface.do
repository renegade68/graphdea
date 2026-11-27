* Both examples preserve the active dataset. Run with graphdea installed.
* Optional arguments are azimuth and elevation in degrees: do example_surface.do 135 25
version 16.0
* Add sectionfill to shade the feasible section: do example_surface.do 135 25 sectionfill
* Add fdh to show the free disposal hull: do example_surface.do 135 25 sectionfill fdh
* Use just fdh as the third argument for the FDH wireframe.
args az el fill technology
if inlist("`fill'","crs","vrs","fdh") & "`technology'" == "" {
    local technology `fill'
    local fill
}
if !inlist("`technology'","","crs","vrs","fdh") exit 198
if "`technology'" == "" local technology vrs
local model rts(`technology')
if "`technology'" == "fdh" local model model(fdh)
if !inlist("`fill'","","sectionfill") {
    di as err "use sectionfill or a technology name after the angles"
    exit 198
}
if "`az'" != "" local camera azimuth(`az')
if "`el'" != "" local camera `camera' elevation(`el')
preserve
clear
input str1 firm double(labor capital output)
"A" 1 4 3
"B" 4 1 3
"C" 3 7 7
"E" 7 3 7
"F" 6 8 9
"G" 8 6 9
"D" 6 6 6
end
label var labor "Labor"
label var capital "Capital"
graphdea labor capital = output, view(surface) `camera' `fill' `model' dmu(firm) focus("D") ///
    title("{stSerif:Figure 4. Input requirements across output levels}") name(dea_surface_in, replace)
matrix list r(targets)

clear
input str1 firm double(hours good1 good2)
"A" 3 1 3
"B" 3 3 1
"C" 7 3 7
"E" 7 7 3
"F" 9 6 8
"G" 9 8 6
"D" 6 2 2
end
label var good1 "Product 1"
label var good2 "Product 2"
graphdea good1 good2, inputs(hours) view(surface) `camera' `fill' `model' dmu(firm) focus("D") ///
    title("{stSerif:Figure 5. Output possibilities across input levels}") name(dea_surface_out, replace)
matrix list r(targets)
restore
