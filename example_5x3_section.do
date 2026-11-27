* Experimental fixed-mix DEA section. Run from the graphdea directory.
version 16.0
preserve
clear
input str1 id double(x1 x2 x3 x4 x5 y1 y2 y3)
"A"  5  9 15 18 24   4  9 13
"B" 10 18 27 40 47  14 30 45
"C" 15 29 43 58 75  18 38 56
"D" 10 20 30 40 50  10 20 30
"E"  9 24 30 37 53  21 19 32
"F" 11 17 31 42 44   8 35 49
end
foreach unit in D E {
    graphdea x1-x5 = y1-y3, view(raysection) dmu(id) focus("`unit'") ///
        name(section_`unit', replace)
    matrix section = r(section)
    mata: s = st_matrix("section"); s[selectindex(s[,1]:==1),]
}
graph combine section_D section_E, xcommon ycommon cols(2) ///
    title("Five inputs and three outputs") name(dea_5x3_section, replace)
graph export graphdea-5x3-section.png, width(1800) replace
restore
