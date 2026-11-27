* Run with graphdea installed. Uses the data from example_additive.do.
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
graphdea hours = units, view(sbm) dmu(plant) focus("D") ///
    compare(vrs crs) name(dea_sbm, replace)
matrix list r(sbm)
restore
