* Run with graphdea installed. Both panels evaluate plant D under FDH.
version 16.0
preserve
clear
input str1 plant double(hours units)
"A" 2 4
"B" 4 6
"C" 7 7
"D" 6 3
end
label variable hours "Labor input (hours)"
label variable units "Desirable output (units)"
foreach direction in input output {
    graphdea hours = units, view(sbm) model(fdh) dmu(plant) focus("D") ///
        orientation(`direction') title("`=proper("`direction'")' orientation") ///
        name(dea_sbm_`direction', replace)
    matrix list r(sbm)
}
graph combine dea_sbm_input dea_sbm_output, cols(2) xcommon ycommon ///
    title("{stSerif:Slacks-based efficiency of plant D}", position(11) span) ///
    xsize(10) ysize(6.5) scheme(s1mono) name(dea_sbm_oriented, replace)
restore
