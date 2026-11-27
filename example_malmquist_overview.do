* Run with graphdea installed.
version 16.0
preserve
clear
input str12 plant int year double(hours units)
"North site" 2023 3 2
"South site" 2023 5 4
"West site"  2023 4 4
"East site"  2023 4 3
"Old site"   2023 2 2
"South site" 2024 5 3
"West site"  2024 4 4
"North site" 2024 5 5
"East site"  2024 4 3.6
"New site"   2024 4 5
end
graphdea hours = units, view(malmquist) overview time(year) periods(2023 2024) ///
    dmu(plant) name(dea_mpi_overview, replace)
matrix list r(overview)
restore
