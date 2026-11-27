version 16.0
clear
input double(id a b z p1 p2)
1 1 4 3 1 2
2 4 1 3 1 2
3 3 7 7 1 2
4 7 3 7 1 2
5 6 8 9 1 2
6 8 6 9 1 2
7 6 6 6 1 2
end
datasignature set
foreach technology in crs vrs fdh {
    local model rts(`technology')
    if "`technology'" == "fdh" local model model(fdh)
    foreach inputs in 1 2 {
        if `inputs'==2 {
            local quantities a b = z
            local view isoquant
            local prices w(p1 p2)
            local econ ce
        }
        else {
            local quantities z = a b
            local view outputset
            local prices p(p1 p2)
            local econ re
        }
        graphdea `quantities', view(`view') `model' dmu(id) focus(7) `prices'
        matrix expected = r(targets)
        scalar te = r(te)
        scalar economic = r(`econ')
        graphdea `quantities', view(surface) `model' dmu(id) focus(7) `prices' sectionfill
        matrix actual = r(targets)
        assert reldif(r(te),te)<1e-12 & reldif(r(`econ'),economic)<1e-12
        mata: assert(max(abs(st_matrix("expected")-st_matrix("actual")))<1e-12)
        datasignature confirm
    }
}
graphdea a b = z if id!=7, view(surface) rts(vrs) sectionfill
assert r(output)==7 & r(N)==6
graphdea a b, inputs(z) at(z=5) view(surface) rts(vrs)
assert r(input)==5
graphdea a b = z in 1, dmu(id) focus(1) view(surface) rts(vrs)
assert r(te)==1
capture graphdea a b = z, at(z=12) view(surface) rts(vrs)
assert _rc==459
capture graphdea a = z, view(surface)
assert _rc==198
capture graphdea z = a b, view(surface) at(focus)
assert _rc==198
* Rotation changes only the projection; exercise both poles and a wrapped azimuth.
foreach el in -90 0 25 90 {
    graphdea a b = z, view(surface) rts(vrs) dmu(id) focus(7) azimuth(-225) elevation(`el')
    matrix targets = r(targets)
    assert r(azimuth)==135 & r(elevation)==`el'
    assert abs(targets[2,1]-4.375)<1e-12 & abs(targets[2,2]-4.375)<1e-12
}
graphdea z = a b, view(surface) rts(vrs) elevation(75)
assert r(azimuth)==45 & r(elevation)==75
graphdea a b = z, view(surface) azimuth(405)
assert r(azimuth)==45 & abs(r(elevation)-35.26438968275465)<1e-10
capture graphdea a b = z, view(surface) elevation(91)
assert _rc==125 | _rc==198
capture graphdea a b = z, at(z=6) azimuth(90)
assert _rc==198
datasignature confirm
capture graphdea a b = z, rts(vrs) at(z=6) sectionfill
assert _rc==198

graphdea a b = z if id!=7, view(surface) model(fdh) azimuth(-225) elevation(-25) sectionfill
assert r(output)==7 & r(azimuth)==135 & r(elevation)==-25
foreach el in 0 90 {
    graphdea z = a b in 1, view(surface) model(fdh) dmu(id) focus(1) elevation(`el') sectionfill
    assert r(te)==1 & r(phi)==1 & r(elevation)==`el'
}
graphdea a b = z, view(surface) model(fdh) at(z=6.5)
assert r(output)==6.5
capture graphdea a b = z, view(surface) model(fdh) at(z=10)
assert _rc==459
capture graphdea z = a b, view(surface) model(fdh) at(z=2)
assert _rc==459
datasignature confirm
di "surface checks passed"
