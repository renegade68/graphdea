* Run with graphdea installed.
version 16.0
preserve
clear
input str1 plant int year double(hours units)
"A" 2023 4 4
"B" 2023 5 3
"D" 2023 3 2
"A" 2024 4 5
"C" 2024 2 2
"D" 2024 5 5
end
label variable hours "Labor input (hours)"
label variable units "Desirable output (units)"
graphdea hours = units, view(malmquist) dmu(plant) focus("D") ///
    time(year) periods(2023 2024) name(dea_malmquist, replace)
matrix list r(distances)
return list
restore
