* Run with graphdea installed.
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
graphdea hours = units, view(super) dmu(plant) focus("B") ///
    compare(vrs fdh) orientation(input) name(dea_super, replace) ///
    title("{stSerif:Input-oriented super-efficiency of plant B}")
matrix list r(super)
restore
