* Two inputs measured in hours and one output measured in units.
version 16.0
preserve
clear
input str12 plant int year double(labor machine units)
"North" 2023 2 8 4
"East"  2023 6 3 4
"South" 2023 5 6 4
"West"  2023 5 5 3
"Old"   2023 4 4 4
"East"  2024 6 3 4
"New"   2024 1 8 4
"North" 2024 2 8 5
"West"  2024 5 6 4
"South" 2024 5 5 4
end
graphdea labor machine = units, view(malmquist) overview dmu(plant) ///
    time(year) periods(2023 2024) orientation(input) name(dea_mpi_multi, replace)
matrix list r(overview)
restore
