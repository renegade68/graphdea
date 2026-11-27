* Run do example_peers.do or do example_peers.do output from the examples directory.
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
graphdea x = y, dmu(id) focus("D") compare(crs vrs fdh) ///
    orientation(`direction') show(pps frontier radial lambda slacks) ///
    title("{stSerif:Reference units and slack for DMU D}") name(dea_peers, replace)
matrix list r(peers)
matrix list r(benchmarks)
restore
