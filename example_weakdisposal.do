* From this directory: do example_weakdisposal.do
* To test keeping D's full output after halving emissions: do example_weakdisposal.do 3 8
version 16.0
args emissions goods
if "`emissions'`goods'" == "" {
    local emissions 3
    local goods 6
}
preserve
clear
input str1 plant double(hours emissions units)
"A" 10 2 5
"B" 10 4 7
"D" 10 6 8
"E" 10 8 5
end
label variable emissions "Emissions (tonnes)"
label variable units "Desirable output (units)"
graphdea hours = units, bad(emissions) view(weakdisposal) rts(vrs) ///
    dmu(plant) focus("D") plan(`emissions' `goods') name(dea_weakdisposal, replace)
matrix list r(plan)
matrix list r(frontier)
restore
