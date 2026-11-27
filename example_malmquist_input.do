* Run with graphdea installed.
version 16.0
preserve
clear
input str1 plant int year double(hours units)
"A" 2023 4 4
"B" 2023 5 3
"E" 2023 2 1
"D" 2023 3 2
"A" 2024 4 5
"C" 2024 2 2
"D" 2024 5 5
end
label variable hours "Labor input (hours)"
label variable units "Desirable output (units)"
graphdea hours = units, view(malmquist) dmu(plant) focus("D") ///
    time(year) periods(2023 2024) orientation(input) decompose name(dea_mpi_input, replace)
matrix list r(period_efficiency)
display r(pure_efficiency_change) * r(scale_efficiency_change) * r(technical_change)
restore
