* Run in a test session. Loading the source makes its private Mata functions visible.
version 16.0
clear all
findfile graphdea.ado
quietly run "`r(fn)'"

* All nondominated observed bundles remain eligible, including unsupported ones.
* Verify the interior corners of each staircase turn toward the feasible side.
mata:
bundles = (1,8 \ 5,6 \ 8,1)
obs = bundles \ (5,6) \ (9,9)
corners = _graphdea_slicehull(obs,0,1)
assert(all(corners:==bundles))
assert(all(_graphdea_fdh(corners,0):==(1,8 \ 5,8 \ 5,6 \ 8,6 \ 8,1)))
obs = bundles \ (5,6) \ (1,1)
corners = _graphdea_slicehull(obs,1,1)
assert(all(corners:==bundles))
assert(all(_graphdea_fdh(corners,1):==(1,8 \ 1,6 \ 5,6 \ 5,1 \ 8,1)))
end

* Nearly flat and nearly vertical facets have large normalized multipliers.
mata:
flat = (.1,0 \ .1,.5 \ .9,.5+1e-14 \ 1,.5+1e-14)
steep = (.5,0 \ .5,.1 \ .5+1e-14,.9 \ 1,.9)
o = (1,.5+5e-15)
line = .
m = _graphdea_support(flat,o,1,(1,1),(1,1),line)
assert(abs(m[4]-_graphdea_targets(flat,o)[1]/o[1])<1e-12)
o = (.5+5e-15,.1)
m = _graphdea_support(steep,o,0,(1,1),(1,1),line)
assert(abs(m[4]-_graphdea_targets(steep,o)[2]/o[2])<1e-12)
end

* A crossing segment must meet its rear half at the plane for both cameras.
* Changing the viewpoint also changes which observed point the plane can mask.
mata:
segments = (1,0,0,0,1,1,1 \ 1,1,0,1,0,1,0 \ 4,0,0,.2,.,.,. \ 4,0,0,.8,.,.,.)
above = _graphdea_sectiondepth(segments,.5,25)
below = _graphdea_sectiondepth(segments,.5,-25)
assert(rows(above)==6 & rows(below)==6)
assert(all(above[,1]:==(1\1\10\4\9\9)))
assert(all(below[,1]:==(1\1\4\10\9\9)))
assert(all(above[1,2..4]:==(.5,.5,.5)) & all(above[2,5..7]:==(.5,.5,.5)))
assert(all(above[5,5..7]:==above[1,2..4]) & all(above[6,2..4]:==above[2,5..7]))
assert(all(below[1,5..7]:==above[1,2..4]) & all(below[2,2..4]:==above[2,5..7]))
assert(all(_graphdea_sectiondepth(segments,.5,0):==segments))
end
* FDH geometry is independent of camera angle and keeps narrow terraces.
* Compare the mesh with membership of the original observed orthants.
mata:
data = (.25,.75,.5 \ .75,.25,.5 \ .5,.5,.50001)
for (s=0;s<=1;s++) {
    mesh = _graphdea_fdhmesh(data,s)
    assert(all(mesh[,1]:==1))
    assert(all(rowsum(mesh[,2..4]:!=mesh[,5..7]):==1))
    assert(any(mesh[,4]:==.5) & any(mesh[,4]:==.50001))
    // A plane halfway through the narrow terrace must cut these uprights.
    crossing = select(mesh,(mesh[,4]:<.500005):&(mesh[,7]:>.500005))
    if (s) expected = (0,.75 \ .25,.75 \ .25,.25 \ .75,.25 \ .75,0)
    else   expected = (.5,1 \ .5,.5 \ 1,.5)
    assert(all(sort(crossing[,2..3],(1,2)):==sort(expected,(1,2))))
    for (j=1;j<=rows(mesh);j++) {
        mid = (mesh[j,2..4]+mesh[j,5..7])/2
        gains = (data:-mid):*((s ? 1 : -1)*(1,1,-1))
        assert(any(rowmin(gains):>=-1e-14))
        assert(!any(rowmin(gains):>1e-14))
    }
    dominated = s ? (.125,.125,.875) : (.875,.875,.125)
    assert(all(mesh:==_graphdea_fdhmesh(data[3::1,] \ data[1,] \ dominated,s)))
}
end

clear all
di "Mata geometry checks passed"
