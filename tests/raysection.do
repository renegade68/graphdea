version 16.0
clear
input byte(id x1 x2 y1 y2)
1 1  2  2  4
2 3  6  3  6
3 8 16 80 80
end
datasignature set
graphdea y1 y2 in 1/2, inputs(x1 x2) view(raysection) dmu(id) focus(2)
assert r(N)==2
matrix S = r(section)
mata:
s = st_matrix("S")
left = select(s,s[,3]:<.)[1,]
assert(max(abs(left :- (1/3,2/3,2/3))) < 1e-7)
assert(max(abs(select(s,s[,1]:==1) :- (1,2,1))) < 1e-7)
assert(all(select(s[,3],s[,1]:<1/3):==.))
end
graphdea x1 x2 = y1 y2 in 1/2, view(raysection) dmu(id) focus(1)
matrix S = r(section)
mata: s=st_matrix("S"); assert(max(abs(select(s,s[,1]:==1) :- (1,1,1))) < 1e-7)
capture graphdea x1 x2 = y1 y2 in 1/2, view(raysection) dmu(id) focus(3)
assert _rc==459
datasignature confirm
