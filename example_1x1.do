* Example for the installed graphdea command. Restores the current dataset.
version 16.0

preserve
clear
input str1 id double(x y)
"A" 2 2
"B" 4 6
"C" 8 8
"D" 6 4
end
label variable x "Input"
label variable y "Output"

graphdea x = y, dmu(id) focus("D") compare(crs vrs fdh) ///
    show(pps frontier radialin radialout) name(dea_1x1, replace) ///
    title("{stSerif:Figure 1. Input and output projections for DMU D}") ///
    xtitle("Input ({it:x})") ytitle("Output ({it:y})")
matrix list r(projections)
restore
