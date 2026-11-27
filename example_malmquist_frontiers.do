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
label variable labor "Labor hours"
label variable machine "Machine hours"
label variable units "Units produced"
graphdea labor machine = units, view(malmquist) dmu(plant) focus(West) ///
    time(year) periods(2023 2024) orientation(input) name(dea_mpi_pair, replace)
matrix list r(distances)
matrix list r(ratio_targets)

* One input and two outputs. Overlay the own-period VRS target as a diamond.
clear
input str12 clinic int year double(hours initial followup)
"Harbor" 2023 10 18 12
"East"   2023 12 36  8
"West"   2023  8  8 24
"Harbor" 2024  9 20 13
"East"   2024 12 40  7
"West"   2024  8 12 22
end
label variable hours "Clinician hours"
label variable initial "Initial visits"
label variable followup "Follow-up visits"
graphdea hours = initial followup, view(malmquist) dmu(clinic) focus(Harbor) ///
    time(year) periods(2023 2024) orientation(output) decompose name(dea_clinic_pair, replace)
matrix list r(period_efficiency)
restore
