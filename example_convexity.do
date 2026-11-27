* From this directory: do example_convexity.do
* To see an FDH-feasible mixture of the same pair: do example_convexity.do .5
version 16.0
args share
if "`share'" == "" local share .75
preserve
clear
input str1 plant double(hours output)
"A" 2 2
"B" 4 6
"C" 8 8
"D" 6 4
end
label variable hours "Labor input (hours)"
label variable output "Output (units)"
graphdea hours = output, view(convexity) dmu(plant) pair(A C) share(`share') ///
    name(dea_convexity, replace)
matrix list r(mixture)
restore
