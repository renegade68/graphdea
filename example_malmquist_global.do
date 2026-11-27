* Compare one clinic over time using a CRS frontier pooled over four years.
version 16.0
preserve
clear
input str12 clinic int year double(hours visits procedures)
"Harbor" 2022 10 40  8
"East"   2022 10 60  4
"West"   2022  8 16 16
"Harbor" 2023 10 48  9
"East"   2023 10 68  5
"West"   2023  8 20 16
"New"    2023 12 44 19
"Harbor" 2024 11 45 12
"East"   2024 10 65  6
"New"    2024  9 26 20
"Harbor" 2025 10 50 14
"East"   2025 10 70  5
"West"   2025  9 20 18
end
label variable year "Year"
graphdea hours = visits procedures, view(malmquist) chain benchmark(global) dmu(clinic) ///
    focus(Harbor) time(year) orientation(output) name(dea_global, replace)
* te_global in the final row divided by te_global in the first row
* equals the final cumulative index on this four-year reference.
matrix list r(global_levels)
matrix list r(chain)
matrix list r(cumulative)
restore
