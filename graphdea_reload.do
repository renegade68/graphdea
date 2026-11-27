* Load the project version even when an earlier copy is active in Stata.
version 16.0
confirm file "./graphdea.ado"
capture program drop graphdea
capture program drop _graphdea_isoquant
capture program drop _graphdea_mpioverview
capture program drop _graphdea_mpichain
capture program drop _graphdea_malmquist
capture program drop _graphdea_section
capture program drop _graphdea_weakdiagram
foreach fn in raysection surface fdhmesh fdhslab sectiondepth meshline clipline slice outputslacks prepareslices sectionpath weakfrontier vrssection slicehull lowerhull mpidiagram mpioverviewcalc mpichaincalc mpiglobal mpimultilogs mpivrslog radialfactor mpilevels mpicalc mpivrs mpivrsboundary geometry slacktargets additiveoptima additive support peers axis ddf targets boundary fdh vrs peaks {
    capture mata: mata drop _graphdea_`fn'()
}
quietly run "./graphdea.ado"
