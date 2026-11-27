version 16.0
clear
input str6 plant year double(labor machine units)
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
"omit"  2024 1 1 50
"North" 2024 . 3 7
end
local opts view(malmquist) overview time(year) dmu(plant)
datasignature set
graphdea units if plant!="omit", inputs(labor machine) `opts' orientation(input) decompose top(2)
matrix s=r(overview)
assert r(N)==10 & r(N_base)==5 & r(N_followup)==5 & r(N_matched)==4 & r(N_shown)==2
assert missing(r(technical_change))
matrix expected=(1,8,1.25,1,1.25,1,1 \ 2,6,1,1,1,1,1 \ ///
    3,10,1.089499218452472,1.148717948717948,.94844798034925,1.2,.957264957264957 \ ///
    4,9,1.223803845611936,1.290322580645161,.94844798034925,1.022727272727272,1.261648745519713)
mata: assert(mreldif(sort(st_matrix("s"),1),st_matrix("expected"))<1e-8)
graphdea labor machine=units in 1/10, `opts' periods(2024 2023) decompose orientation(input)
matrix backward=r(overview)
mata: assert(mreldif(sort(st_matrix("backward")[,(2,1,3,4,5,6,7)],1), (st_matrix("expected")[,1..2],1:/st_matrix("expected")[,3..7]))<1e-8)
graphdea labor=machine units in 1/10, `opts' decompose
matrix s=r(overview)
matrix expected=(1,8,1.25,.625,2,1,.625 \ 2,6,1,.5,2,.8,.625 \ ///
    3,10,1,.5,2,.8,.625 \ 4,9,4/3,2/3,2,16/15,.625)
mata: assert(mreldif(sort(st_matrix("s"),1),st_matrix("expected"))<1e-8)
datasignature confirm
generate double labormin=60*labor
generate double thousandunits=.001*units
graphdea machine thousandunits in 1/10, inputs(labormin) `opts' decompose orientation(input)
matrix rescaled=r(overview)
matrix expected=(1,8,1.25,.625,2,1,.625 \ 2,6,1,.5,2,.5,1 \ ///
    3,10,1,.5,2,.5,1 \ 4,9,4/3,2/3,2,.5,4/3)
mata: assert(mreldif(sort(st_matrix("rescaled"),1),st_matrix("expected"))<1e-8)
di "Multidimensional Malmquist overview checks passed"
