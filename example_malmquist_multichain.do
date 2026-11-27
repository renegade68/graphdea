* Follow one clinic through four annual frontiers using one input and two outputs.
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
graphdea hours = visits procedures, view(malmquist) chain dmu(clinic) ///
    focus(Harbor) time(year) orientation(output) name(dea_clinic_chain, replace)
matrix list r(chain)
matrix list r(cumulative)
* The three annual links give 1.4148 in 2025. Adding periods(2022 2025)
* to the command evaluates only the two endpoints and gives 1.4102.
restore
