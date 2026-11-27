* Run do example_scale.do input or do example_scale.do output from this directory.
* Optionally give the focus DMU, for example: do example_scale.do input B
version 16.0
args direction unit
if "`direction'" == "" local direction input
if "`unit'" == "" local unit D
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
graphdea x = y, view(scale) dmu(id) focus("`unit'") orientation(`direction') ///
    title("{stSerif:Scale efficiency of DMU `unit'}") name(dea_scale, replace)
display "Scale efficiency = " %6.4f r(se)
display "Returns at the VRS target = " upper("`r(rts)'")
display "NIRS technical efficiency = " %6.4f r(te_nirs)
matrix list r(projections)
restore
