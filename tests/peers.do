* Reference weights, radial benchmarks and second-stage improvements.
version 16.0
clear
input str1 id double(x y)
"A" 2 2
"B" 4 6
"C" 8 8
"D" 6 4
end
datasignature set
graphdea x=y, dmu(id) focus("D") compare(crs vrs fdh) show(pps frontier radial lambda slacks)
assert "`r(ref_orientation)'" == "input"
matrix bm = r(benchmarks)
matrix peers = r(peers)
matrix targets = (8/3,4,8/3,4,0,0 \ 3,4,3,4,0,0 \ 4,4,4,6,0,2)
matrix weights = (2,2/3,4,6 \ 1,.5,2,2 \ 2,.5,4,6 \ 2,1,4,6)
mata: assert(mreldif(st_matrix("bm"),st_matrix("targets")) < 1e-14)
mata: assert(mreldif(st_matrix("peers"),st_matrix("weights")) < 1e-14)
graphdea x=y, dmu(id) focus("D") compare(crs vrs fdh) show(radialout peers)
assert "`r(ref_orientation)'" == "output"
matrix bm = r(benchmarks)
matrix peers = r(peers)
matrix targets = (6,9,6,9,0,0 \ 6,7,6,7,0,0 \ 6,6,4,6,2,0)
matrix weights = (2,1.5,4,6 \ 2,.5,4,6 \ 3,.5,8,8 \ 2,1,4,6)
mata: assert(mreldif(st_matrix("bm"),st_matrix("targets")) < 1e-14)
mata: assert(mreldif(st_matrix("peers"),st_matrix("weights")) < 1e-14)
datasignature confirm

* Duplicate extremes and both free-disposal edges in a restricted sample.
clear
input double(x y)
1 99
1  3
1  3
2  1
end
gen id = _n
foreach direction in input output {
    graphdea x=y in 2/4, dmu(id) focus(4) compare(vrs fdh) orientation(`direction') show(slacks)
    matrix bm = r(benchmarks)
    matrix peers = r(peers)
    matrix weights = (2,1,1,3 \ 2,1,1,3)
    mata: assert(all(st_matrix("peers"):==st_matrix("weights")))
    if "`direction'"=="input" matrix targets = (1,1,1,3,0,2 \ 1,1,1,3,0,2)
    else matrix targets = (2,3,1,3,1,0 \ 2,3,1,3,1,0)
    mata: assert(all(st_matrix("bm"):==st_matrix("targets")))
}
graphdea x=y in 3, dmu(id) focus(3) compare(crs vrs fdh) show(lambda)
matrix peers = r(peers)
mata: assert(all(st_matrix("peers") :== J(3,1,1)*(3,1,1,3)))
capture graphdea x=y, show(slacks)
assert _rc==198
di "peers checks passed"
