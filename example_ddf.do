* With graphdea installed, run: do example_ddf.do
version 16.0
preserve
clear
input str1 id double(hours output)
"A" 2 2
"B" 4 6
"C" 8 8
"D" 6 4
end
label variable hours "Labor input (hours)"
label variable output "Output (units)"
graphdea hours = output, view(ddf) rts(vrs) dmu(id) focus("D") gx(1) gy(1) ///
    show(pps frontier radialin radialout) name(dea_ddf, replace) ///
    title("{stSerif:Radial and directional targets for DMU D}")
matrix list r(ddf)
matrix list r(projections)
restore
