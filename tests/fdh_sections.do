version 16.0
clear
input double(id a b z p1 p2)
1 1 7 10 . .
2 2 4 10 . .
3 4 2 10 . .
4 7 1 10 . .
5 6 6 10 2 1
6 1 1  9 . .
end
datasignature set
graphdea a b = z, model(fdh) dmu(id) focus(5) w(p1 p2)
matrix actual = r(targets)
matrix expected = (6,6,18 \ 4,4,12 \ 2,4,8)
mata: assert(mreldif(st_matrix("actual"),st_matrix("expected"))<1e-13)
assert abs(r(te)-2/3)<1e-12 & abs(r(ae)-2/3)<1e-12 & abs(r(ce)-4/9)<1e-12
assert "`r(technologies)'"=="fdh" & r(output)==10 & r(N)==6
graphdea z if id!=2, inputs(a b) model(fdh) dmu(id) focus(5) w(p1 p2)
assert abs(r(ce)-.5)<1e-12
graphdea a b = z, model(fdh) at(z=9.5)
assert r(output)==9.5
capture graphdea a b = z, model(fdh) at(z=11)
assert _rc==459
capture graphdea a b = z, model(fdh) rts(vrs) at(z=10)
assert _rc==198
datasignature confirm

clear
input double(id a b z p1 p2)
1 1 8  9 . .
2 3 7 10 . .
3 7 3 10 . .
4 8 1  9 . .
5 3 3 10 3 2
6 8 8 11 . .
end
datasignature set
graphdea a b, inputs(z) model(fdh) dmu(id) focus(5) p(p1 p2) show(radialout revenuemax)
matrix actual = r(targets)
matrix expected = (3,3,15 \ 3,3,15 \ 7,3,27)
mata: assert(mreldif(st_matrix("actual"),st_matrix("expected"))<1e-13)
assert r(phi)==1 & r(te)==1 & abs(r(ae)-5/9)<1e-12 & abs(r(re)-5/9)<1e-12
graphdea z=a b in 5, model(fdh) dmu(id) focus(5) p(p1 p2)
assert r(N)==1 & r(te)==1 & r(ae)==1 & r(re)==1
graphdea z=a b, model(fdh) at(z=9.5)
assert r(input)==9.5
capture graphdea z=a b, model(fdh) at(z=8)
assert _rc==459
datasignature confirm

di "FDH section checks passed"
