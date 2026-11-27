* From this directory: do example_additive.do
* Give input saving twice the weight: do example_additive.do 2 1
version 16.0
args wx wy
if "`wx'`wy'" == "" {
    local wx 1
    local wy 1
}
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
graphdea hours = units, view(additive) dmu(plant) focus("D") ///
    compare(vrs fdh) slackweights(`wx' `wy') name(dea_additive, replace)
matrix list r(additive)
restore
