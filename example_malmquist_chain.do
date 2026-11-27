* Run with graphdea installed.
version 16.0
preserve
clear
input str1 plant int year double(hours units)
"A" 2022 4 4
"B" 2022 5 3
"E" 2022 2 1
"D" 2022 3 2
"A" 2023 4 5
"C" 2023 2 2
"D" 2023 5 5
"A" 2024 4 6
"C" 2024 2 2
"D" 2024 5 4
"A" 2025 4 6
"E" 2025 2 2
"D" 2025 5 6
end
label variable year "Year"
graphdea hours = units, view(malmquist) time(year) dmu(plant) focus("D") ///
    chain name(dea_mpi_chain, replace)
matrix list r(chain)
matrix list r(cumulative)
restore
