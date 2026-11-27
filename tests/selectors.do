version 16.0
clear
input float(id time) double(labor output)
.1 .1  1 1
.2 .1  2 3
.1 .2  2 4
.2 .2  3 4
end
datasignature set
graphdea labor=output in 1/2, dmu(id) focus(.1)
matrix projection=r(projections)
assert r(N)==2 & abs(projection[1,2]-2/3)<1e-12
graphdea output if time==float(.1), inputs(labor) view(convexity) dmu(id) pair(.1 .2)
matrix mixture=r(mixture)
assert mixture[1,3]==1.5 & mixture[1,4]==2
local panel view(malmquist) dmu(id) time(time)
graphdea labor=output, `panel' focus(.1)
scalar autoindex=r(malmquist)
graphdea labor=output, `panel' periods(.1 .2) focus(.1)
assert r(N_base)==2 & r(N_followup)==2 & !missing(r(technical_change),r(efficiency_change))
assert r(malmquist)==autoindex & r(base)==float(.1) & r(followup)==float(.2)
graphdea labor=output, `panel' overview periods(.1 .2) top(1)
assert r(N_matched)==2 & r(N_shown)==1
graphdea labor=output, `panel' focus(.1) chain periods(.2 .1) benchmark(global)
assert r(base)==float(.2) & r(followup)==float(.1) & abs(r(malmquist)*autoindex-1)<1e-12
capture graphdea labor=output, `panel' focus(.1) periods(.1 .100000001)
assert _rc==198
datasignature confirm

clear
input float(x) double(a b)
.1 1 3
.2 3 1
end
datasignature set
graphdea x=a b, rts(vrs) at(x=.1)
assert r(input)==float(.1)
graphdea x=a b, rts(vrs) at(x=.15)
assert r(input)==.15
datasignature confirm

* A double ID and time distinguish observations in the same float bin.
clear
input double(id time x y)
.1                .1                1 1
.100000000000001  .1                2 3
.1                .100000000000001  2 4
.100000000000001  .100000000000001  3 4
end
datasignature set
graphdea x=y in 1/2, dmu(id) focus(.100000000000001)
matrix projection=r(projections)
assert projection[1,2]==1
graphdea x=y, view(malmquist) dmu(id) focus(.1) time(time) periods(.1 .100000000000001)
assert r(base)==.1 & r(followup)==.100000000000001 & r(N)==4 & r(N_followup)==2
datasignature confirm
di "Decimal selector checks passed"
