* Run do example_weights.do or do example_weights.do output from the examples directory.
version 16.0
args direction
if "`direction'" == "" local direction input
preserve
clear
input str1 id double(x y)
"A" 2 2
"B" 4 6
"C" 8 8
"D" 6 4
end
label variable x "Input"
label variable y "Output"
graphdea x = y, dmu(id) focus("D") compare(crs vrs) ///
    orientation(`direction') show(pps frontier radial weights) ///
    title("{stSerif:Multiplier weights at the radial target of DMU D}") name(dea_weights, replace)
matrix list r(multipliers)
restore
