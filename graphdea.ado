*! version 0.30.1  27nov2026
* Copyright (c) 2026 Choonjoo Lee <bloom.rampike@gmail.com>
* Licensed under the Academic Free License version 3.0
* SPDX-License-Identifier: AFL-3.0
program define graphdea, rclass
    version 16.0
    syntax anything(name=spec equalok) [if] [in], [Inputs(varlist numeric) ///
        DMU(varname) FOCus(string) Model(string) RTS(string) Compare(string) ///
        ORientation(string) Show(string) View(string) Layout(string) NAME(passthru) ///
        TItle(passthru) XTItle(passthru) YTItle(passthru) AT(string) W(varlist numeric) P(varlist numeric) ///
        AZimuth(numlist min=1 max=1) ELevation(numlist min=1 max=1 >=-90 <=90) SECTIONFill GX(string) GY(string) ///
        PAIR(string asis) SHARE(numlist min=1 max=1 >=0 <=1) PLAN(numlist min=2 max=2 >=0) BAD(varname numeric) ///
        SLACKWeights(numlist min=2 max=2 >0) TIME(varname numeric) PERiods(string) DECompose CHain BENchmark(string) OVERview TOP(numlist integer min=1 max=1 >=1)]

    if "`inputs'" == "" {
        local eq = strpos("`spec'", "=")
        local x = substr("`spec'", 1, `eq'-1)
        local y = substr("`spec'", `eq'+1, .)
        if !`eq' {
            di as err "specify input = output, or output, inputs(input)"
            exit 198
        }
    }
    else {
        local x `inputs'
        local y `spec'
    }
    foreach side in x y {
        unab expanded : ``side''
        foreach v of local expanded {
            confirm numeric variable `v'
        }
        local `side' `expanded'
    }
    local ninputs : word count `x'
    local noutputs : word count `y'
    if inlist("`model'", "additive", "sbm", "super", "malmquist") {
        if !inlist("`view'", "", "`model'") {
            di as err "model(`model') requires view(`model')"
            exit 198
        }
        local view `model'
        local model
    }
    local slackview = inlist("`view'", "additive", "sbm")
    if "`slackweights'" != "" & "`view'" != "additive" {
        di as err "slackweights() requires view(additive)"
        exit 198
    }
    if `slackview' {
        if `ninputs'+`noutputs' != 2 | `"`focus'"' == "" | "`dmu'" == "" {
            di as err "view(`view') requires one input, one output, dmu(), and focus()"
            exit 198
        }
        if "`view'"=="additive" & "`orientation'"!="" {
            di as err "view(additive) is nonoriented"
            exit 198
        }
        if !inlist("`model'", "", "fdh") {
            di as err "use rts(vrs|crs), model(fdh), or compare() with view(`view')"
            exit 198
        }
        if "`view'"=="additive" & "`slackweights'" == "" local slackweights 1 1
        foreach coefficient of local slackweights {
            if missing(`coefficient') error 198
        }
        if "`model'`rts'`compare'" == "" local rts vrs
    }
    local superview = "`view'"=="super"
    if `superview' & (`ninputs'+`noutputs'!=2 | `"`focus'"'=="" | "`dmu'"=="") {
        di as err "view(super) requires one input, one output, dmu(), and focus()"
        exit 198
    }
    if "`bad'" != "" & "`view'" == "" local view weakdisposal
    local weakview = "`view'" == "weakdisposal"
    if (`weakview' & (`ninputs' != 1 | `noutputs' != 1 | "`bad'" == "")) | (!`weakview' & "`bad'" != "") {
        di as err "specify one input = one desirable output, bad(emissions) for view(weakdisposal)"
        exit 198
    }
    local vars `x' `y' `bad'
    local vars : list retokenize vars
    local unique : list uniq vars
    if `ninputs' + `noutputs' > 3 | "`unique'" != "`vars'" {
        di as err "supported dimensions are 1 input/1 output, 2 inputs/1 output, or 1 input/2 outputs"
        exit 198
    }
    if `ninputs' == 2 & "`view'" == "" local view isoquant
    if `noutputs' == 2 & "`view'" == "" local view outputset
    marksample touse
    markout `touse' `vars'
    local mpi = "`view'"=="malmquist"
    if "`overview'"!="" & (!`mpi' | "`chain'"!="" | `"`focus'"'!="") {
        di as err "overview compares all matched DMUs for one pair of periods in view(malmquist)"
        exit 198
    }
    if "`top'"!="" & "`overview'"=="" {
        di as err "top() requires overview"
        exit 198
    }
    if "`chain'"!="" & !`mpi' {
        di as err "chain requires view(malmquist)"
        exit 198
    }
    if "`benchmark'"!="" & ("`chain'"=="" | !inlist("`benchmark'","contemporaneous","global")) {
        di as err "specify benchmark(contemporaneous|global) with view(malmquist) chain"
        exit 198
    }
    if "`decompose'"!="" & !`mpi' {
        di as err "decompose requires view(malmquist)"
        exit 198
    }
    if !`mpi' & "`time'`periods'"!="" {
        di as err "time() and periods() require view(malmquist)"
        exit 198
    }
    if `mpi' {
        if "`time'"=="" | "`dmu'"=="" | (`"`focus'"'=="" & "`overview'"=="") {
            di as err "view(malmquist) requires time(), dmu(), and either focus() or overview"
            exit 198
        }
        if "`orientation'"=="" local orientation output
        if !inlist("`orientation'","input","output") {
            di as err "Malmquist orientation() must be input or output"
            exit 198
        }
        if !inlist("`rts'","","crs") | ///
            "`model'`compare'`show'`layout'`at'`w'`p'`azimuth'`elevation'`sectionfill'`gx'`gy'`share'`plan'"!="" | `"`pair'"'!="" {
            di as err "view(malmquist) requires a CRS productivity index and supplies its graph layers"
            exit 198
        }
        markout `touse' `time' `dmu', strok
        if "`periods'"!="" {
            // Validate range notation, but retain the full precision of explicit dates.
            numlist "`periods'", min(2)
            local expanded "`r(numlist)'"
            local dates : subinstr local periods "," " ", all
            foreach date of local dates {
                capture confirm number `date'
                if _rc {
                    local dates `expanded'
                    continue, break
                }
            }
            local periods
            local timetype : type `time'
            foreach date of local dates {
                if "`timetype'"=="float" local date : display %24.17g float(`date')
                local periods `periods' `date'
            }
            local periods : list retokenize periods
        }
        if "`chain'"!="" {
            if "`periods'"!="" {
                tempvar wanted
                quietly gen byte `wanted' = 0
                gettoken base rest : periods
                local end : word count `periods'
                local later : word `end' of `periods'
                local previous `base'
                foreach date of local rest {
                    if missing(`previous',`date') | cond(`later'>`base',`date'<=`previous',`date'>=`previous') {
                        di as err "chain periods must be strictly increasing or strictly decreasing"
                        exit 198
                    }
                    local previous `date'
                }
                foreach date of local periods {
                    quietly replace `wanted'=1 if `time'==`date' & `touse'
                }
                quietly replace `touse'=0 if !`wanted'
            }
        }
        else {
            if "`periods'"!="" & `:word count `periods''!=2 {
                di as err "select exactly two periods or add chain"
                exit 198
            }
            if "`periods'"=="" {
                quietly summarize `time' if `touse', meanonly
                if !r(N) error 2000
                local base : display %24.17g r(min)
                local later : display %24.17g r(max)
                quietly count if `touse' & !inlist(`time',`base',`later')
                if r(N) {
                    di as err "select two time values with periods(base followup) or if/in"
                    exit 198
                }
            }
            else {
                gettoken base later : periods
            }
            if missing(`base',`later') | `base'==`later' {
                di as err "two distinct nonmissing time values are required"
                exit 198
            }
            quietly replace `touse'=0 if !inlist(`time',`base',`later')
        }
    }
    quietly count if `touse'
    local N = r(N)
    if !`N' error 2000
    if `superview' & `N'<2 {
        di as err "at least one other DMU must remain after excluding the focus"
        exit 459
    }
    foreach v of local vars {
        if `weakview' & "`v'" != "`x'" {
            quietly count if `touse' & `v' < 0
            if r(N) {
                di as err "desirable and undesirable outputs must be nonnegative"
                exit 459
            }
            continue
        }
        quietly count if `touse' & `v' <= 0
        if r(N) {
            di as err "inputs and output in the reference sample must be strictly positive"
            exit 459
        }
    }
    tempvar selected
    quietly gen byte `selected' = 0
    local dispview = "`view'" == "disposability"
    if `dispview' {
        if `ninputs'+`noutputs' != 2 | `"`focus'"' == "" | "`dmu'" == "" {
            di as err "view(disposability) requires one input, one output, dmu(), and focus()"
            exit 198
        }
        if "`model'`rts'`compare'" == "" local compare vrs fdh
    }
    else if "`plan'" != "" & !`weakview' {
        di as err "plan() requires view(disposability) or view(weakdisposal)"
        exit 198
    }
    local mixview = "`view'" == "convexity"
    if `mixview' {
        if `ninputs'+`noutputs' != 2 | "`dmu'" == "" | `:word count `pair'' != 2 {
            di as err "view(convexity) requires one input, one output, dmu(), and pair(first_id second_id)"
            exit 198
        }
        gettoken first rest : pair
        gettoken second rest : rest
        if `"`first'"' == "" | `"`second'"' == "" {
            di as err "pair() requires two nonempty DMU identifiers"
            exit 198
        }
        if "`share'" == "" local share .5
        if "`model'`rts'`compare'" == "" local compare vrs fdh
        tempvar endpoints
        quietly gen byte `endpoints' = 0
        local roles first second
    }
    else if `"`pair'"' != "" | "`share'" != "" {
        di as err "pair() and share() require view(convexity)"
        exit 198
    }
    if `"`focus'"' != "" local roles `roles' focus
    foreach role of local roles {
        if "`dmu'" == "" {
            di as err "focus() requires dmu()"
            exit 198
        }
        local idvalue `"``role''"'
        local flag `selected'
        if "`role'" != "focus" local flag `endpoints'
        local tag = 1 + ("`role'" == "second")
        capture confirm string variable `dmu'
        if !_rc local match `"`dmu' == `"`idvalue'"'"'
        else {
            confirm number `idvalue'
            local idtype : type `dmu'
            local number real("`idvalue'")
            if "`idtype'"=="float" local number float(`number')
            local match `dmu' == `number' & !missing(`dmu')
        }
        quietly replace `flag' = `tag' if `touse' & `flag' == 0 & `match'
        if `mpi' {
            if "`chain'"!="" continue
            foreach date in `base' `later' {
                quietly count if `flag' & `time'==`date'
                if r(N)!=1 {
                    di as err "focus() must identify one complete observation in each selected period"
                    exit 459
                }
            }
            continue
        }
        quietly count if `flag' == `tag'
        if r(N) != 1 {
            if "`role'" == "focus" di as err "focus() must identify exactly one DMU in the reference sample"
            else di as err "pair() must identify two distinct DMUs, each unique in the reference sample"
            exit 459
        }
    }
    if "`chain'"!="" {
        if "`benchmark'"=="" local benchmark contemporaneous
        if "`periods'"!="" local periodopt periods(`periods')
        _graphdea_mpichain `x' `y' if `touse', ninputs(`ninputs') time(`time') `periodopt' selected(`selected') ///
            focus(`"`focus'"') orientation(`orientation') benchmark(`benchmark') `decompose' `title' `xtitle' `ytitle' `name'
        return add
        exit
    }
    if "`overview'"!="" {
        if "`top'"!="" local topopt top(`top')
        _graphdea_mpioverview `x' `y' if `touse', ninputs(`ninputs') time(`time') periods(`base' `later') ///
            dmu(`dmu') orientation(`orientation') `decompose' `topopt' `title' `xtitle' `ytitle' `name'
        return add
        exit
    }
    if `mpi' {
        _graphdea_malmquist `x' `y' if `touse', ninputs(`ninputs') time(`time') periods(`base' `later') ///
            selected(`selected') focus(`"`focus'"') orientation(`orientation') `decompose' `title' `xtitle' `ytitle' `name'
        return add
        exit
    }
    if "`azimuth'`elevation'`sectionfill'" != "" & "`view'" != "surface" {
        di as err "azimuth(), elevation(), and sectionfill require view(surface)"
        exit 198
    }
    local ddfview = "`view'" == "ddf"
    local ddflayer : list posof "ddf" in show
    local ddf = `ddfview' | `ddflayer' > 0
    if `ddf' & (`ninputs'+`noutputs' != 2 | !inlist("`view'", "", "production", "ddf")) {
        di as err "directional distance requires one input and one output in a production diagram"
        exit 198
    }
    if "`gx'`gy'" != "" & !`ddf' {
        di as err "gx() and gy() require view(ddf) or show(ddf)"
        exit 198
    }
    if `ddf' {
        if `"`focus'"' == "" {
            di as err "directional distance requires dmu() and focus()"
            exit 198
        }
        tempname dirx diry
        foreach axis in x y {
            local value `g`axis''
            if "`value'" == "" local value ``axis''
            if `:word count `value'' != 1 {
                di as err "g`axis'() takes one number or numeric variable"
                exit 198
            }
            capture confirm name `value'
            if _rc scalar `dir`axis'' = real("`value'")
            else {
                unab dirvar : `value', max(1)
                confirm numeric variable `dirvar'
                quietly summarize `dirvar' if `selected', meanonly
                scalar `dir`axis'' = r(mean)
            }
            if missing(`dir`axis'') | `dir`axis'' < 0 {
                di as err "g`axis'() must be finite and nonnegative at the selected DMU"
                exit 459
            }
        }
        if `dirx' == 0 & `diry' == 0 {
            di as err "at least one direction component must be positive"
            exit 459
        }
    }
    if "`view'" == "surface" {
        if `ninputs' + `noutputs' != 3 {
            di as err "view(surface) requires two inputs and one output, or one input and two outputs"
            exit 198
        }
        if "`azimuth'" == "" local azimuth 45
        if "`elevation'" == "" local elevation = asin(1/sqrt(3)) * 180 / _pi
        local surface surface `sectionfill' azimuth(`azimuth') elevation(`elevation')
        if `ninputs' == 2 local view isoquant
        else local view outputset
    }
    if inlist("`view'","isoquant","outputset","weakdisposal") {
        if `weakview' {
            if "`compare'`layout'`p'`w'`orientation'" != "" | !inlist("`model'","","undesirable") | !inlist("`rts'","","vrs","crs") {
                di as err "view(weakdisposal) uses one convex technology, specified by rts(vrs|crs)"
                exit 198
            }
            if "`rts'" == "" local rts vrs
            local model
            local sectionvars `bad' `y' `x'
        }
        else if "`view'" == "isoquant" {
            if `ninputs' != 2 | !inlist("`orientation'","","input") | "`p'" != "" {
                di as err "isoquant requires two inputs, input orientation, and w() for prices"
                exit 198
            }
            local sectionvars `x' `y'
            local prices `w'
        }
        else {
            if `noutputs' != 2 | !inlist("`orientation'","","output") | "`w'" != "" {
                di as err "outputset requires two outputs, output orientation, and p() for prices"
                exit 198
            }
            local sectionvars `y' `x'
            local prices `p'
        }
        if !inlist("`layout'","","panel") | ("`layout'" != "" & "`compare'" == "") {
            di as err "use layout(panel) with compare() for planar sections"
            exit 198
        }
        if "`surface'" != "" & "`compare'" != "" {
            di as err "view(surface) uses one technology; compare() requires a planar section"
            exit 198
        }
        foreach opt in model rts at prices show compare plan {
            if "``opt''" != "" local sectionopts `sectionopts' `opt'(``opt'')
        }
        _graphdea_section `sectionvars' if `touse', selected(`selected') view(`view') ///
            `sectionopts' `surface' `title' `xtitle' `ytitle' `name'
        return add
        exit
    }
    if `ninputs' + `noutputs' != 2 | "`at'`w'`p'" != "" {
        di as err "use view(isoquant) or view(outputset) for a fixed-level cross-section"
        exit 198
    }
    local scaleview = "`view'" == "scale"
    if `scaleview' {
        if `"`focus'"' == "" {
            di as err "view(scale) requires dmu() and focus()"
            exit 198
        }
        if "`compare'`rts'`layout'`show'" != "" | !inlist("`model'", "", "te") {
            di as err "view(scale) supplies its own CRS and VRS frontiers, layout, and layers"
            exit 198
        }
        local compare crs vrs
    }
    if !inlist("`view'", "", "production", "scale", "ddf", "convexity", "disposability", "additive", "sbm", "super") | !inlist("`layout'", "", "panel") {
        di as err "use a supported production view and layout(panel)"
        exit 198
    }
    if "`view'"=="sbm" & "`orientation'"=="" local orientation nonoriented
    if "`orientation'" == "" {
        local orientation input
        if strpos(" `show' "," radialout ") & !strpos(" `show' "," radialin ") & !strpos(" `show' "," radial ") {
            local orientation output
        }
    }
    local orientedsbm = "`view'"=="sbm" & inlist("`orientation'","input","output")
    if !inlist("`orientation'", "input", "output") & !("`view'"=="sbm" & "`orientation'"=="nonoriented") {
        if "`view'"=="sbm" {
            di as err "SBM orientation() must be nonoriented, input, or output"
            exit 198
        }
        di as err "orientation() must be input or output"
        exit 198
    }
    if "`compare'" != "" {
        if !`scaleview' & "`rts'`model'" != "" {
            di as err "compare() supplies the technologies; omit model() and rts()"
            exit 198
        }
        local models `compare'
    }
    else {
        if !inlist("`model'", "", "te", "fdh") | !inlist("`rts'", "", "crs", "vrs") {
            di as err "use model(te) with rts(crs|vrs), or model(fdh)"
            exit 198
        }
        if "`model'" == "fdh" & "`rts'" != "" {
            di as err "model(fdh) specifies the ordinary FDH technology; omit rts()"
            exit 198
        }
        local models `rts'
        if "`models'" == "" local models crs
        if "`model'" == "fdh" local models fdh
    }
    local unique : list uniq models
    local k : word count `models'
    if `:word count `unique'' != `k' {
        di as err "each comparison technology must appear once"
        exit 198
    }
    foreach m of local models {
        if !inlist("`m'", "crs", "vrs", "fdh") {
            di as err "compare() accepts crs, vrs, and fdh"
            exit 198
        }
    }

    if "`show'" == "" {
        local show pps frontier
        if `slackview' local show `show' slacks
        else if `"`focus'"' != "" & !`ddfview' & !`dispview' local show `show' radial
    }
    foreach item of local show {
        if `superview' {
            if !inlist("`item'","pps","frontier","radial") {
                di as err "available super-efficiency layers are pps, frontier, and radial"
                exit 198
            }
            if "`item'"=="radial" {
                local draw_superradial 1
                continue
            }
        }
        if `slackview' {
            if !inlist("`item'","pps","frontier","slacks") {
                di as err "available `view' layers are pps, frontier, and slacks"
                exit 198
            }
            if "`item'" == "slacks" {
                local draw_targetslacks 1
                continue
            }
        }
        if "`item'" != "ddf" & !inlist("`item'", "pps", "frontier", "radial", "radialin", "radialout", "peers", "lambda", "slacks", "weights") {
            di as err "unknown show() layer: `item'"
            exit 198
        }
        if "`item'" == "radial" {
            if "`orientation'" == "input" local item radialin
            else local item radialout
        }
        local draw_`item' 1
    }
    local reference = "`draw_peers'`draw_lambda'`draw_slacks'" != ""
    if "`draw_lambda'" != "" local draw_peers 1
    local showtarget = `reference' | "`draw_weights'" != ""
    local hasfdh : list posof "fdh" in models
    if "`draw_weights'" != "" & `hasfdh' {
        di as err "show(weights) requires convex CRS or VRS technology"
        exit 198
    }
    if (`showtarget' | "`draw_radialin'`draw_radialout'" != "") & `"`focus'"' == "" {
        di as err "projections and reference layers require dmu() and focus()"
        exit 198
    }
    local xt : variable label `x'
    local yt : variable label `y'
    if `"`xt'"' == "" local xt `x'
    if `"`yt'"' == "" local yt `y'
    if `"`xtitle'"' == "" local xtitle `"xtitle("`xt'")"'
    if `"`ytitle'"' == "" local ytitle `"ytitle("`yt'")"'
    if `"`title'"' == "" {
        if `scaleview' local title title("{stSerif:Scale efficiency}")
        else if `superview' local title title("{stSerif:`=proper("`orientation'")'-oriented radial super-efficiency}")
        else if `orientedsbm' local title title("{stSerif:`=proper("`orientation'")'-oriented slacks-based efficiency}")
        else if "`view'" == "sbm" local title title("{stSerif:Slacks-based efficiency}")
        else if `slackview' local title title("{stSerif:Additive DEA targets}")
        else if `dispview' local title title("{stSerif:Free disposability of inputs and outputs}")
        else if `mixview' local title title("{stSerif:Convex combinations of observed DMUs}")
        else if `ddf' local title title("{stSerif:Directional distance to the frontier}")
        else if `k' == 1 local title title("{stSerif:DEA production frontier}")
        else local title title("{stSerif:DEA production frontiers}")
    }

    local legendgrid rows(2)
    preserve
    quietly {
        tempvar ox oy label orig
        gen long `orig' = _n
        keep if `touse' 
        gen double `ox' = `x'
        gen double `oy' = `y'
        if "`dmu'" != "" {
            capture confirm string variable `dmu'
            if !_rc {
                clonevar `label' = `dmu'
            }
            else gen str24 `label' = strtrim(string(`dmu', "%24.0g"))
        }
        local labs
        if "`dmu'" != "" local labs `label'
        keep `ox' `oy' `selected' `labs' `orig' `endpoints'
        expand `k'
        bysort `orig' : gen byte panel = _n
        sort panel `orig'
        foreach v in bx by top fx fy tx ty {
            gen double `v' = .
        }
        gen byte floor = 0
        if `superview' {
            tempname superresults
            foreach v in refx refy reftop superx supery {
                gen double `v' = .
            }
        }
        if `slackview' {
            tempname slacktargets slacksummary
            foreach v in ax ay slackx0 slacky0 {
                gen double `v' = .
            }
            gen byte targetface = 0
        }
        if `dispview' {
            tempname disposal
            gen double dispx = .
            gen double dispy = .
            if "`plan'" != "" {
                gen double planx = .
                gen double plany = .
            }
        }
        if `mixview' {
            tempname mixtures
            gen double mixx = .
            gen double mixy = .
        }
        if `ddf' {
            gen double dx = .
            gen double dy = .
        }
        if `showtarget' {
            gen double rx = .
            gen double ry = .
        }
        if "`draw_weights'" != "" {
            gen double wx = .
            gen double wy = .
        }
        if `reference' {
            foreach v in sx sy weight {
                gen double `v' = .
            }
        }
        tempname scores panellabel peers benchmarks nirste multipliers distances
        mata: _graphdea_geometry()
        if `ddf' {
            // Place labels beside coincident target DMUs away from the incoming arrow.
            tempvar ddflabpos
            gen byte `ddflabpos' = 4
            forvalues i = 1/`k' {
                replace `ddflabpos' = 9 if panel==`i' & ///
                    reldif(`ox',`distances'[`i',4]) < 1e-12 & reldif(`oy',`distances'[`i',5]) < 1e-12
            }
        }
        if !`scaleview' {
            forvalues i = 1/`k' {
                local modelname = upper(word("`models'", `i'))
                if `k' > 1 local modelname = "(" + char(96+`i') + ")  `modelname'"
                local heading `""{bf:`modelname'}""'
                if `superview' {
                    local full = strtrim(string(`superresults'[`i',1],"%9.4g"))
                    local status "No radial target"
                    if `superresults'[`i',6] {
                        local value = strtrim(string(`superresults'[`i',3],"%9.4g"))
                        local status "Super score = `value'"
                    }
                    local heading `"`heading' "Full score = `full'" "`status'""'
                }
                if `slackview' {
                    local score = strtrim(string(`slacksummary'[`i',1], "%9.5g"))
                    local measure "Weighted slack sum"
                    if "`view'"=="sbm" local measure "{&rho}"
                    if `orientedsbm' local measure "{&rho}{sub:`orientation'}"
                    local heading `"`heading' "`measure' = `score'""'
                    if "`view'"=="sbm" & "`draw_targetslacks'"!="" {
                        local xs = strtrim(string(100*`slacksummary'[`i',3],"%9.4g"))
                        local ys = strtrim(string(100*`slacksummary'[`i',4],"%9.4g"))
                        local heading `"`heading' "Input slack  `xs'%" "Output slack  `ys'%""'
                    }
                    if "`view'"=="additive" & `slacksummary'[`i',2]>1 {
                        local kind "Optimal segment"
                        if word("`models'",`i')=="fdh" local kind "Separate optimal targets"
                        local heading `"`heading' "`kind'""'
                    }
                }
                if `dispview' & "`plan'" != "" {
                    local region = cond(`disposal'[`i',5], "Inside", "Outside")
                    local status = cond(`disposal'[`i',7], "Feasible", "Infeasible")
                    local heading `"`heading' "`status' plan" "`region' the selected DMU's region""'
                }
                if `mixview' {
                    local status = cond(`mixtures'[`i',6], "Feasible", "Infeasible")
                    local w1 = strtrim(string(`share', "%9.4g"))
                    local w2 = strtrim(string(1-`share', "%9.4g"))
                    local heading `"`heading' "`w1' `first' + `w2' `second'  ({it:`status'})""'
                }
                if `"`focus'"' != "" {
                    local theta = strtrim(string(`scores'[`i',2], "%6.3f"))
                    local effout = strtrim(string(`scores'[`i',5], "%6.3f"))
                    local score "{&theta} = `theta'     1/{&phi} = `effout'"
                    if "`draw_weights'" != "" {
                        if "`orientation'" == "input" local score "Input orientation     {&theta} = `theta'"
                        else local score "Output orientation     1/{&phi} = `effout'"
                    }
                    if (!`superview' & !`ddf' & !`dispview' & !`slackview') | "`draw_radialin'`draw_radialout'`draw_weights'" != "" local heading `"`heading' "`score'""'
                    if `ddf' {
                        local beta = strtrim(string(`distances'[`i',1], "%9.4g"))
                        local dirpair = strtrim(string(`dirx', "%9.4g")) + ", " + strtrim(string(`diry', "%9.4g"))
                        local heading `"`heading' "{&beta} = `beta'     (g{sub:x}, g{sub:y}) = (`dirpair')""'
                    }
                }
                if "`draw_weights'" != "" {
                    local values
                    forvalues j = 1/3 {
                        local term : word `j' of v u w
                        local value = strtrim(string(`multipliers'[`i',`j'],"%9.4g"))
                        local values "`values'   {it:`term'} = `value'"
                    }
                    local heading `"`heading' "`values'""'
                }
                label define `panellabel' `i' `"`heading'"', add
            }
            label values panel `panellabel'
        }
        if "`draw_lambda'" != "" {
            tempvar weightlabel labelpos
            gen str40 `weightlabel' = "{&lambda}=" + strtrim(string(weight,"%9.4g")) if !missing(weight)
            gen byte `labelpos' = cond(`ox' >= .2*`xlimit', 10, 2)
        }
    }

    if `scaleview' {
        local scorecol = cond("`orientation'"=="input",2,5)
        tempname se
        scalar `se' = `scores'[1,`scorecol']/`scores'[2,`scorecol']
        local crste = strtrim(string(`scores'[1,`scorecol'],"%5.3f"))
        local vrste = strtrim(string(`scores'[2,`scorecol'],"%5.3f"))
        local sedisplay = strtrim(string(`se',"%5.3f"))
        // Compare full-precision scores relative to VRS, also for very small TE.
        local regime irs
        if abs(1-`se') <= 1e-10 local regime crs
        else if abs(1-`nirste'/`scores'[2,`scorecol']) <= 1e-10 local regime drs
        local returns = cond("`regime'"=="crs","Constant",cond("`regime'"=="irs","Increasing","Decreasing"))
        local heading = proper("`orientation'") + " orientation"
        local graphopts title(, position(11) span size(medlarge)) `title' ///
            subtitle("`heading'     `returns' returns at the VRS target" ///
                "CRS TE = `crste'     VRS TE = `vrste'     SE = `sedisplay'", ///
                position(11) span size(small)) graphregion(color(white))
        local px tx
        local py fy
        if "`orientation'" == "output" {
            local px fx
            local py ty
        }
        local plots (line by bx if panel==2, lcolor(black) lwidth(medthick)) ///
            (line by bx if panel==1, lpattern(dash) lcolor(gs6) lwidth(medthick)) ///
            (pcspike fy fx `py' `px' if panel==1 & `selected'==1, lcolor(gs7) lpattern(shortdash) lwidth(medium)) ///
            (scatter `oy' `ox' if panel==1, msymbol(O) msize(small) mcolor(black) ///
                mlabel(`labs') mlabposition(4) mlabcolor(black)) ///
            (scatter `oy' `ox' if panel==1 & `selected', msymbol(Oh) msize(vlarge) mcolor(black)) ///
            (scatter `py' `px' if panel==1, msymbol(Sh) msize(medlarge) mcolor(black)) ///
            (scatter `py' `px' if panel==2, msymbol(Dh) msize(small) mcolor(black))
        local order 2 "CRS frontier" 1 "VRS frontier" 5 "Selected DMU" 6 "CRS target" 7 "VRS target"
        local size xsize(6.4) ysize(5.6)
        local legendspan span
    }
    else {
        // All layers use grey levels explicitly, including arrowheads and labels.
        local plots
        local order
        local n 0
        if "`draw_pps'" != "" {
            local height top
            local xpos bx
            local region "Feasible set"
            if `superview' {
                local height reftop
                local xpos refx
                local region "Peer technology"
            }
            local plots (rarea floor `height' `xpos' if !missing(`xpos',`height'), fcolor(gs15) fintensity(100) lwidth(none))
            local order `++n' "`region'"
        }
        if `dispview' {
            local plots `plots' (rarea floor dispy dispx if !missing(dispx), fcolor(gs12) fintensity(100) lwidth(none))
            local order `order' `++n' "Free disposal from selected DMU"
        }
        if "`draw_frontier'" != "" {
            local plots `plots' (line by bx, lcolor(black) lpattern(solid) lwidth(medthick))
            local boundary "Boundary"
            if `superview' local boundary "Full frontier"
            local order `order' `++n' "`boundary'"
            if `superview' {
                local plots `plots' (line refy refx, lcolor(gs6) lwidth(medthick) lpattern(dash))
                local order `order' `++n' "Peer frontier"
            }
        }
        if `slackview' {
            quietly count if targetface==1
            if r(N) {
                local plots `plots' (line ay ax if targetface==1, lcolor(gs6) lwidth(thick) lpattern(dash))
                local order `order' `++n' "Optimal segment"
            }
        }
        if "`draw_targetslacks'" != "" {
            local saving ax<slackx0 & !missing(slackx0)
            local gain ay>slacky0 & !missing(slacky0)
            // Follow the scored direction first, then the remaining slack.
            local xs slacky0 slackx0 slacky0 ax
            local ys slacky0 ax ay ax
            local xstyle lcolor(gs4) mcolor(gs4) lpattern(shortdash)
            local ystyle `xstyle'
            if `orientedsbm' {
                if "`orientation'"=="input" local xstyle lcolor(black) mcolor(black) lpattern(solid)
                else {
                    local ys slacky0 slackx0 ay slackx0
                    local xs ay slackx0 ay ax
                    local ystyle lcolor(black) mcolor(black) lpattern(solid)
                }
            }
            local plots `plots' (pcspike `xs' if `saving', lcolor(white) lwidth(medthick)) ///
                (pcspike `ys' if `gain', lcolor(white) lwidth(medthick)) ///
                (pcarrow `xs' if `saving', `xstyle') (pcarrow `ys' if `gain', `ystyle')
            local n = `n'+2
            if `orientedsbm' {
                local xkey = `n'+1
                local ykey = `n'+2
                local primary = cond("`orientation'"=="input",`xkey',`ykey')
                local residual = cond("`orientation'"=="input",`ykey',`xkey')
                local primaryif = cond("`orientation'"=="input","`saving'","`gain'")
                local residualif = cond("`orientation'"=="input","`gain'","`saving'")
                quietly count if `primaryif'
                if r(N) local order `order' `primary' "Scored change"
                quietly count if `residualif'
                if r(N) local order `order' `residual' "Residual slack"
                local n = `n'+2
                if `k'==1 local legendgrid cols(2)
            }
            else {
                local order `order' `++n' "Slack adjustments"
                local ++n
            }
        }
        if `mixview' {
            local plots `plots' (line `oy' `ox' if inlist(`endpoints',1,2), ///
                lpattern(dash) lcolor(gs7) lwidth(medthick))
            local order `order' `++n' "Mixtures of the pair"
        }
        if "`draw_weights'" != "" {
            local plots `plots' (line wy wx, lcolor(gs6) lpattern(dash) lwidth(medthick))
            local order `order' `++n' "Supporting line"
        }
        if "`draw_superradial'"!="" {
            quietly count if !missing(superx,supery)
            if r(N) {
                local plots `plots' (pcarrow `oy' `ox' supery superx if !missing(superx,supery) & ///
                    (superx!=`ox' | supery!=`oy'), lcolor(black) mcolor(black)) ///
                    (scatter supery superx, msymbol(Dh) msize(large) mcolor(black))
                local ++n
                local order `order' `++n' "Peer target"
            }
        }
        if "`draw_radialin'" != "" {
            local plots `plots' (pcarrow fy fx fy tx if tx < fx, lcolor(black) mcolor(black) lpattern(solid))
            local order `order' `++n' "Input contraction"
        }
        if "`draw_radialout'" != "" {
            local plots `plots' (pcarrow fy fx ty fx if ty > fy, lcolor(gs4) mcolor(gs4) lpattern(dash))
            local order `order' `++n' "Output expansion"
        }
        if `ddf' {
            local plots `plots' (pcarrow fy fx dy dx if !missing(dx) & (dx<fx | dy>fy), ///
                lpattern(longdash) lcolor(black) mcolor(black))
            local ++n
        }
        if "`draw_slacks'" != "" {
            local moved !missing(rx) & (rx!=sx | ry!=sy)
            local plots `plots' (pcspike ry rx sy sx if `moved', lwidth(thick) lcolor(white))
            local ++n
            local plots `plots' (pcarrow ry rx sy sx if `moved', ///
                lpattern(dash) lwidth(medthick) lcolor(gs6) mcolor(gs4))
            local order `order' `++n' "Slack adjustment"
        }
        if `showtarget' {
            local plots `plots' (scatter ry rx, msymbol(Dh) msize(medium) mcolor(black))
            local order `order' `++n' "`=proper("`orientation'")' radial target"
        }
        local ml
        if "`labs'" != "" local ml mlabel(`labs') mlabcolor(black) mlabposition(4)
        if `superview' {
            tempvar superpos
            quietly gen byte `superpos' = cond(`selected'==1,10,4)
            local ml mlabel(`labs') mlabcolor(black) mlabvposition(`superpos')
        }
        if `slackview' local ml mlabel(`labs') mlabcolor(black) mlabposition(10) mlabgap(small)
        if `ddf' local ml mlabel(`labs') mlabcolor(black) mlabvposition(`ddflabpos')
        local plots `plots' (scatter `oy' `ox', msymbol(O) msize(small) mcolor(black) `ml')
        local order `order' `++n' "Observed DMU"
        if `mixview' {
            local plots `plots' (scatter mixy mixx, msymbol(Dh) msize(large) mcolor(black))
            local order `order' `++n' "Chosen mixture"
        }
        if `"`focus'"' != "" {
            local plots `plots' (scatter `oy' `ox' if `selected' == 1, msymbol(Oh) msize(large) mcolor(black))
            local order `order' `++n' "Selected DMU"
        }
        if `slackview' {
            local plots `plots' (scatter ay ax, msymbol(Dh) msize(vlarge) mcolor(black))
            local order `order' `++n' "Optimal target"
        }
        if "`plan'" != "" {
            local plots `plots' (scatter plany planx, msymbol(Dh) msize(vlarge) mcolor(black))
            local order `order' `++n' "Proposed plan"
        }
        if "`draw_peers'" != "" {
            local wl
            if "`draw_lambda'" != "" local wl mlabel(`weightlabel') mlabvposition(`labelpos') mlabsize(small) mlabcolor(black)
            local plots `plots' (scatter `oy' `ox' if !missing(weight), msymbol(Th) ///
                msize(medlarge) mcolor(black) `wl')
            local order `order' `++n' "Reference DMU"
        }
        if `ddf' {
            local plots `plots' (scatter dy dx, msymbol(Sh) msize(medlarge) mcolor(black))
            local order `order' `++n' "Directional target"
            if `k' == 1 & `n' >= 8 local legendgrid cols(3)
        }
        local size
        local panelnote note("")
        if "`view'"=="additive" local panelnote note("Input weight = `:word 1 of `slackweights''     Output weight = `:word 2 of `slackweights''", size(small))
        if "`view'"=="sbm" & !`orientedsbm' & "`draw_targetslacks'"!="" {
            local panelnote note("Slack percentages use the observed DMU as the base. Arrows show the smallest-input optimum.", size(small))
        }
        if `ddf' & `k' == 1 local size xsize(6.4) ysize(5.6)
        if `k' > 1 local size xsize(9) ysize(4.9)
        if "`view'"=="sbm" & `k'>1 local size xsize(9) ysize(6.2)
        if `superview' {
            local legendgrid cols(3)
            if `k'==1 local legendgrid cols(2)
        }
        local graphopts by(panel, cols(`k') iyaxes imargin(medsmall) `panelnote' ///
                title(, position(11) span size(medlarge) color(black)) `title' ///
                legend(position(6)) graphregion(color(white))) ///
            subtitle(, span nobox bcolor(none) lcolor(none) margin(b=2) size(medsmall))
    }
    twoway `plots', `graphopts' ///
        `xtitle' `ytitle' xscale(range(0 `xlimit') line noextend lwidth(thin)) ///
        yscale(range(0 `ylimit') line noextend lwidth(thin)) ///
        xlabel(0(`xstep')`xlimit', nogrid labsize(small)) ///
        ylabel(0(`ystep')`ylimit', nogrid labsize(small) angle(horizontal)) ///
        aspectratio(`=`ylimit'/`xlimit'') plotregion(style(none) margin(zero)) ///
        legend(order(`order') `legendgrid' `legendspan' size(small) region(lstyle(none))) scheme(s1mono) `size' `name'

    restore
    return scalar N = `N'
    return local technologies "`models'"
    if `superview' {
        matrix rownames `superresults' = `models'
        matrix colnames `superresults' = full_score factor score x_target y_target feasible
        if `k'==1 return scalar super_score = `superresults'[1,3]
        return matrix super = `superresults'
        return scalar N_ref = `N'-1
        return local orientation "`orientation'"
    }
    if "`view'"=="sbm" {
        matrix colnames `slacktargets' = x_target y_target s_input s_output rel_input rel_output rho
        if `k'==1 return scalar rho = `slacksummary'[1,1]
        return local orientation "`orientation'"
        return matrix sbm = `slacktargets'
    }
    if "`view'"=="additive" {
        matrix colnames `slacktargets' = x_target y_target s_input s_output objective
        return matrix additive = `slacktargets'
        return scalar w_input = `:word 1 of `slackweights''
        return scalar w_output = `:word 2 of `slackweights''
    }
    if `dispview' {
        matrix rownames `disposal' = `models'
        matrix colnames `disposal' = x_focus y_focus x_plan y_plan from_focus y_max feasible
        return matrix disposal = `disposal'
    }
    if `mixview' {
        matrix rownames `mixtures' = `models'
        matrix colnames `mixtures' = share1 share2 x_mix y_mix y_max feasible
        return matrix mixture = `mixtures'
        return local first `"`first'"'
        return local second `"`second'"'
    }
    if `ddf' {
        matrix rownames `distances' = `models'
        matrix colnames `distances' = beta gx gy x_target y_target
        return matrix ddf = `distances'
    }
    if `scaleview' {
        return local rts "`regime'"
        return scalar te_nirs = `nirste'
        return scalar se = `se'
        return scalar te_crs = `scores'[1,`scorecol']
        return scalar te_vrs = `scores'[2,`scorecol']
        return local orientation "`orientation'"
    }
    if "`draw_weights'" != "" {
        matrix colnames `multipliers' = v u w objective
        matrix rownames `multipliers' = `models'
        return matrix multipliers = `multipliers'
        return local orientation "`orientation'"
    }
    if `reference' {
        matrix colnames `peers' = obs lambda x y
        matrix colnames `benchmarks' = x_radial y_radial x_final y_final s_input s_output
        matrix rownames `benchmarks' = `models'
        return matrix peers = `peers'
        return matrix benchmarks = `benchmarks'
        return local ref_orientation "`orientation'"
    }
    if `"`focus'"' != "" {
        matrix rownames `scores' = `models'
        matrix colnames `scores' = x_input theta y_output phi eff_output
        return matrix projections = `scores'
    }
end

program define _graphdea_mpioverview, rclass
    version 16.0
    syntax varlist(min=2 max=3 numeric) if, NINPUTS(integer) DMU(varname) TIME(varname numeric) ///
        PERiods(string) ORientation(string) [DECompose TOP(integer 0) ///
        NAME(passthru) TItle(passthru) XTItle(passthru) YTItle(passthru)]
    local multi = (`:word count `varlist''==3)
    gettoken base later : periods
    local fmt : format `time'
    local first = strtrim(string(`base',"`fmt'"))
    local last = strtrim(string(`later',"`fmt'"))
    if "`first'"=="`last'" {
        local first = strtrim(string(`base',"%24.17g"))
        local last = strtrim(string(`later',"%24.17g"))
    }
    if `"`title'"'=="" local title title("{stSerif:Malmquist productivity change by DMU}")
    if `"`xtitle'"'=="" local xtitle xtitle("Change factor")
    if `"`ytitle'"'=="" local ytitle ytitle("")

    preserve
    tempvar original second paired other mi ec tc pure scale label stub position
    quietly gen long `original' = _n
    quietly keep `if'
    quietly gen byte `second' = `time'==`later'
    quietly count if !`second'
    local nbase = r(N)
    local nfollow = _N-`nbase'
    capture isid `dmu' `second'
    if _rc {
        di as err "overview requires one complete observation per DMU and period"
        exit 459
    }
    bysort `dmu' (`second'): gen byte `paired' = _N==2
    quietly count if `paired' & !`second'
    local matched = r(N)
    if !`matched' {
        di as err "no complete DMU is observed in both selected periods"
        exit 459
    }
    quietly by `dmu': gen long `other' = `original'[2] if `paired'
    local factorvars `mi' `ec' `tc'
    local columns base_obs followup_obs malmquist efficiency_change technical_change
    if "`decompose'"!="" {
        local factorvars `factorvars' `pure' `scale'
        local columns `columns' pure_efficiency_change scale_efficiency_change
    }
    foreach v of local factorvars {
        quietly gen double `v' = .
    }
    mata: _graphdea_mpioverviewcalc()
    quietly keep if `paired' & !`second'
    gsort -`mi' +`dmu'
    capture confirm string variable `dmu'
    if !_rc quietly clonevar `label' = `dmu'
    else {
        local idlabels : value label `dmu'
        if "`idlabels'"!="" {
            quietly decode `dmu', gen(`label')
            quietly replace `label'=strtrim(string(`dmu',"%24.17g")) if missing(`label')
        }
        else quietly gen str24 `label' = strtrim(string(`dmu',"%24.17g"))
    }
    quietly gen str128 `stub' = ustrtoname(`label')
    tempname results axislabels
    quietly mkmat `original' `other' `factorvars', matrix(`results') rownames(`stub')
    matrix colnames `results' = `columns'
    if `top'>0 quietly keep in 1/`=min(`top',`matched')'
    local shown = _N
    quietly gen long `position' = _n
    mata: st_vlmodify(st_local("axislabels"),st_data(.,st_local("position")),st_sdata(.,st_local("label")))
    label values `position' `axislabels'
    local high = `shown'+.5
    local height = min(16,max(3.7,1.9+.40*`shown'))
    local legendrows = cond("`decompose'"=="",1,2)
    local layers (scatter `position' `mi', msymbol(O) mcolor(black) msize(medium))
    local componentrow `position'
    local scalerow `position'
    if `multi' {
        tempvar tcrow ecrow serow
        quietly gen double `tcrow' = `position'-.20
        quietly gen double `ecrow' = `position'+.20
        quietly gen double `serow' = `position'+.36
        local componentrow `ecrow'
        local scalerow `serow'
        local layers `layers' (scatter `tcrow' `tc', msymbol(Dh) mcolor(gs5) msize(medlarge))
        local tclabel "Technical change"
    }
    else {
        local shift = `tc'[1]
        local shiftlabel = strtrim(string(`shift',"%9.4g"))
        local layers `layers' (pci .5 `shift' `high' `shift', lcolor(gs6) lpattern(dash))
        local tclabel "Technical change (`shiftlabel')"
    }
    if "`decompose'"=="" {
        local layers `layers' (scatter `componentrow' `ec', msymbol(Sh) mcolor(gs4) msize(large))
        local order 1 "Productivity" 3 "Efficiency change" 2 "`tclabel'"
    }
    else {
        local layers `layers' (scatter `componentrow' `pure', msymbol(Sh) mcolor(gs4) msize(large)) ///
            (scatter `scalerow' `scale', msymbol(Th) mcolor(gs6) msize(medlarge))
        local order 1 "Productivity" 3 "Pure efficiency change" 4 "Scale efficiency change" 2 "`tclabel'"
    }
    local coverage "`matched' matched DMUs"
    if `matched'==1 local coverage "1 matched DMU"
    if `shown'<`matched' local coverage "Highest `shown' of `matched' matched DMUs"
    twoway `layers', title(, position(11) span size(medlarge)) `title' ///
        subtitle("`first' to `last'     `=proper("`orientation'")' orientation     `coverage'", ///
            position(11) span size(small)) `xtitle' `ytitle' ///
        ylabel(1(1)`shown', valuelabel angle(horizontal) noticks nogrid labsize(small)) ///
        xlabel(, nogrid labsize(small)) yscale(reverse range(.5 `high') noline) ///
        xscale(range(1) line noextend) xline(1, lpattern(dot) lcolor(gs8)) ///
        legend(order(`order') rows(`legendrows') size(small) region(lstyle(none))) ///
        graphregion(color(white)) plotregion(style(none)) xsize(7.5) ysize(`height') scheme(s1mono) `name'
    restore
    return matrix overview = `results'
    return scalar N_base = `nbase'
    return scalar N_followup = `nfollow'
    return scalar N = `nbase'+`nfollow'
    return scalar N_matched = `matched'
    return scalar N_shown = `shown'
    return scalar base = `base'
    return scalar followup = `later'
    if !`multi' return scalar technical_change = `shift'
    return local orientation "`orientation'"
    return local dmu "`dmu'"
    local tech crs
    if "`decompose'"!="" local tech crs vrs
    return local technologies "`tech'"
end

program define _graphdea_mpichain, rclass
    version 16.0
    syntax varlist(min=2 max=3 numeric) if, NINPUTS(integer) TIME(varname numeric) SELECTED(varname) ///
        FOCus(string) ORientation(string) BENchmark(string) [PERiods(string) DECompose ///
        NAME(passthru) TItle(passthru) XTItle(passthru) YTItle(passthru)]
    local fmt : format `time'
    local timelabel : variable label `time'
    if `"`timelabel'"'=="" local timelabel `time'
    if `"`xtitle'"'=="" local xtitle `"xtitle("`timelabel'")"'
    if `"`ytitle'"'=="" local ytitle ytitle("Change factor")
    local heading "Malmquist productivity change"
    local shift technical_change
    local shiftlabel "Technical change"
    if "`benchmark'"=="global" {
        local heading "Global Malmquist productivity change"
        local shift best_practice_change
        local shiftlabel "Best practice change"
    }
    if `"`title'"'=="" local title title("{stSerif:`heading'}")

    preserve
    quietly keep `if'
    local N = _N
    if "`benchmark'"=="global" {
        local context "     `N' pooled observations"
        local yticks #8
    }
    sort `time'
    tempname links cum data scores
    mata: _graphdea_mpichaincalc()
    local k = rowsof(`links')
    local reverse
    if `links'[1,1]>`links'[`k',1] local reverse reverse
    local columns period n_ref malmquist efficiency_change `shift'
    if "`decompose'"!="" local columns `columns' pure_efficiency_change scale_efficiency_change
    matrix colnames `links' = `columns'
    matrix colnames `cum' = `columns'
    matrix `data' = `links' \ `cum'
    clear
    quietly svmat double `data', names(col)
    tempvar panel
    quietly gen byte `panel' = _n>`k'
    tempname panels
    local cumulative_label "Since base period"
    if "`benchmark'"=="contemporaneous" & `:word count `varlist''==3 local cumulative_label "Chained since base period"
    label define `panels' 0 "Since preceding period" 1 "`cumulative_label'"
    label values `panel' `panels'
    local nticks = min(`k',6)
    local angle = 0
    forvalues j=1/`nticks' {
        local row = 1+round((`j'-1)*(`k'-1)/(`nticks'-1))
        local tick : display %24.17g period[`row']
        local ticks `ticks' `tick'
        if strlen(strtrim(string(period[`row'],"`fmt'")))>5 local angle = 45
    }
    local plots (connected malmquist period, msymbol(O) msize(medsmall) ///
        lcolor(black) mcolor(black) lwidth(medthick)) ///
        (connected `shift' period, msymbol(Th) msize(medium) ///
        lpattern(dash) lcolor(gs5) mcolor(gs5))
    local legendrows = cond("`decompose'"=="",1,2)
    local order 1 "Productivity" 2 "`shiftlabel'"
    if "`decompose'"=="" {
        local plots `plots' (connected efficiency_change period, msymbol(Sh) ///
            lpattern(shortdash) lcolor(gs3) mcolor(gs3))
        local order `order' 3 "Efficiency change"
    }
    else {
        local plots `plots' (connected pure_efficiency_change period, msymbol(Sh) ///
            lpattern(shortdash) lcolor(gs3) mcolor(gs3)) ///
            (connected scale_efficiency_change period, msymbol(Dh) ///
            lpattern(longdash_dot) lcolor(gs6) mcolor(gs6))
        local order `order' 3 "Pure efficiency change" 4 "Scale efficiency change"
    }
    twoway `plots', by(`panel', cols(2) iyaxes title(, position(11) span size(medlarge)) `title' ///
        subtitle(`"Focus (`focus')     `=proper("`orientation'")' orientation`context'"', position(11) span size(small)) ///
        legend(position(6)) note("") graphregion(color(white))) ///
        subtitle(, nobox bcolor(none) lcolor(none) size(medsmall)) ///
        xlabel(`ticks', format(`fmt') nogrid labsize(small) angle(`angle')) ylabel(`yticks', angle(horizontal) nogrid labsize(small)) ///
        xscale(`reverse' line noextend) yscale(line noextend) yline(1, lwidth(thin) lpattern(dot) lcolor(gs8)) ///
        `xtitle' `ytitle' legend(order(`order') rows(`legendrows') size(small) region(lstyle(none))) ///
        plotregion(style(none)) graphregion(color(white)) xsize(8.2) ysize(4.8) scheme(s1mono) `name'
    restore
    return scalar N = `N'
    return scalar N_periods = `k'
    return scalar N_base = `cum'[1,2]
    return scalar N_followup = `cum'[`k',2]
    return scalar base = `cum'[1,1]
    return scalar followup = `cum'[`k',1]
    foreach component of local columns {
        if !inlist("`component'","period","n_ref") {
            return scalar `component' = `cum'[`k',colnumb(`cum',"`component'")]
        }
    }
    if "`benchmark'"=="global" {
        local levelnames period n_ref te_global te_period best_practice_ratio
        if "`decompose'"!="" local levelnames `levelnames' te_vrs scale_eff
        matrix colnames `scores' = `levelnames'
        return matrix global_levels = `scores'
    }
    return local benchmark "`benchmark'"
    return local orientation "`orientation'"
    local tech crs
    if "`decompose'"!="" local tech crs vrs
    return local technologies "`tech'"
    return matrix chain = `links'
    return matrix cumulative = `cum'
end

program define _graphdea_malmquist, rclass
    version 16.0
    syntax varlist(min=2 max=3 numeric) if, NINPUTS(integer) TIME(varname numeric) PERiods(string) ///
        SELECTED(varname) FOCus(string) ORientation(string) [DECompose NAME(passthru) TItle(passthru) XTItle(passthru) YTItle(passthru)]
    gettoken x y : varlist
    local multi = (`:word count `varlist''==3)
    if `multi' {
        local denom : word `=cond(`ninputs'==1,1,3)' of `varlist'
        local x : word `=cond(`ninputs'==1,2,1)' of `varlist'
        local y : word `=cond(`ninputs'==1,3,2)' of `varlist'
        local denlabel : variable label `denom'
        if `"`denlabel'"'=="" local denlabel `denom'
    }
    gettoken base later : periods
    local fmt : format `time'
    local first = strtrim(string(`base',"`fmt'"))
    local last = strtrim(string(`later',"`fmt'"))
    if "`first'"=="`last'" {
        local first = strtrim(string(`base',"%24.17g"))
        local last = strtrim(string(`later',"%24.17g"))
    }
    foreach axis in x y {
        if `"``axis'title'"'=="" {
            local axislabel : variable label ``axis''
            if `"`axislabel'"'=="" local axislabel ``axis''
            if `multi' local axislabel `"`axislabel' / `denlabel'"'
            local `axis'title `"`axis'title("`axislabel'")"'
        }
    }
    if `"`title'"'=="" {
        local heading "Malmquist productivity change"
        if "`decompose'"!="" local heading "Malmquist efficiency decomposition"
        if !`multi' & "`orientation'"=="input" local heading "Input-oriented `heading'"
        local title title("{stSerif:`heading'}")
    }

    preserve
    quietly keep `if'
    tempvar second
    quietly gen byte `second' = `time'==`later'
    quietly count if `second'==0
    local nbase = r(N)
    local nfollow = _N-`nbase'
    tempname distances changes
    if "`decompose'"!="" tempname levels
    if `multi' {
        tempname targets
        tempvar panel bx by lx ly rx ry ox oy btx bty ltx lty
        local plotvars `panel' `bx' `by' `lx' `ly' `rx' `ry' `ox' `oy' `btx' `bty' `ltx' `lty'
        if "`decompose'"!="" {
            tempvar vtx vty
            local plotvars `plotvars' `vtx' `vty'
        }
        foreach v of local plotvars {
            quietly gen double `v' = .
        }
        mata: _graphdea_mpidiagram()
        quietly keep if !missing(`panel')
    }
    else {
        tempname ends focusxy
        tempvar crstarget
        quietly gen double `crstarget' = .
        if "`decompose'"!="" {
            tempvar vx vy cx cy vrstarget
            foreach v in vx vy cx cy vrstarget {
                quietly gen double ``v'' = .
            }
        }
        local span `y' `crstarget' `x'
        local crscoords `crstarget' `x'
        local vrscoords `vrstarget' `x'
        if "`orientation'"=="input" {
            local span `x' `crstarget' `y'
            local horizontal horizontal
            local crscoords `y' `crstarget'
            local vrscoords `y' `vrstarget'
        }
        mata: _graphdea_mpicalc()
    }
    local ec = strtrim(string(`changes'[1,1],"%9.4g"))
    local tc = strtrim(string(`changes'[1,2],"%9.4g"))
    local mi = strtrim(string(`changes'[1,3],"%9.4g"))
    local axes xlabel(0(`xstep')`xlimit', nogrid labsize(small)) ylabel(0(`ystep')`ylimit', nogrid angle(horizontal) labsize(small)) ///
        xscale(range(0 `xlimit') line noextend) yscale(range(0 `ylimit') line noextend) ///
        aspectratio(`=`ylimit'/`xlimit'') plotregion(style(none) margin(zero)) graphregion(color(white))
    if `multi' {
        tempname panels
        label define `panels' 0 "`first' observation" 1 "`last' observation"
        label values `panel' `panels'
        local sub `""`focus'     `=proper("`orientation'")' orientation" "Efficiency change = `ec'     Technical change = `tc'     Malmquist = `mi'""'
        local order 2 "`first' CRS frontier" 3 "`last' CRS frontier" 6 "Observed mix" 4 "`first' target" 5 "`last' target"
        if "`decompose'"!="" {
            local pure = strtrim(string(`levels'[2,1]/`levels'[1,1],"%9.4g"))
            local se = strtrim(string(`levels'[2,3]/`levels'[1,3],"%9.4g"))
            local sub `"`sub' "Pure efficiency change = `pure'     Scale efficiency change = `se'""'
            local vrsplot (scatter `vty' `vtx', msymbol(Dh) mcolor(gs5) msize(vlarge))
            local order 2 "`first' CRS frontier" 3 "`last' CRS frontier" 7 "Observed mix" 4 "`first' target" 5 "`last' target" 6 "Own VRS target"
        }
        twoway (line `ry' `rx', lcolor(gs9) lpattern(dot)) ///
            (line `by' `bx', lcolor(black) lwidth(medthick)) ///
            (line `ly' `lx', lcolor(gs5) lpattern(longdash) lwidth(medthick)) ///
            (scatter `bty' `btx', msymbol(Sh) mcolor(black) msize(large)) ///
            (scatter `lty' `ltx', msymbol(Th) mcolor(gs4) msize(medlarge)) ///
            `vrsplot' (scatter `oy' `ox', msymbol(O) mcolor(black) msize(small)), ///
            by(`panel', cols(2) iyaxes title(, position(11) span size(medlarge)) `title' ///
                subtitle(`sub', position(11) span size(small)) legend(position(6)) note("") graphregion(color(white))) ///
            subtitle(, nobox bcolor(none) lcolor(none) size(medsmall)) `xtitle' `ytitle' `axes' ///
            legend(order(`order') cols(3) size(small) region(lstyle(none))) xsize(8.2) ysize(5.8) scheme(s1mono) `name'
    }
    else if "`decompose'"=="" {
        local ray1 `=`ends'[1,2]' `=`ends'[1,1]'
        local ray2 `=`ends'[2,2]' `=`ends'[2,1]'
        local path `=`focusxy'[1,2]' `=`focusxy'[1,1]' `=`focusxy'[2,2]' `=`focusxy'[2,1]'
        tempvar panel
        quietly gen byte `panel' = 1
        twoway (pci 0 0 `ray1', lcolor(black) lwidth(medthick)) ///
            (pci 0 0 `ray2', lcolor(gs5) lpattern(longdash) lwidth(medthick)) ///
            (rspike `span' if `selected', `horizontal' lpattern(shortdash) lcolor(gs7)) ///
            (scatter `y' `x' if !`second', msymbol(Oh) mcolor(gs5) msize(medsmall)) ///
            (scatter `y' `x' if `second', msymbol(Th) mcolor(gs5) msize(medium)) ///
            (pcarrowi `path', lcolor(black) mcolor(black) lwidth(medthick)) ///
            (scatter `crscoords' if `selected', msymbol(+) mcolor(black) msize(large)) ///
            (scatter `y' `x' if `selected' & !`second', msymbol(O) mcolor(black) msize(small)) ///
            (scatter `y' `x' if `selected' & `second', msymbol(T) mcolor(black) msize(small)), ///
            by(`panel', iytitle ixtitle l1title("") b1title("") title(, position(11) span size(medlarge)) `title' ///
                subtitle("Efficiency change = `ec'     Technical change = `tc'     Malmquist = `mi'", ///
                    position(11) span size(small)) legend(position(6)) note("") graphregion(color(white))) ///
            subtitle("") `xtitle' `ytitle' ///
            `axes' ///
            legend(order(1 "`first' frontier" 2 "`last' frontier" 6 `"`focus': `first' to `last'"' ///
                4 "`first' observations" 5 "`last' observations" 7 "Own-period target") ///
                cols(3) size(small) region(lstyle(none))) xsize(7) ysize(6) scheme(s1mono) `name'
    }
    else {
        local pure = strtrim(string(`levels'[2,4]/`levels'[1,4],"%9.4g"))
        local se = strtrim(string(`levels'[2,6]/`levels'[1,6],"%9.4g"))
        tempname years
        label define `years' 0 "`first'" 1 "`last'"
        label values `second' `years'
        twoway (line `vy' `vx', lcolor(black) lwidth(medthick)) ///
            (line `cy' `cx', lcolor(gs5) lpattern(longdash) lwidth(medthick)) ///
            (rspike `span' if `selected'==1, `horizontal' lcolor(gs7) lpattern(shortdash)) ///
            (scatter `y' `x', msymbol(Oh) mcolor(gs5) msize(medsmall)) ///
            (scatter `crscoords' if `selected'==1, msymbol(Sh) mcolor(black) msize(vlarge)) ///
            (scatter `vrscoords' if `selected'==1, msymbol(Dh) mcolor(black) msize(large)) ///
            (scatter `y' `x' if `selected'==1, msymbol(O) mcolor(black) msize(medsmall)), ///
            by(`second', cols(2) iyaxes title(, position(11) span size(medlarge)) `title' ///
                subtitle("Pure efficiency change = `pure'     Scale efficiency change = `se'" ///
                    "Efficiency change = `ec'     Technical change = `tc'     Malmquist = `mi'", position(11) span size(small)) ///
                legend(position(6)) note("") graphregion(color(white))) ///
            subtitle(, nobox bcolor(none) lcolor(none) size(medsmall)) `xtitle' `ytitle' `axes' ///
            legend(order(1 "VRS frontier" 2 "CRS frontier" 4 "Observed DMU" ///
                6 "VRS target" 5 "CRS target" 7 `"Focus (`focus')"' ) cols(3) size(small) region(lstyle(none))) ///
            xsize(8.2) ysize(5.8) scheme(s1mono) `name'
    }
    restore
    matrix rownames `distances' = base_obs followup_obs
    matrix colnames `distances' = base_tech followup_tech
    return matrix distances = `distances'
    if `multi' {
        matrix rownames `targets' = base_obs followup_obs
        if "`decompose'"!="" local vcols vrs_1 vrs_2
        matrix colnames `targets' = observed_1 observed_2 base_1 base_2 followup_1 followup_2 `vcols'
        return matrix ratio_targets = `targets'
    }
    return scalar efficiency_change = `changes'[1,1]
    return scalar technical_change = `changes'[1,2]
    return scalar malmquist = `changes'[1,3]
    return scalar base = `base'
    return scalar followup = `later'
    return scalar N = `nbase'+`nfollow'
    return scalar N_base = `nbase'
    return scalar N_followup = `nfollow'
    return local orientation "`orientation'"
    if "`decompose'"!="" {
        matrix rownames `levels' = base followup
        if `multi' matrix colnames `levels' = te_vrs te_crs scale_eff
        else {
            local axis = cond("`orientation'"=="input","x","y")
            matrix colnames `levels' = `axis'_observed `axis'_vrs `axis'_crs te_vrs te_crs scale_eff
        }
        return scalar pure_efficiency_change = `levels'[2,"te_vrs"]/ `levels'[1,"te_vrs"]
        return scalar scale_efficiency_change = `levels'[2,"scale_eff"]/ `levels'[1,"scale_eff"]
        return matrix period_efficiency = `levels'
        return local technologies "crs vrs"
    }
    else return local technologies crs
end

* Shared renderer for two-dimensional fixed-input and fixed-output sets.
program define _graphdea_section, rclass
    version 16.0
    syntax varlist(min=3 max=3 numeric) if, SELECTED(varname) VIEW(string) [Model(string) SURface SECTIONFill ///
        AZimuth(real 45) ELevation(real 35.264389682754654) ///
        RTS(string) Compare(string) AT(string) PRices(varlist numeric min=2 max=2) Show(string) ///
        PLAN(numlist min=2 max=2 >=0) NAME(passthru) TItle(passthru) XTItle(passthru) YTItle(passthru)]

    tokenize `varlist'
    local axis1 `1'
    local axis2 `2'
    local fixed `3'
    if inlist("`view'","outputset","weakdisposal") {
        local quantity output
        local fixedtype input
        local priceopt p
        local radialalias radialout
        local optimum revenuemax
        local isoline isorevenue
        local linelegend "Maximum-revenue line"
        local money revenue
        local econ re
        local tag3 M
        local point3 "M = revenue maximum"
        local rayend 2
        local heading "Output possibilities at fixed input"
    }
    else {
        local quantity input
        local fixedtype output
        local priceopt w
        local radialalias radialin
        local optimum costmin
        local isoline isocost
        local linelegend "Minimum-cost line"
        local money cost
        local econ ce
        local tag3 C
        local point3 "C = cost minimum"
        local rayend 1
        local heading "Input requirements at fixed output"
    }
    if "`compare'" != "" {
        if "`rts'" != "" | !inlist("`model'","","te","allocative") {
            di as err "compare() supplies the technologies; use w() or p() for economic efficiency"
            exit 198
        }
        local technologies : list retokenize compare
        local unique : list uniq technologies
        if "`technologies'" != "`unique'" {
            di as err "each comparison technology must appear once"
            exit 198
        }
        foreach tech of local technologies {
            if !inlist("`tech'","crs","vrs","fdh") {
                di as err "compare() accepts crs, vrs, and fdh"
                exit 198
            }
        }
    }
    else if "`model'" == "fdh" {
        if "`rts'" != "" {
            di as err "model(fdh) supplies its own technology; omit rts()"
            exit 198
        }
        local rts fdh
    }
    else {
        if "`rts'" == "" local rts crs
        if !inlist("`rts'","crs","vrs") | !inlist("`model'","","te","allocative") {
            di as err "use rts(crs|vrs) for a convex technology or model(fdh) for FDH"
            exit 198
        }
    }
    if "`compare'" == "" local technologies `rts'
    local count : word count `technologies'
    if "`model'" == "allocative" & "`prices'" == "" {
        di as err "model(allocative) requires `priceopt'(price1 price2)"
        exit 198
    }
    preserve
    quietly keep `if'
    local N = _N
    quietly count if `selected'
    local focused = r(N)
    if "`prices'" != "" {
        if !`focused' | "`model'" == "te" {
            di as err "`priceopt'() requires a selected DMU and an allocative model"
            exit 198
        }
        foreach price of local prices {
            quietly count if `selected' & (missing(`price') | `price' <= 0)
            if r(N) {
                di as err "both `quantity' prices must be positive for the selected DMU"
                exit 459
            }
        }
    }

    tempname q targets
    quietly summarize `fixed' if `selected', meanonly
    scalar `q' = r(mean)
    if "`at'" != "" & "`at'" != "focus" {
        local at = subinstr("`at'", " ", "", .)
        gettoken lhs rhs : at, parse("=")
        gettoken eq level : rhs, parse("=")
        if "`lhs'" != "`fixed'" | "`eq'" != "=" | missing(real("`level'")) | real("`level'") <= 0 {
            di as err "specify at(focus) or at(`fixed'=#) with a positive `fixedtype' level"
            exit 198
        }
        local leveltype : type `fixed'
        if "`leveltype'" == "float" {
            // Snap only to an observed level. Other slices remain continuous.
            quietly count if `fixed' == float(real("`level'"))
            if r(N) local level : display %24.17g float(real("`level'"))
        }
        if `focused' & real("`level'") != `q' {
            di as err "the slice must equal the selected DMU's `fixedtype' to evaluate its efficiency"
            exit 198
        }
        scalar `q' = real("`level'")
    }
    if "`surface'" != "" & !`focused' & "`at'" == "" {
        quietly summarize `fixed', detail
        scalar `q' = r(p50)
    }
    if missing(`q') {
        di as err "specify a focus or an explicit `fixedtype' slice with at(`fixed'=#)"
        exit 198
    }
    quietly summarize `fixed', meanonly
    if "`technologies'" != "crs" & (("`view'" == "isoquant" & `q' > r(max)) | ///
        ("`fixedtype'" == "input" & `q' < r(min))) {
        di as err "no reference activity meets the requested `fixedtype' level for every requested technology"
        exit 459
    }
    if "`view'" == "weakdisposal" {
        local opts
        foreach opt in plan show {
            if "``opt''" != "" local opts `opts' `opt'(``opt'')
        }
        _graphdea_weakdiagram `axis1' `axis2' `fixed', selected(`selected') budget(`q') ///
            rts(`rts') `opts' `title' `xtitle' `ytitle' `name'
        return add
        restore
        return scalar N = `N'
        return scalar input = `q'
        return local technologies "`rts'"
        return local bad "`axis1'"
        return local good "`axis2'"
        exit
    }
    if "`show'" == "" {
        local show pps frontier
        if `focused' local show `show' radial
        if "`prices'" != "" local show `show' `isoline' `optimum'
    }
    foreach layer of local show {
        if "`layer'" == "slacks" {
            if "`view'" != "outputset" | !`focused' {
                di as err "section slacks require two outputs, dmu() and focus()"
                exit 198
            }
            local draw_slacks 1
            local draw_radial 1
            continue
        }
        if !inlist("`layer'","pps","frontier","radial","`radialalias'","`isoline'","`optimum'") {
            di as err "unknown `view' layer: `layer'"
            exit 198
        }
        if inlist("`layer'","radial","`radialalias'") & !`focused' {
            di as err "a radial projection requires a focus"
            exit 198
        }
        if inlist("`layer'","`isoline'","`optimum'") & "`prices'" == "" {
            di as err "`layer' requires `priceopt'(price1 price2)"
            exit 198
        }
        if "`layer'" == "`radialalias'" local layer radial
        if "`layer'" == "`isoline'" local layer priceline
        if "`layer'" == "`optimum'" local layer optimum
        local draw_`layer' 1
    }
    if `"`title'"' == "" {
        if "`surface'" != "" local heading "DEA frontier and cross-section"
        local title title("{stSerif:`heading'}")
    }
    local xt : variable label `axis1'
    local yt : variable label `axis2'
    if `"`xt'"' == "" local xt `axis1'
    if `"`yt'"' == "" local yt `axis2'
    if `"`xtitle'"' == "" local xtitle `"xtitle("`xt'")"'
    if `"`ytitle'"' == "" local ytitle `"ytitle("`yt'")"'

    // Keep one pair of hull coordinates per technology. Each hull
    // is built once; all disposal extensions and price lines use the same axes.
    tempname normscale summary stacked axes alternatives slacks
    local allhulls
    foreach tech of local technologies {
        tempvar hx hy
        quietly gen double `hx' = .
        quietly gen double `hy' = .
        local hull_`tech' `hx' `hy'
        local allhulls `allhulls' `hx' `hy'
    }
    mata: _graphdea_prepareslices()
    local figuretitle `"`title'"'
    local figurename `"`name'"'
    local i_panel 0
    foreach rts of local technologies {
        local ++i_panel
        local hullvars `hull_`rts''
        tempvar bx by cap ix iy px py role
        quietly {
            foreach v in bx by cap ix iy px py {
                gen double ``v'' = .
            }
            gen str8 `role' = ""
            if "`draw_slacks'" != "" {
                tempvar from1 from2 to1 to2
                foreach v in from1 from2 to1 to2 {
                    gen double ``v'' = .
                }
            }
            mata: _graphdea_slice()
        }
        local plots
        local n 0
        local order
        if "`draw_pps'" != "" {
            local plots (rarea `by' `cap' `bx' if !missing(`bx'), fcolor(gs15) fintensity(100) lwidth(none))
            local order `++n' "Feasible `quantity's"
        }
        local plots `plots' (line `by' `bx', lpattern(solid) lcolor(black) lwidth(medthick))
        local order `order' `++n' "`=proper("`quantity'")' boundary"
        if "`draw_priceline'" != "" {
            local plots `plots' (line `iy' `ix', lcolor(gs4) lpattern(dash))
            local order `order' `++n' "`linelegend'"
        }
        if "`draw_radial'" != "" {
            local plots `plots' (pci 0 0 `=`targets'[`rayend',2]' `=`targets'[`rayend',1]', lcolor(gs8) lpattern(shortdash))
            local order `order' `++n' "Radial direction"
        }
        if "`draw_slacks'" != "" {
            local arrowcoords `from2' `from1' `to2' `to1'
            local plots `plots' (pcspike `arrowcoords', lwidth(thick) lcolor(white)) ///
                (pcarrow `arrowcoords', lwidth(medthick) lpattern(dash) lcolor(gs5) mcolor(black))
            local n = `n'+2
            local order `order' `n' "Output slack from R"
        }
        if `focused' {
            local shown 1
            if "`draw_radial'" != "" local shown `shown' 2
            if "`draw_optimum'" != "" local shown `shown' 3
            foreach i of local shown {
                local tag : word `i' of D R `tag3'
                local sym : word `i' of O Dh T
                local pos : word `i' of 2 6 2
                if `i' == 2 & "`rts'" == "fdh" & "`view'" == "isoquant" local pos 4
                // Combine labels only for targets that coincide in both coordinates.
                foreach j of local shown {
                    if `j' >= `i' continue, break
                    if abs(`px'[`i'] - `px'[`j']) <= 1e-12 * max(`px'[`i'],`px'[`j']) ///
                        & abs(`py'[`i'] - `py'[`j']) <= 1e-12 * max(`py'[`i'],`py'[`j']) ///
                        & `role'[`j'] != "" {
                        quietly replace `role' = `role' + "/`tag'" in `j'
                        local tag
                        continue, break
                    }
                }
                if "`tag'" == "" continue
                quietly replace `role' = "`tag'" in `i'
                local plots `plots' (scatter `py' `px' in `i', msymbol(`sym') mcolor(black) ///
                    mlabel(`role') mlabposition(`pos') mlabcolor(black))
            }
        }
        local sub = "`fixed' = " + strtrim(string(`q',"%10.6g"))
        if `count' == 1 local sub "`=upper("`rts'")'     `sub'"
        if `focused' {
            local sub "`sub'     TE = `: di %5.3f `te''"
            if "`prices'" != "" local sub "`sub'     AE = `: di %5.3f `ae''     `=upper("`econ'")' = `: di %5.3f `economic''"
            local note
            if "`view'" == "outputset" & "`prices'" != "" local note "Revenue"
            foreach i of local shown {
                local point : word `i' of "D = observed" "R = radial target" "`point3'"
                if "`prices'" != "" {
                    local amount = strtrim(string(`targets'[`i',3], "%9.5g"))
                    if "`view'" == "outputset" {
                        local point : word `i' of "D (observed)" "R (radial)" "M (maximum)"
                        local point "`point' = `amount'"
                    }
                    else local point "`point' (`money' `amount')"
                }
                local note "`note'    `point'"
            }
        }
        if "`draw_slacks'" != "" {
            local names
            forvalues j=1/`=rowsof(`alternatives')' {
                local branch radial
                if `alternatives'[`j',5]>0 local branch more1
                if `alternatives'[`j',6]>0 local branch more2
                local names `names' `branch'
            }
            matrix rownames `alternatives' = `names'
            matrix roweq `alternatives' = `rts'
            matrix `slacks' = nullmat(`slacks') \ `alternatives'
            local explanation "No residual output slack at R"
            if "`branch'" != "radial" local explanation "Arrow ends at a Pareto-efficient output bundle"
            if rowsof(`alternatives')==2 local explanation "Each arrow ends at a separate feasible target"
            local note `""`note'" "`explanation'""'
        }
        else local note `""`note'""'
        local sectionscale .75
        if "`surface'" != "" {
            local sectionscale .9
            local azimuth = mod(mod(`azimuth',360)+360,360)
            tempname flat mesh
            local title title("{bf:(b) Fixed-`fixedtype' section}", size(medium))
            local name name(`flat') nodraw
        }
        if `count' > 1 {
            tempname panel
            local panels `panels' `panel'
            local title title("{bf:(`=char(96+`i_panel')') `=upper("`rts'")'}", size(medium))
            local name name(`panel') nodraw
        }
        twoway `plots', title(, position(11) span size(medlarge)) `title' ///
            subtitle("`sub'", position(11) span size(medsmall) margin(b=2)) ///
            `xtitle' `ytitle' xlabel(0(`xstep')`xlimit', nogrid labsize(small)) ///
            ylabel(0(`ystep')`ylimit', nogrid angle(horizontal) labsize(small)) ///
            xscale(line noextend lwidth(thin)) yscale(line noextend lwidth(thin)) ///
            aspectratio(`=`ylimit'/`xlimit'') plotregion(style(none) margin(zero)) graphregion(color(white)) ///
            legend(order(`order') cols(2) size(small) region(lstyle(none)) span) ///
            note(`note', size(small) span) xsize(5.5) ysize(5.5) scale(`sectionscale') scheme(s1mono) `name'

        if "`compare'" != "" & `focused' {
            local values `te'
            local cols te
            local rows observed radial
            if "`view'" == "outputset" {
                local values `values', `phi'
                local cols `cols' phi
            }
            if "`prices'" != "" {
                local values `values', `ae', `economic'
                local cols `cols' ae `econ'
                local rows `rows' `optimum'
            }
            matrix `summary' = nullmat(`summary') \ (`values')
            matrix rownames `targets' = `rows'
            matrix roweq `targets' = `rts'
            matrix `stacked' = nullmat(`stacked') \ `targets'
        }
    }
    if `count' > 1 {
        graph combine `panels', cols(`count') xcommon ycommon scheme(s1mono) graphregion(color(white)) ///
            title(, position(11) span) `figuretitle' xsize(`=min(14,5*`count')') ysize(5.5) `figurename'
    }
    if "`surface'" != "" {
        tempvar kind u v uend vend label
        quietly {
            foreach column in kind u v uend vend {
                gen double ``column'' = .
            }
            gen strL `label' = ""
            mata: _graphdea_surface()
        }
        local layers (pcspike `v' `u' `vend' `uend' if `kind'==1, lcolor(gs10) lwidth(vthin)) ///
            (pcspike `v' `u' `vend' `uend' if `kind'==2, lcolor(black) lwidth(medthick)) ///
            (pcspike `v' `u' `vend' `uend' if `kind'==3, lcolor(gs5) lwidth(thin)) ///
            (scatter `v' `u' if `kind'==4, msymbol(O) mcolor(gs6) msize(vsmall))
        local key 1 "Frontier mesh" 2 "Selected section" 4 "Observed DMU"
        if "`sectionfill'" != "" & `elevation' != 0 {
            // The opaque polygon masks only the parts projected inside its outline.
            local behind (pcspike `v' `u' `vend' `uend' if `kind'==9, lcolor(gs10) lwidth(vthin)) ///
                (scatter `v' `u' if `kind'==10, msymbol(O) mcolor(gs6) msize(vsmall))
            local face (area `v' `u' if `kind'==11, nodropbase cmissing(n) ///
                fcolor(gs14) fintensity(100) lwidth(none))
            local layers `behind' `face' `layers'
            local key 4 "Frontier mesh" 5 "Selected boundary" 7 "Observed DMU" 3 "Feasible section"
        }
        if `focused' {
            local layers `layers' (pcspike `v' `u' `vend' `uend' if `kind'==5, lcolor(black) lpattern(dash)) ///
                (scatter `v' `u' if `kind'==6, msymbol(Oh) mcolor(black) mlabel(`label') mlabcolor(black) mlabpos(2))
        }
        local layers `layers' (scatter `v' `u' if `kind'==7, msymbol(none) ///
            mlabel(`label') mlabpos(0) mlabsize(small) mlabcolor(gs4)) ///
            (scatter `v' `u' if `kind'==8, msymbol(none) ///
            mlabel(`label') mlabpos(0) mlabsize(medsmall) mlabcolor(black))
        twoway `layers', name(`mesh') nodraw title("{bf:(a) Production frontier}", ///
            size(medium) position(11) span) xscale(off range(`umin' `umax')) ///
            yscale(off range(`vmin' `vmax')) xlabel(`umin' `umax', nogrid) ylabel(`vmin' `vmax', nogrid) ///
            aspectratio(`=(`vmax'-`vmin')/(`umax'-`umin')') ///
            plotregion(style(none) margin(zero)) graphregion(color(white)) ///
            legend(order(`key') cols(2) size(small) span region(lstyle(none))) scale(`sectionscale') scheme(s1mono)
        graph combine `mesh' `flat', cols(2) graphregion(color(white)) scheme(s1mono) ///
            title(, position(11) span size(medlarge)) `figuretitle' xsize(10) ysize(5.4) `figurename'
    }
    restore
    return scalar N = `N'
    return scalar `fixedtype' = `q'
    if "`surface'" != "" {
        return scalar azimuth = `azimuth'
        return scalar elevation = `elevation'
    }
    if "`draw_slacks'" != "" {
        matrix colnames `slacks' = radial1 radial2 target1 target2 slack1 slack2
        return matrix slacks = `slacks'
        return local outputs "`axis1' `axis2'"
    }
    return local technologies "`technologies'"
    if "`compare'" != "" {
        matrix `axes' = (`xlimit',`xstep' \ `ylimit',`ystep')
        matrix rownames `axes' = `axis1' `axis2'
        matrix colnames `axes' = maximum step
        return matrix axes = `axes'
        if `focused' {
            matrix colnames `summary' = `cols'
            matrix rownames `summary' = `technologies'
            matrix colnames `stacked' = `axis1' `axis2' `money'
            return matrix efficiency = `summary'
            return matrix targets = `stacked'
        }
    }
    if `focused' & "`compare'" == "" {
        matrix colnames `targets' = `axis1' `axis2' `money'
        local rows observed radial
        if "`prices'" != "" {
            local rows `rows' `optimum'
            return scalar ae = `ae'
            return scalar `econ' = `economic'
        }
        matrix rownames `targets' = `rows'
        return matrix targets = `targets'
        return scalar te = `te'
        if "`view'" == "outputset" return scalar phi = `phi'
    }
end

program define _graphdea_weakdiagram, rclass
    version 16.0
    syntax varlist(min=3 max=3 numeric), SELECTED(varname) BUDGET(name) RTS(string) ///
        [PLAN(numlist min=2 max=2 >=0) Show(string) NAME(passthru) TItle(passthru) XTItle(passthru) YTItle(passthru)]
    tokenize `varlist'
    local bad `1'
    local good `2'
    local input `3'
    quietly count if `selected'
    local focused = r(N)
    if "`show'" == "" {
        local show pps frontier
        if `focused' local show `show' contraction
    }
    foreach layer of local show {
        if !inlist("`layer'","pps","frontier","contraction") | ("`layer'"=="contraction" & !`focused') {
            di as err "use show(pps frontier), with contraction available for a selected DMU"
            exit 198
        }
        local draw_`layer' 1
    }
    local xt : variable label `bad'
    local yt : variable label `good'
    if `"`xt'"' == "" local xt `bad'
    if `"`yt'"' == "" local yt `good'
    if `"`xtitle'"' == "" local xtitle `"xtitle("`xt'")"'
    if `"`ytitle'"' == "" local ytitle `"ytitle("`yt'")"'
    if `"`title'"' == "" local title title("{stSerif:Production with weakly disposable outputs}")

    tempname vertices evaluation
    tempvar bx by floor
    quietly gen double `bx' = .
    quietly gen double `by' = .
    quietly gen byte `floor' = 0
    mata: _graphdea_weakfrontier()
    local n 0
    if "`draw_pps'" != "" {
        local plots (rarea `floor' `by' `bx', fcolor(gs15) fintensity(100) lwidth(none))
        local order `++n' "Feasible outputs"
    }
    if "`draw_frontier'" != "" {
        local plots `plots' (line `by' `bx', lcolor(black) lwidth(medthick))
        local order `order' `++n' "Boundary"
    }
    if "`draw_contraction'" != "" {
        quietly summarize `bad' if `selected'==1, meanonly
        local b0 = r(mean)
        quietly summarize `good' if `selected'==1, meanonly
        local y0 = r(mean)
        local plots `plots' (pci 0 0 `y0' `b0', lcolor(gs6) lpattern(dash))
        local order `order' `++n' "Joint contraction"
    }
    quietly count if `input'<=`budget'
    if r(N) {
        local plots `plots' (scatter `good' `bad' if `input'<=`budget', msymbol(O) msize(small) mcolor(black))
        local order `order' `++n' "Observed DMU"
    }
    if `focused' {
        local plots `plots' (scatter `good' `bad' if `selected'==1, msymbol(Oh) msize(large) mcolor(black))
        local order `order' `++n' "Selected DMU"
    }
    local sub = upper("`rts'") + "     `input' = " + strtrim(string(`budget',"%9.5g"))
    if "`plan'" != "" {
        gettoken bp yp : plan
        if "`draw_contraction'" != "" & !missing(`evaluation'[1,5]) {
            local joint = `evaluation'[1,5]
            local plots `plots' (scatteri `joint' `bp', msymbol(+) msize(medlarge) mcolor(black))
            local order `order' `++n' "Proportional output"
        }
        local plots `plots' (scatteri `yp' `bp', msymbol(Dh) msize(vlarge) mcolor(black))
        local order `order' `++n' "Proposed plan"
        local status = cond(`evaluation'[1,4], "Feasible", "Infeasible")
        local sub "`sub'     `status' plan"
    }
    tempvar panel
    tempname panellabel
    quietly gen byte `panel' = 1
    label define `panellabel' 1 "`sub'"
    label values `panel' `panellabel'
    twoway `plots', by(`panel', note("") legend(position(6)) graphregion(color(white)) ///
        title(, position(11) span size(medlarge)) `title') ///
        subtitle(, nobox bcolor(none) lcolor(none) size(small)) `xtitle' `ytitle' ///
        xlabel(0(`xstep')`xlimit', nogrid labsize(small)) ylabel(0(`ystep')`ylimit', nogrid angle(horizontal) labsize(small)) ///
        xscale(range(0 `xlimit') line noextend) yscale(range(0 `ylimit') line noextend) ///
        aspectratio(`=`ylimit'/`xlimit'') plotregion(style(none) margin(zero)) graphregion(color(white)) ///
        legend(order(`order') cols(3) size(small) span region(lstyle(none))) ///
        xsize(6.4) ysize(5.8) scale(.82) scheme(s1mono) `name'
    matrix colnames `vertices' = bad good_max
    return matrix frontier = `vertices'
    if "`plan'" != "" {
        matrix colnames `evaluation' = bad_plan good_plan good_max feasible good_joint
        return matrix plan = `evaluation'
    }
end

version 16.0
mata:
// Vertices in increasing input order. At repeated inputs keep the largest output.
real matrix _graphdea_peaks(real matrix xy)
{
    real matrix s, peaks
    real scalar i, k
    s = sort(xy, (1,-2))
    peaks = J(rows(s), 2, .)
    k = 1
    peaks[k,] = s[1,]
    for (i=2; i<=rows(s); i++) {
        if (s[i,2] > peaks[k,2]) peaks[++k,] = s[i,]
    }
    return(peaks[|1,1 \ k,2|])
}

real matrix _graphdea_vrs(real matrix peaks, | real matrix original)
{
    real colvector vertices
    real rowvector a, b, c
    real scalar i, k
    vertices = J(rows(peaks),1,.)
    k = 0
    for (i=1; i<=rows(peaks); i++) {
        c = peaks[i,]
        while (k >= 2) {
            a = peaks[vertices[k-1],]
            b = peaks[vertices[k],]
            if ((b[2]-a[2])*(c[1]-b[1]) > (c[2]-b[2])*(b[1]-a[1])) break
            k--
        }
        vertices[++k] = i
    }
    vertices = vertices[1::k]
    if (args()==2) return(original[vertices,])
    return(peaks[vertices,])
}

real matrix _graphdea_fdh(real matrix peaks, | real scalar verticalfirst)
{
    real matrix steps
    real scalar i
    if (args()==1) verticalfirst = 0
    steps = J(2*rows(peaks)-1,2,.)
    steps[1,] = peaks[1,]
    for (i=2; i<=rows(peaks); i++) {
        if (verticalfirst) steps[2*i-2,] = (peaks[i-1,1],peaks[i,2])
        else               steps[2*i-2,] = (peaks[i,1],peaks[i-1,2])
        steps[2*i-1,] = peaks[i,]
    }
    return(steps)
}

// Clip the drawn frontier to the common plotting window. Fill to the right
// edge as well when the CRS ray exits through the top of the window.
real matrix _graphdea_boundary(string scalar model, real matrix peaks, real matrix hull,
    real scalar slope, real scalar right, real scalar top, real matrix area)
{
    real matrix b
    if (model=="crs") {
        b = (0,0) \ (min((right,top/slope)),min((top,right*slope)))
        area = b
        if (b[2,1]<right) area = area \ (right,top)
    }
    else {
        b = model=="vrs" ? hull : _graphdea_fdh(peaks)
        b = (b[1,1],0) \ b \ (right,b[rows(b),2])
        area = b
    }
    return(b)
}

// First crossing at y0 and last crossing at x0, including disposal edges.
// A held-out focus can have no crossing in one or both directions.
real rowvector _graphdea_targets(real matrix b, real rowvector o)
{
    real scalar i, x, y
    real rowvector a, z
    real colvector cross
    x = y = .
    cross = selectindex(b[,2] :>= o[2])
    if (rows(cross)) {
        i = cross[1]
        z = b[i,]
        x = z[1]
        if (i > 1 & z[2] > o[2]) {
            a = b[i-1,]
            x = a[1]+(o[2]-a[2])/(z[2]-a[2])*(z[1]-a[1])
        }
    }
    cross = selectindex(b[,1] :<= o[1])
    if (rows(cross)) {
        i = cross[rows(cross)]
        a = b[i,]
        y = a[2]
        if (i < rows(b) & a[1] < o[1]) {
            z = b[i+1,]
            y = a[2]+(o[1]-a[1])/(z[1]-a[1])*(z[2]-a[2])
        }
    }
    return((x,y))
}

// Intersect (o.x - beta*g.x, o.y + beta*g.y) with the ordered boundary.
// A strictly northwest ray crosses even an FDH staircase exactly once.
real rowvector _graphdea_ddf(real matrix b, real rowvector o, real rowvector t,
    real rowvector g)
{
    real rowvector h, a, edge, target
    real colvector side
    real scalar i, beta, gap, width
    if ((g[1]>0 & t[1]>=o[1]) | (g[2]>0 & t[2]<=o[2])) return((0,o))
    if (g[1]==0) return(((t[2]-o[2])/g[2],o[1],t[2]))
    if (g[2]==0) return(((o[1]-t[1])/g[1],t[1],o[2]))

    h = g/max(g)
    side = h[2]*(b[,1]:-o[1]) + h[1]*(b[,2]:-o[2])
    i = selectindex(side:>=0)[1]
    a = b[i-1,]
    edge = b[i,]-a
    width = side[i]-side[i-1]
    target = a - (side[i-1]/width)*edge
    gap = edge[2]*(o[1]-a[1]) + edge[1]*(a[2]-o[2])
    beta = gap / (edge[2]*h[1]+edge[1]*h[2]) / max(g)
    if (beta<=0) return((0,o))
    return((beta,target))
}

// Align the computational plotting window with the outermost labeled ticks.
real scalar _graphdea_axis(string scalar axis, real scalar extent, real scalar scale)
{
    real scalar step, limit
    if (missing(extent*scale) | extent*scale <= 0) _error(3300)
    stata("quietly _natscale 0 " + strofreal(extent*scale,"%21.16g") + " 5")
    step = st_numscalar("r(delta)")
    limit = ceil(extent*scale/step)*step
    if (missing(limit) | step <= 0) _error(3300)
    st_local(axis+"step", strofreal(step,"%21.16g"))
    st_local(axis+"limit", strofreal(limit,"%21.16g"))
    return(limit/scale)
}

real matrix _graphdea_mpivrsboundary(real matrix xy, real scalar right, real scalar top)
{
    real matrix peaks, area
    peaks = _graphdea_peaks(xy)
    return(_graphdea_boundary("vrs",peaks,_graphdea_vrs(peaks),.,right,top,area))
}

// Log levels for selected rows, using every observation in this period as a peer.
real matrix _graphdea_mpilevels(real matrix part, real colvector hit, real scalar split, real scalar input)
{
    real matrix logs, hull, xy
    real colvector rate
    real rowvector focus, target
    real scalar i
    logs = J(rows(hit),split ? 5 : 3,.)
    rate = ln(part[,2]):-ln(part[,1])
    logs[,1] = rate[hit]
    logs[,3] = J(rows(hit),1,max(rate))
    logs[,2] = logs[,1]-logs[,3]
    if (split) {
        xy = part:/colmax(part)
        hull = _graphdea_mpivrsboundary(xy,1.1,1.1)
        for (i=1;i<=rows(hit);i++) {
            focus = xy[hit[i],]
            target = _graphdea_targets(hull,focus)
            logs[i,4] = ln(input ? target[1]/focus[1] : focus[2]/target[2])
        }
        logs[,5] = logs[,2]-logs[,4]
    }
    return(logs)
}

// Radial intersection of a two-coordinate frontier expressed in units of the
// observed bundle. Both period cross-evaluations and fixed-level plots use it.
real scalar _graphdea_radialfactor(real matrix cut, real scalar outputset, real scalar fdh)
{
    real scalar i, t, factor, candidate
    real colvector cross
    if (outputset) factor = max(rowmin(cut))
    else           factor = min(rowmax(cut))
    // FDH takes the best radial factor over individual eligible units.
    if (!fdh) {
        cross = cut[,1]-cut[,2]
        for (i=2; i<=rows(cut); i++) {
            if (cross[i-1]<0 & cross[i]>0) {
                t = -cross[i-1]/(cross[i]-cross[i-1])
                candidate = (1-t)*cut[i-1,1]+t*cut[i,1]
                if (outputset) factor = max((factor,candidate))
                else           factor = min((factor,candidate))
            }
        }
    }
    return(factor)
}

// Fix one quantity at its observed level to obtain a two-dimensional VRS
// section. When both radial coordinates move, intersect the observed ray.
// When just one moves, read the corresponding input or output target.
real scalar _graphdea_mpivrslog(real matrix peers, real rowvector obs, real scalar nx, real scalar input)
{
    real matrix hull
    real rowvector pair, bundle, target
    real scalar fixed, outputset, factor
    outputset = nx==1
    if (input!=outputset) {
        pair = outputset ? (2,3) : (1,2)
        fixed = outputset ? 1 : 3
        hull = _graphdea_vrssection(peers[,pair],peers[,fixed],obs[fixed],outputset,outputset)
        factor = _graphdea_radialfactor(hull:/obs[pair],outputset,0)
        return(outputset ? -ln(factor) : ln(factor))
    }
    // For two inputs hold the first input fixed, then maximize output at the
    // second input. For two outputs hold the last output fixed, then minimize
    // input at the first output. Shape 2 is an input/output frontier.
    pair = outputset ? (1,2) : (2,3)
    fixed = outputset ? 3 : 1
    hull = _graphdea_vrssection(peers[,pair],peers[,fixed],obs[fixed],!outputset,2)
    bundle = obs[pair]
    target = _graphdea_targets(hull,bundle)
    return(input ? ln(target[1]/bundle[1]) : ln(bundle[2]/target[2]))
}

// For CRS, a two-input isoquant at unit output (or a two-output boundary at
// unit input) suffices for every bundle. Distances can exceed 1 across periods.
real matrix _graphdea_mpimultilogs(real matrix rawbase, real matrix rawfollow,
    real colvector m0, real colvector m1, real scalar nx, real scalar input, real scalar split,
    | real matrix basehull, real matrix laterhull, real matrix te, real matrix vrs)
{
    real scalar outs, fixed, i, j, ec, tc, pure
    real rowvector pair, d0, d1, scale
    real colvector vrslogs
    real matrix base, follow, a, b, h0, h1, ratios, factors
    // Both periods use the same units, independent of other links in a chain.
    scale = colmax(colmax(rawbase) \ colmax(rawfollow))
    base = rawbase:/scale
    follow = rawfollow:/scale
    outs = nx==1
    pair = outs ? (2,3) : (1,2)
    fixed = outs ? 1 : 3
    a = base[,pair]:/base[,fixed]
    b = follow[,pair]:/follow[,fixed]
    h0 = _graphdea_slicehull(a,outs)
    h1 = _graphdea_slicehull(b,outs)
    factors = J(rows(m0),split ? 5 : 3,.)
    for (i=1; i<=rows(m0); i++) {
        ratios = a[m0[i],] \ b[m1[i],]
        d0 = d1 = J(1,2,.)
        for (j=1; j<=2; j++) {
            d0[j] = ln(_graphdea_radialfactor(h0:/ratios[j,],outs,0))
            d1[j] = ln(_graphdea_radialfactor(h1:/ratios[j,],outs,0))
        }
        // An output expansion is the reciprocal of Farrell efficiency.
        if (outs) {
            d0 = -d0
            d1 = -d1
        }
        ec = d1[2]-d0[1]
        tc = ((d0[1]-d1[1])+(d0[2]-d1[2]))/2
        factors[i,1..3] = (ec+tc,ec,tc)
        if (split) {
            vrslogs = _graphdea_mpivrslog(base,base[m0[i],],nx,input) \
                _graphdea_mpivrslog(follow,follow[m1[i],],nx,input)
            pure = vrslogs[2]-vrslogs[1]
            factors[i,4..5] = (pure,ec-pure)
        }
    }
    // The focus diagram requests the two hulls and scores for a single match.
    if (args()==11) {
        basehull = h0:*(scale[pair]/scale[fixed])
        laterhull = h1:*(scale[pair]/scale[fixed])
        te = exp((d0',d1'))
        if (split) vrs = exp(vrslogs)
    }
    return(factors)
}

// Two panels share the ratio-space frontiers, limits and units. Each panel
// contains the observed focus and the projections along its own radial line.
void _graphdea_mpidiagram()
{
    real matrix raw, base, later, h0, h1, te, vrs, focus, obs, radial, targets, path0, path1, plot
    real colvector second, selected, m0, m1, own, reach
    real rowvector factors, pair, limits
    real scalar nx, outs, input, split, fixed, i, n, start
    raw = st_data(.,tokens(st_local("varlist")))
    second = st_data(.,st_local("second"))
    selected = st_data(.,st_local("selected"))
    base = select(raw,!second)
    later = select(raw,second)
    m0 = selectindex(select(selected,!second))
    m1 = selectindex(select(selected,second))
    nx = strtoreal(st_local("ninputs"))
    outs = nx==1
    input = st_local("orientation")=="input"
    split = st_local("decompose")!=""
    h0 = h1 = te = vrs = .
    factors = exp(_graphdea_mpimultilogs(base,later,m0,m1,nx,input,split,h0,h1,te,vrs))
    st_matrix(st_local("changes"),factors[(2,3,1)])
    st_matrix(st_local("distances"),input ? 1:/te : te)

    focus = base[m0,] \ later[m1,]
    pair = outs ? (2,3) : (1,2)
    fixed = outs ? 1 : 3
    obs = focus[,pair]:/focus[,fixed]
    radial = outs ? 1:/te : te
    targets = (obs,obs:*radial[,1],obs:*radial[,2])
    if (split) {
        own = diagonal(te)
        st_matrix(st_local("levels"),(vrs,own,own:/vrs))
        radial = (radial,(outs ? 1:/vrs : vrs))
        targets = (targets,obs:*radial[,3])
    }
    st_matrix(st_local("targets"),targets)
    reach = rowmax((J(2,1,1),radial))
    limits = colmax(h0 \ h1 \ (obs:*reach))
    limits = (_graphdea_axis("x",1.1,limits[1])*limits[1],
              _graphdea_axis("y",1.1,limits[2])*limits[2])
    path0 = _graphdea_sectionpath(h0,outs,limits)
    path1 = _graphdea_sectionpath(h1,outs,limits)
    n = max((rows(path0),rows(path1)))
    plot = J(2*n,7+cols(targets),.)
    for (i=1; i<=2; i++) {
        start = (i-1)*n+1
        plot[start..(start+n-1),1] = J(n,1,i-1)
        plot[start..(start+rows(path0)-1),2..3] = path0
        plot[start..(start+rows(path1)-1),4..5] = path1
        plot[start..(start+1),6..7] = (0,0) \ (obs[i,]*reach[i])
        plot[start,8..cols(plot)] = targets[i,]
    }
    if (rows(plot)>st_nobs()) st_addobs(rows(plot)-st_nobs())
    st_store(1::rows(plot),tokens(st_local("plotvars")),plot)
}

void _graphdea_mpioverviewcalc()
{
    real matrix xy, base, followup, levels0, levels1
    real colvector second, matched0, matched1, paired
    real scalar input, split
    xy = st_data(.,tokens(st_local("varlist")))
    second = st_data(.,st_local("second"))
    paired = st_data(.,st_local("paired"))
    base = select(xy,!second)
    followup = select(xy,second)
    matched0 = selectindex(select(paired,!second))
    matched1 = selectindex(select(paired,second))
    // The data are sorted by ID and base/follow-up status, so the selected
    // IDs have exactly the same order in the two period samples.
    split = st_local("decompose")!=""
    input = st_local("orientation")=="input"
    if (cols(xy)==3) {
        st_store(selectindex(paired:&!second),tokens(st_local("factorvars")),
            exp(_graphdea_mpimultilogs(base,followup,matched0,matched1,strtoreal(st_local("ninputs")),input,split)))
        return
    }
    levels0 = _graphdea_mpilevels(base,matched0,split,input)
    levels1 = _graphdea_mpilevels(followup,matched1,split,input)
    st_store(selectindex(paired:&!second),tokens(st_local("factorvars")),exp(levels1-levels0))
}

// Use the same CRS reference for every focal period. Each column is a
// log level, so differences give the global index and its decomposition.
real matrix _graphdea_mpiglobal(real matrix raw, real matrix panels, real colvector hits,
    real scalar nx, real scalar input, real scalar split)
{
    real matrix levels, data, ratios, pool, part, periodratios, ownhull
    real rowvector obs, pair
    real scalar j, fixed, outs, sign, pooledrate, hit
    levels = J(rows(panels),split ? 5 : 3,.)
    if (cols(raw)==2) {
        pooledrate = max(ln(raw[,2]):-ln(raw[,1]))
        for (j=1;j<=rows(panels);j++) {
            part = panelsubmatrix(raw,j,panels)
            levels[j,] = _graphdea_mpilevels(part,hits[j],split,input)
            // The one-input, one-output pooled frontier is a ray.
            levels[j,1] = levels[j,1]-pooledrate
            levels[j,3] = levels[j,1]-levels[j,2]
        }
        return(levels)
    }
    data = raw:/colmax(raw)
    outs = nx==1
    pair = outs ? (2,3) : (1,2)
    fixed = outs ? 1 : 3
    sign = outs ? -1 : 1
    ratios = data[,pair]:/data[,fixed]
    pool = _graphdea_slicehull(ratios,outs)
    for (j=1;j<=rows(panels);j++) {
        periodratios = panelsubmatrix(ratios,j,panels)
        hit = hits[j]
        obs = periodratios[hit,]
        ownhull = _graphdea_slicehull(periodratios,outs)
        levels[j,1] = sign*ln(_graphdea_radialfactor(pool:/obs,outs,0))
        levels[j,2] = sign*ln(_graphdea_radialfactor(ownhull:/obs,outs,0))
        levels[j,3] = levels[j,1]-levels[j,2]
        if (split) {
            part = panelsubmatrix(data,j,panels)
            levels[j,4] = _graphdea_mpivrslog(part,part[hit,],nx,input)
            levels[j,5] = levels[j,2]-levels[j,4]
        }
    }
    return(levels)
}

// Keep links and cumulative factors on the log scale until storing results.
void _graphdea_mpichaincalc()
{
    real matrix xy, panels, part, previous, header, link, cum, levels
    real colvector dates, flags, hit, hits
    real rowvector requested
    real scalar j, k, split, input, nx, pooled
    dates = st_data(.,st_local("time"))
    panels = panelsetup(dates,1)
    k = rows(panels)
    requested = strtoreal(tokens(st_local("periods")))
    if (st_local("periods")!="" & k!=cols(requested)) {
        errprintf("each requested period must contain a complete observation of the focus\n")
        _error(459)
    }
    if (k<2) {
        errprintf("at least two distinct periods are required for chain\n")
        _error(198)
    }
    if (st_local("periods")!="") {
        if (requested[1]>requested[k]) panels = panels[k::1,]
    }
    flags = st_data(.,st_local("selected"))
    xy = st_data(.,tokens(st_local("varlist")))
    nx = strtoreal(st_local("ninputs"))
    input = st_local("orientation")=="input"
    split = st_local("decompose")!=""
    link = J(k,split ? 5 : 3,.)
    cum = J(k,cols(link),0)
    pooled = st_local("benchmark")=="global"
    header = J(k,2,.)
    hits = J(k,1,.)
    for (j=1;j<=k;j++) {
        hit = selectindex(panelsubmatrix(flags,j,panels))
        if (rows(hit)!=1) {
            errprintf("focus() must select exactly one complete observation at time %g\n",dates[panels[j,1]])
            _error(459)
        }
        header[j,] = (dates[panels[j,1]],panels[j,2]-panels[j,1]+1)
        hits[j] = hit
    }
    if (pooled | cols(xy)==2) {
        if (pooled) {
            levels = _graphdea_mpiglobal(xy,panels,hits,nx,input,split)
            st_matrix(st_local("scores"),(header,exp(levels)))
        }
        else {
            levels = J(k,cols(link),.)
            for (j=1;j<=k;j++) {
                levels[j,] = _graphdea_mpilevels(panelsubmatrix(xy,j,panels),hits[j],split,input)
            }
        }
        link[2::k,] = levels[2::k,]-levels[1::(k-1),]
        cum = levels:-levels[1,]
    }
    else {
        previous = panelsubmatrix(xy,1,panels)
        for (j=2;j<=k;j++) {
            part = panelsubmatrix(xy,j,panels)
            link[j,] = _graphdea_mpimultilogs(previous,part,hits[j-1],hits[j],nx,input,split)
            cum[j,] = cum[j-1,]+link[j,]
            previous = part
        }
    }
    st_matrix(st_local("links"),(header,exp(link)))
    st_matrix(st_local("cum"),(header,exp(cum)))
}

// Store the two boundaries for one period and evaluate its two VRS radial targets.
real rowvector _graphdea_mpivrs(real matrix xy, real rowvector focus, real scalar period,
    real rowvector scale, real rowvector crsend, real scalar right, real scalar top)
{
    real matrix b
    real colvector dest
    real rowvector target
    b = _graphdea_mpivrsboundary(xy,right,top)
    target = _graphdea_targets(b,focus)
    dest = st_nobs() :+ (1::rows(b))
    st_addobs(rows(b))
    st_store(dest,st_local("second"),J(rows(b),1,period))
    st_store(dest,(st_local("vx"),st_local("vy")),b:*scale)
    st_store(dest[1::2],(st_local("cx"),st_local("cy")),((0,0) \ crsend))
    return(target)
}

// In 1x1 CRS, each period's best observed output/input ratio defines its ray.
// Evaluate both focus bundles on both rays, including cross-period distances > 1.
void _graphdea_mpicalc()
{
    real matrix raw, xy, focus, crstarget, score, endpoints
    real rowvector scale, slope
    real colvector second, selected, ix, rate, vrstarget, vrs_te, crs_te
    real rowvector target
    real scalar j, right, top, ec, tc, mpi, axis, input

    raw = st_data(.,(st_local("x"),st_local("y")))
    scale = colmax(raw)
    xy = raw:/scale
    second = st_data(.,st_local("second"))
    selected = st_data(.,st_local("selected"))
    ix = selectindex(selected:&!second) \ selectindex(selected:&second)
    focus = xy[ix,]
    rate = xy[,2]:/xy[,1]
    slope = (max(select(rate,!second)), max(select(rate,second)))
    input = st_local("orientation")=="input"
    axis = input ? 1 : 2
    if (input) {
        crstarget = (focus[,2]/slope[1],focus[,2]/slope[2])
        score = crstarget:/focus[,1]
    }
    else {
        crstarget = focus[,1]*slope
        score = focus[,2]:/crstarget
    }
    // Scores use the efficiency convention in both orientations. Shephard
    // input distances, returned below, are reciprocals of those scores.
    // Logs avoid overflow in the product inside the geometric mean.
    ec = score[2,2]/score[1,1]
    tc = exp(mean(ln(score[,1]):-ln(score[,2])))
    mpi = exp(mean(ln(score[2,]'):-ln(score[1,]')))
    right = _graphdea_axis("x",1.1,scale[1])
    top = input ? 1.1 : 1.1*max((1,diagonal(crstarget)'))
    top = _graphdea_axis("y",top,scale[2])
    endpoints = J(2,2,.)
    for (j=1;j<=2;j++) {
        endpoints[j,] = (min((right,top/slope[j])), min((top,right*slope[j]))):*scale
    }
    if (st_local("decompose")!="") {
        vrstarget = J(2,1,.)
        for (j=1;j<=2;j++) {
            target = _graphdea_mpivrs(select(xy,second:==(j-1)),focus[j,],j-1,
                scale,endpoints[j,],right,top)
            vrstarget[j] = target[axis]
        }
        vrs_te = input ? vrstarget:/focus[,1] : focus[,2]:/vrstarget
        crs_te = diagonal(score)
        st_store(ix,st_local("vrstarget"),vrstarget*scale[axis])
        st_matrix(st_local("levels"),(raw[ix,axis],vrstarget*scale[axis],diagonal(crstarget)*scale[axis],
            vrs_te,crs_te,crs_te:/vrs_te))
    }
    st_store(ix,st_local("crstarget"),diagonal(crstarget)*scale[axis])
    st_matrix(st_local("focusxy"),raw[ix,])
    st_matrix(st_local("ends"),endpoints)
    st_matrix(st_local("distances"),input ? 1:/score : score)
    st_matrix(st_local("changes"),(ec,tc,mpi))
}

// One deterministic representation of the Pareto target as observation weights.
// VRS uses the two bracketing extreme points; FDH uses one undominated unit.
real matrix _graphdea_peers(string scalar model, real matrix xy, real matrix hull,
    real matrix peaks, real rowvector o, real scalar input)
{
    real scalar axis, k, span
    real colvector idx, weights, which
    real matrix vertices, result
    axis = input ? 2 : 1
    if (model=="crs") {
        weights = xy[,2]:/xy[,1]
        k = selectindex(weights:==max(weights))[1]
        return((k,o[axis]/xy[k,axis]))
    }
    if (model=="fdh") {
        if (input) k = min(selectindex(peaks[,2]:>=o[2]))
        else       k = max(selectindex(peaks[,1]:<=o[1]))
        vertices = peaks[k,]
        weights = 1
    }
    else {
        idx = selectindex(hull[,axis]:>=o[axis])
        if (!length(idx)) k = rows(hull)
        else              k = idx[1]
        vertices = hull[k,]
        weights = 1
        if (k>1 & o[axis]<hull[k,axis]) {
            span = hull[k,axis]-hull[k-1,axis]
            vertices = hull[(k-1)\k,]
            weights = ((hull[k,axis]-o[axis]) \ (o[axis]-hull[k-1,axis])) / span
        }
    }
    result = J(rows(vertices),2,.)
    for (k=1;k<=rows(vertices);k++) {
        which = selectindex((xy[,1]:==vertices[k,1]):&(xy[,2]:==vertices[k,2]))
        result[k,] = (which[1],weights[k])
    }
    return(select(result,result[,2]:>0))
}

// Select an incident frontier edge in normalized coordinates. Extending it
// through the plot window gives a support even on a vertical disposal face.
real rowvector _graphdea_support(real matrix b, real rowvector o, real scalar input,
    real rowvector scale, real rowvector limits, real matrix line)
{
    real scalar edge, norm, v, u, w, objective, lo, hi
    real rowvector a, d
    real colvector active
    if (input) edge = selectindex(b[,2]:>=o[2])[1]-1
    else       edge = max(selectindex(b[,1]:<=o[1]))
    a = b[edge,]
    d = b[edge+1,]-a
    d = d/max(d)
    norm = input ? d[2]*o[1] : d[1]*o[2]
    v = d[2]/norm
    u = d[1]/norm
    w = (d[2]*a[1]-d[1]*a[2])/norm
    // Evaluate the dual objective relative to the edge endpoint. This avoids
    // cancellation between the weighted observation and a large VRS constant.
    objective = input ? v*a[1]+u*(o[2]-a[2]) : u*a[2]+v*(o[1]-a[1])

    active = selectindex(d':>0)
    lo = max(-a[active]:/d[active])
    hi = min((limits[active]-a[active]):/d[active])
    line = (colmax((0,0) \ (a+lo*d)) \ colmin(limits \ (a+hi*d))):*scale
    return((v/scale[1],u/scale[2],w,objective))
}

// Compare weighted differences so that a large common slack cannot mask
// the difference between two additive target scores.
real matrix _graphdea_additiveoptima(real matrix candidates, real rowvector w)
{
    real scalar i, best
    real rowvector d
    real matrix change
    best = 1
    for (i=2; i<=rows(candidates); i++) {
        d = (candidates[i,]-candidates[best,]):*w
        if (d[2]-d[1] > 8*epsilon(1)*max(abs(d))) best = i
    }
    change = (candidates:-candidates[best,]):*w
    return(select(candidates,abs(change[,2]-change[,1]):<=8*epsilon(1)*rowmax(abs(change))))
}

// A linear or positive-denominator fractional objective attains its optimum
// at a vertex of the frontier clipped to x<=x0, y>=y0.
real matrix _graphdea_slacktargets(string scalar model, real matrix frontier, real rowvector o,
    string scalar objective, real rowvector w)
{
    real matrix candidates, slacks
    real rowvector a, b
    real colvector rho
    real scalar k, x, y, minimum
    if (model=="crs") {
        a = frontier[1,]
        if (o[2]/o[1]==a[2]/a[1]) candidates = o
        else {
            x = min((o[1], (o[2]/a[2])*a[1]))
            y = max((o[2], (o[1]/a[1])*a[2]))
            candidates = (x,o[2]) \ (o[1],y)
        }
    }
    else {
        candidates = select(frontier,(frontier[,1]:<=o[1]):&(frontier[,2]:>=o[2]))
        if (model=="vrs") {
            k = selectindex(frontier[,2]:>=o[2])[1]
            if (k>1 & frontier[k,2]>o[2]) {
                a = frontier[k-1,]
                b = frontier[k,]
                x = a[1]+((o[2]-a[2])/(b[2]-a[2]))*(b[1]-a[1])
                candidates = candidates \ (min((x,o[1])),o[2])
            }
            k = max(selectindex(frontier[,1]:<=o[1]))
            if (k<rows(frontier) & frontier[k,1]<o[1]) {
                a = frontier[k,]
                b = frontier[k+1,]
                y = a[2]+((o[1]-a[1])/(b[1]-a[1]))*(b[2]-a[2])
                candidates = candidates \ (o[1],max((y,o[2])))
            }
        }
    }
    candidates = _graphdea_peaks(candidates)
    // Nondominated candidates increase strictly in both coordinates. The
    // first (last) attains the input (output) score and exhausts residual slack.
    if (objective=="input") {
        candidates = candidates[1,]
        minimum = candidates[1,1]/o[1]
    }
    else if (objective=="output") {
        candidates = candidates[rows(candidates),]
        minimum = o[2]/candidates[1,2]
    }
    else if (objective=="nonoriented") {
        // Both factors are bounded by one; avoid cancellation in 1-s_input/x0.
        rho = (candidates[,1]:/o[1]):*(o[2]:/candidates[,2])
        minimum = min(rho)
        candidates = select(candidates,rho:-minimum:<=8*epsilon(1)*minimum)
    }
    else candidates = _graphdea_additiveoptima(candidates,w)
    if (model!="fdh" & rows(candidates)>2) candidates = candidates[(1 \ rows(candidates)),]
    slacks = (o[1]:-candidates[,1],candidates[,2]:-o[2])
    if (objective!="additive") return((candidates,slacks,slacks:/o,J(rows(slacks),1,minimum)))
    return((candidates,slacks,slacks*w'))
}

void _graphdea_geometry()
{
    real matrix raw, xy, peaks, hull, b, area, result, weights, peers, benchmarks, multipliers, line
    string matrix stripe
    real rowvector radial, final, slack
    real colvector sourceobs
    real rowvector scale, o, t
    real rowvector first, second, mixture, capacity
    real colvector endpoints
    real scalar mixview, share, ymax
    real matrix mixtures
    real scalar dispview, hasplan, direct, feasible, xquery, observedmax
    real rowvector plan, focus
    real matrix disposal
    real colvector eligible
    real matrix distances
    real matrix refxy, refpeaks, refhull, refboundary, refarea, superresults
    real scalar superview, refslope, factor
    real rowvector reftarget, location
    real colvector refrows
    real matrix alltargets, targets, crstargets, rawpeaks, rawhull, slacksummary
    real rowvector slackweights
    string matrix targetstripe
    real scalar slackview, sbm, bestunit
    real rowvector direction, g, crsddf, hit
    real scalar ddf
    real colvector ix, dest, selected
    real scalar n, j, slope, right, top, hasfocus, reference, input, support
    string rowvector models
    string scalar objective

    models = tokens(st_local("models"))
    n = strtoreal(st_local("N"))
    ix = 1::n
    raw = st_data(ix,(st_local("ox"), st_local("oy")))
    mixview = st_local("mixview")=="1"
    if (mixview) {
        endpoints = st_data(ix,st_local("endpoints"))
        first = raw[selectindex(endpoints:==1),]
        second = raw[selectindex(endpoints:==2),]
        share = strtoreal(st_local("share"))
        // Anchor at the nearer endpoint so zero weights and tied coordinates are exact.
        if (share<=.5) mixture = second+share*(first-second)
        else           mixture = first+(1-share)*(second-first)
        mixtures = J(cols(models),6,.)
    }
    // Scale each axis before slope comparisons and restore original units for display.
    scale = colmax(raw)
    xy = raw :/ scale
    slackview = st_local("slackview")=="1"
    if (slackview) {
        // Use normalized turns for the graph, retaining the very same vertices
        // in original units for exact observed slacks and their weights.
        rawpeaks = _graphdea_peaks(raw)
        peaks = rawpeaks:/scale
        rawhull = _graphdea_vrs(peaks,rawpeaks)
        hull = rawhull:/scale
    }
    else {
        peaks = _graphdea_peaks(xy)
        hull = _graphdea_vrs(peaks)
    }
    selected = selectindex(st_data(ix,st_local("selected")))
    hasfocus = length(selected) > 0
    if (hasfocus) o = xy[selected[1],]
    result = J(cols(models),5,.)
    reference = strtoreal(st_local("reference"))
    input = st_local("orientation")=="input"
    support = st_local("draw_weights")!=""
    if (support) multipliers = J(cols(models),4,.)
    if (reference) {
        sourceobs = st_data(ix,st_local("orig"))
        peers = J(0,4,.)
        stripe = J(0,2,"")
        benchmarks = J(cols(models),6,.)
    }
    right = top = 1.1
    superview = st_local("superview")=="1"
    slope = refslope = .
    if (anyof(models,"crs")) slope = max(xy[,2]:/xy[,1])
    if (superview) {
        refxy = select(xy,ix:!=selected[1])
        refpeaks = _graphdea_peaks(refxy)
        refhull = _graphdea_vrs(refpeaks)
        superresults = J(cols(models),6,.)
        if (anyof(models,"crs")) {
            refslope = max(refxy[,2]:/refxy[,1])
            if (input) right = max((right,1.1*o[2]/refslope))
            else top = max((top,1.1*o[1]*refslope))
        }
    }
    if (slackview) {
        sbm = st_local("view")=="sbm"
        objective = sbm ? st_local("orientation") : "additive"
        slackweights = strtoreal(tokens(st_local("slackweights")))
        alltargets = J(0,sbm ? 7 : 5,.)
        slacksummary = J(cols(models),sbm ? 4 : 2,.)
        targetstripe = J(0,2,"")
        if (anyof(models,"crs")) {
            bestunit = selectindex(xy[,2]:/xy[,1]:==max(xy[,2]:/xy[,1]))[1]
            crstargets = _graphdea_slacktargets("crs",raw[bestunit,],raw[selected,],objective,slackweights)
            top = max((top,1.1*max(crstargets[,2])/scale[2]))
        }
    }
    dispview = st_local("dispview")=="1"
    hasplan = st_local("plan")!=""
    if (dispview) {
        focus = raw[selected[1],]
        disposal = (J(cols(models),1,1)*focus, J(cols(models),5,.))
        if (hasplan) {
            plan = strtoreal(tokens(st_local("plan")))
            direct = plan[1]>=focus[1] & plan[2]<=focus[2]
            right = max((right,1.1*plan[1]/scale[1]))
            top = max((top,1.1*plan[2]/scale[2]))
        }
    }
    if (mixview | hasplan) {
        if (mixview) xquery = mixture[1]
        else         xquery = plan[1]
        eligible = select(raw[,2],raw[,1]:<=xquery)
        observedmax = rows(eligible) ? max(eligible) : .
    }
    ddf = strtoreal(st_local("ddf"))
    if (ddf) {
        direction = (st_numscalar(st_local("dirx")),st_numscalar(st_local("diry")))
        g = direction:/scale
        distances = J(cols(models),5,.)
        if (anyof(models,"crs")) {
            slope = max(xy[,2]:/xy[,1])
            t = (o[2]/slope,o[1]*slope)
            crsddf = _graphdea_ddf((0,0) \ (o[1],t[2]),o,t,g)
            top = max((top,1.1*crsddf[3]))
        }
    }
    if (hasfocus & (st_local("draw_radialout") != "" | ((reference | support) & !input)) & anyof(models,"crs")) {
        top = max((top,1.1*o[1]*max(xy[,2]:/xy[,1])))
    }
    right = _graphdea_axis("x",right,scale[1])
    top = _graphdea_axis("y",top,scale[2])
    if (st_local("scaleview")=="1") {
        // Sum(lambda)<=1 is a convex mixture with the origin taking unused weight.
        b = _graphdea_vrs((0,0) \ hull)
        b = b \ (right,b[rows(b),2])
        t = _graphdea_targets(b,o)
        st_numscalar(st_local("nirste"), input ? t[1]/o[1] : o[2]/t[2])
    }
    for (j=1; j<=cols(models); j++) {
        b = _graphdea_boundary(models[j],peaks,hull,slope,right,top,area)
        if (hasfocus) {
            if (models[j]=="crs") t = (o[2]/slope,o[1]*slope)
            else t = _graphdea_targets(b,o)
        }
        if (superview) {
            refboundary = _graphdea_boundary(models[j],refpeaks,refhull,refslope,right,top,refarea)
            if (models[j]=="crs") reftarget = (o[2]/refslope,o[1]*refslope)
            else reftarget = _graphdea_targets(refboundary,o)
            location = input ? (reftarget[1],o[2]) : (o[1],reftarget[2])
            factor = input ? location[1]/o[1] : location[2]/o[2]
            superresults[j,1] = input ? t[1]/o[1] : o[2]/t[2]
            superresults[j,6] = !missing(factor)
            if (!missing(factor)) {
                location = location:*scale
                // Retain the observed coordinates exactly when the ray does not move.
                if (input) location[2] = raw[selected,2]
                else location[1] = raw[selected,1]
                if (factor==1) location = raw[selected,]
                superresults[j,2..5] = (factor,(input ? factor : 1/factor),location)
                st_store((j-1)*n+selected[1],("superx","supery"),location)
            }
            refrows = st_nobs():+(1::rows(refarea))
            st_addobs(rows(refarea))
            st_store(refrows,"panel",J(rows(refarea),1,j))
            st_store(refrows,"floor",J(rows(refarea),1,0))
            st_store(refrows,("refx","reftop"),refarea:*scale)
            st_store(refrows[1::rows(refboundary)],"refy",refboundary[,2]*scale[2])
        }
        if (mixview | hasplan) {
            ymax = observedmax
            if (models[j]=="crs") ymax = max((observedmax,xquery/scale[1]*slope*scale[2]))
            if (models[j]=="vrs" & !missing(observedmax)) {
                capacity = _graphdea_targets(b,(xquery/scale[1],0))
                ymax = max((observedmax,capacity[2]*scale[2]))
            }
        }
        if (mixview) {
            if (models[j]!="fdh") ymax = max((ymax,mixture[2]))
            mixtures[j,] = (share,1-share,mixture,ymax,mixture[2]<=ymax)
            st_store((j-1)*n+1,("mixx","mixy"),mixture)
        }
        if (hasplan) {
            feasible = !missing(ymax) & plan[2]<=ymax
            // Allow floating-point interpolation error on convex frontier segments.
            if (!missing(ymax) & models[j]!="fdh" & plan[2]>ymax) {
                feasible = plan[2]-ymax <= 8*epsilon(1)*ymax
            }
            disposal[j,3..7] = (plan,direct,ymax,feasible)
            st_store((j-1)*n+1,("planx","plany"),plan)
        }
        if (hasfocus) {
            ix = (j-1)*n+selected[1]
            result[j,] = (t[1]*scale[1],t[1]/o[1],t[2]*scale[2],t[2]/o[2],o[2]/t[2])
            st_store(ix,("fx","fy","tx","ty"),((o:*scale),result[j,(1,3)]))
            if (ddf) {
                if (models[j]=="crs") hit = crsddf
                else hit = _graphdea_ddf(b,o,t,g)
                distances[j,] = (hit[1],direction,hit[2..3]:*scale)
                st_store(ix,("dx","dy"),distances[j,4..5])
            }
        }
        if (reference | support) {
            if (input) radial = (result[j,1],raw[selected,2])
            else       radial = (raw[selected,1],result[j,3])
            st_store(ix,("rx","ry"),radial)
        }
        if (reference) {
            weights = _graphdea_peers(models[j],xy,hull,peaks,o,input)
            // Only free-disposal faces can leave slack after a 1x1 radial move.
            final = radial
            if (models[j]!="crs" & rows(weights)==1) {
                if (input) final[2] = raw[weights[1,1],2]
                else       final[1] = raw[weights[1,1],1]
            }
            slack = (radial[1]-final[1],final[2]-radial[2])
            benchmarks[j,] = (radial,final,slack)
            peers = peers \ (sourceobs[weights[,1]],weights[,2],raw[weights[,1],])
            stripe = stripe \ (J(rows(weights),1,models[j]),"peer":+strofreal(1::rows(weights)))
            st_store((j-1)*n:+weights[,1],"weight",weights[,2])
            st_store(ix,("sx","sy"),final)
        }
        dest = st_nobs() :+ (1::rows(area))
        st_addobs(rows(area))
        if (slackview) {
            if (models[j]=="crs") targets = crstargets
            else if (models[j]=="fdh") targets = _graphdea_slacktargets("fdh",rawpeaks,raw[selected,],objective,slackweights)
            else targets = _graphdea_slacktargets("vrs",rawhull,raw[selected,],objective,slackweights)
            alltargets = alltargets \ targets
            targetstripe = targetstripe \ (J(rows(targets),1,models[j]),"target":+strofreal(1::rows(targets)))
            slacksummary[j,1..2] = (max(targets[,cols(targets)]),rows(targets))
            if (sbm) slacksummary[j,3..4] = targets[1,5..6]
            st_store(dest[1::rows(targets)],("ax","ay"),targets[,(1,2)])
            st_store(dest[1],("slackx0","slacky0"),raw[selected,])
            if (models[j]!="fdh" & rows(targets)>1) st_store(dest[1..2],"targetface",(1 \ 1))
        }
        if (dispview) {
            st_store(dest[1..2],("dispx","dispy"),(focus \ (right*scale[1],focus[2])))
        }
        if (support) {
            multipliers[j,] = _graphdea_support(b,o,input,scale,(right,top),line)
            st_store(dest[1..2],("wx","wy"),line)
        }
        st_store(dest,"floor",J(rows(area),1,0))
        st_store(dest,"panel",J(rows(area),1,j))
        st_store(dest,("bx","top"),area:*scale)
        st_store(dest[|1 \ rows(b)|],"by",b[,2]*scale[2])
    }
    if (reference) {
        st_matrix(st_local("peers"),peers)
        st_matrixrowstripe(st_local("peers"),stripe)
        st_matrix(st_local("benchmarks"),benchmarks)
    }
    if (support) st_matrix(st_local("multipliers"),multipliers)
    if (slackview) {
        st_matrix(st_local("slacktargets"),alltargets)
        st_matrixrowstripe(st_local("slacktargets"),targetstripe)
        st_matrix(st_local("slacksummary"),slacksummary)
    }
    if (superview) st_matrix(st_local("superresults"),superresults)
    if (mixview) st_matrix(st_local("mixtures"),mixtures)
    if (dispview) st_matrix(st_local("disposal"),disposal)
    if (ddf) st_matrix(st_local("distances"),distances)
    st_matrix(st_local("scores"),result)
}

// Reflect a Pareto boundary into increasing-coordinate order for the upper hull.
// Return the requested boundary in ascending horizontal-axis order.
real matrix _graphdea_slicehull(real matrix bundles, real scalar shape, | real scalar fdh)
{
    real matrix hull
    real rowvector reflect
    if (args()==2) fdh = 0
    if (shape==3) {
        // Emissions are fixed by equality. Retain descending as well as rising edges.
        hull = sort(bundles,(1,-2))
        if (rows(hull)>1) hull = select(hull,1 \ (hull[2..rows(hull),1]:!=hull[1..(rows(hull)-1),1]))
        return(_graphdea_vrs(hull))
    }
    if (shape==0)      reflect = (1,-1)
    else if (shape==1) reflect = (-1,1)
    else               reflect = (1,1)
    hull = _graphdea_peaks(bundles:*reflect)
    if (!fdh) hull = _graphdea_vrs(hull)
    hull = hull:*reflect
    if (shape==1) hull = hull[rows(hull)::1,]
    return(hull)
}

real matrix _graphdea_vrssection(real matrix bundles, real colvector fixed,
    real scalar q, real scalar fixedinput, real scalar shape)
{
    real matrix cut, hull
    real colvector hi, lo, ratio
    real scalar i, j
    if (fixedinput) cut = select(bundles,fixed:<=q)
    else           cut = select(bundles,fixed:>=q)
    if (!rows(cut)) return(J(0,2,.))
    hull = _graphdea_slicehull(cut,shape)
    hi = selectindex(fixed:>q)
    lo = selectindex(fixed:<q)
    // New vertices of the sliced intensity simplex mix units straddling q.
    for (i=1; i<=length(lo) & length(hi)>0; i++) {
        j = lo[i]
        ratio = (q-fixed[j]):/(fixed[hi]:-fixed[j])
        cut = (1:-ratio)*bundles[j,] + ratio:*bundles[hi,]
        hull = _graphdea_slicehull(hull \ cut,shape)
    }
    return(hull)
}

void _graphdea_weakfrontier()
{
    real matrix obs, hull, path
    real colvector x
    real rowvector extent, plan, focus
    real scalar q, i, n, ymax, feasible, fraction, joint
    obs = st_data(.,(st_local("bad"),st_local("good")))
    x = st_data(.,st_local("input"))
    q = st_numscalar(st_local("budget"))
    if (st_local("rts")=="crs") hull = _graphdea_slicehull((0,0) \ (obs:*(q:/x)),3)
    else {
        // With one freely disposable input, the cheapest idle activity can
        // supply all inactive intensity in the VRS sum-to-one constraint.
        hull = _graphdea_vrssection(obs \ (0,0), x \ min(x),q,1,3)
    }
    n = rows(hull)
    st_matrix(st_local("vertices"),hull)
    extent = colmax(hull)
    if (st_local("plan")!="") {
        plan = strtoreal(tokens(st_local("plan")))
        extent = colmax(extent \ plan)
        ymax = .
        if (plan[1]<=hull[n,1]) {
            i = selectindex(hull[,1]:>=plan[1])[1]
            ymax = hull[i,2]
            if (hull[i,1]>plan[1]) {
                fraction = (plan[1]-hull[i-1,1])/(hull[i,1]-hull[i-1,1])
                ymax = (1-fraction)*hull[i-1,2]+fraction*hull[i,2]
            }
        }
        feasible = !missing(ymax) & plan[2]-ymax<=8*epsilon(1)*ymax
        joint = .
        if (st_local("focused")=="1") {
            focus = obs[selectindex(st_data(.,st_local("selected"))),]
            if (focus[1]>0 & plan[1]<=focus[1]) joint = (plan[1]/focus[1])*focus[2]
        }
        st_matrix(st_local("evaluation"),(plan,ymax,feasible,joint))
    }
    if (extent[1]==0) extent[1] = max(extent)
    if (extent[2]==0) extent[2] = max(extent)
    if (max(extent)==0) extent = (1,1)
    (void) _graphdea_axis("x",1.1,extent[1])
    (void) _graphdea_axis("y",1.1,extent[2])
    path = hull \ (hull[n,1],0)
    if (rows(path)>st_nobs()) st_addobs(rows(path)-st_nobs())
    st_store(1::rows(path),(st_local("bx"),st_local("by")),path)
    st_store(1::rows(path),st_local("floor"),J(rows(path),1,0))
}

// Complete a fixed-level boundary with its free-disposal extensions.
real matrix _graphdea_sectionpath(real matrix hull, real scalar outputset, real rowvector limits)
{
    if (outputset) return((0,hull[1,2]) \ hull \ (hull[rows(hull),1],0))
    return((hull[1,1],limits[2]) \ hull \ (limits[1],hull[rows(hull),2]))
}

void _graphdea_prepareslices()
{
    real matrix bundles, hull, cut
    real colvector fixed, row
    real rowvector scale, limits
    real scalar q, j, outputset
    string rowvector models, vars
    models = tokens(st_local("technologies"))
    vars = tokens(st_local("allhulls"))
    outputset = st_local("view")=="outputset"
    bundles = st_data(.,(st_local("axis1"),st_local("axis2")))
    fixed = st_data(.,st_local("fixed"))
    row = selectindex(st_data(.,st_local("selected")))
    q = st_numscalar(st_local("q"))
    scale = colmax(bundles)
    st_matrix(st_local("normscale"),scale)
    bundles = bundles:/scale
    limits = (0,0)
    if (length(row)) limits = bundles[row,]
    if (st_local("surface")!="") limits = colmax(bundles)
    for (j=1;j<=cols(models);j++) {
        if (models[j]=="crs") hull = _graphdea_slicehull(bundles:*(q:/fixed),outputset)
        else if (models[j]=="fdh") {
            // Keep observed corners in original units: independent axis
            // scaling can break exact ties between two FDH expansion factors.
            row = selectindex(outputset ? fixed:<=q : fixed:>=q)
            cut = st_data(row,(st_local("axis1"),st_local("axis2")))
            hull = _graphdea_slicehull(cut,outputset,1)
        }
        else hull = _graphdea_vrssection(bundles,fixed,q,outputset,outputset)
        if (rows(hull)>st_nobs()) st_addobs(rows(hull)-st_nobs())
        st_store(1::rows(hull),vars[(2*j-1)..(2*j)],hull)
        if (models[j]=="fdh") hull = hull:/scale
        limits = colmax(limits \ colmax(hull))
    }
    (void) _graphdea_axis("x",1.15*limits[1],scale[1])
    (void) _graphdea_axis("y",1.15*limits[2],scale[2])
}

// At the maximal radial expansion a further gain can occur in only one
// coordinate at a time. Its Pareto endpoint is a nondominated hull vertex,
// including the end of a convex free-disposal edge or either arm of an FDH step.
real matrix _graphdea_outputslacks(real matrix cut, real matrix quantities, real scalar factor,
    real rowvector radial)
{
    real matrix alternatives
    real rowvector target
    real colvector eligible
    real scalar j, other
    alternatives = J(0,6,.)
    for (j=1;j<=2;j++) {
        other = 3-j
        eligible = selectindex(cut[,other]:>=factor)
        if (!length(eligible)) continue
        target = radial
        target[j] = max(quantities[eligible,j])
        if (target[j]-radial[j] > 32*epsilon(1)*radial[j]) {
            alternatives = alternatives \ (radial,target,target-radial)
        }
    }
    if (!rows(alternatives)) return((radial,radial,0,0))
    return(alternatives)
}

void _graphdea_slice()
{
    real matrix hull, cut, boundary, points, alternatives, quantities
    real colvector dest, values, row
    real rowvector scale, observed, price, limits, edgepoint
    real scalar factor, optimum, xlo, xhi, outputset, fillto
    real scalar te, economic, ae, fdh
    string rowvector pointvars
    fdh = st_local("rts") == "fdh"
    outputset = st_local("view") == "outputset"
    scale = st_matrix(st_local("normscale"))
    hull = st_data(.,tokens(st_local("hullvars")),0)
    if (fdh) {
        quantities = hull
        hull = hull:/scale
    }
    limits = (strtoreal(st_local("xlimit")),strtoreal(st_local("ylimit"))):/scale
    row = selectindex(st_data(1::strtoreal(st_local("N")),st_local("selected")))
    if (length(row)) {
        observed = st_data(row,(st_local("axis1"),st_local("axis2")))
        // Consider vertices (including free-disposal faces) and ray/edge crossings.
        if (fdh) cut = quantities:/observed
        else     cut = hull:/(observed:/scale)
        factor = _graphdea_radialfactor(cut,outputset,fdh)
        points = (observed \ factor*observed), J(2,1,.)
        if (st_local("draw_slacks")!="") {
            if (!fdh) quantities = hull:*scale
            alternatives = _graphdea_outputslacks(cut,quantities,factor,points[2,1..2])
            st_matrix(st_local("alternatives"),alternatives)
            if (any(alternatives[,5..6])) {
                st_store(1::rows(alternatives),(st_local("from1"),st_local("from2"),
                    st_local("to1"),st_local("to2")),alternatives[,1..4])
            }
        }
        te = outputset ? 1/factor : factor
        st_local("te",strofreal(te,"%24.17g"))
        if (outputset) st_local("phi",strofreal(factor,"%24.17g"))
        if (st_local("prices") != "") {
            price = st_data(row,tokens(st_local("prices")))
            values = (hull:*scale)*price'
            optimum = outputset ? max(values) : min(values)
            edgepoint = hull[selectindex(values:==optimum)[1],]:*scale
            points = points \ (edgepoint,.)
            points[,3] = points[,1..2]*price'
            if (outputset) {
                ae = points[2,3]/optimum
                economic = points[1,3]/optimum
            }
            else {
                ae = optimum/points[2,3]
                economic = optimum/points[1,3]
            }
            st_local("ae",strofreal(ae,"%24.17g"))
            st_local("economic",strofreal(economic,"%24.17g"))
        }
        st_matrix(st_local("targets"),points)
    }
    if (fdh) hull = _graphdea_fdh(hull,outputset)
    boundary = _graphdea_sectionpath(hull,outputset,limits)
    fillto = outputset ? 0 : limits[2]*scale[2]
    if (rows(boundary)>st_nobs()) st_addobs(rows(boundary)-st_nobs())
    dest = 1::rows(boundary)
    st_store(dest,(st_local("bx"),st_local("by")),boundary:*scale)
    st_store(dest,st_local("cap"),J(rows(boundary),1,fillto))
    if (length(row)) {
        pointvars = (st_local("px"),st_local("py"))
        st_store(1::rows(points),pointvars,points[,1..2])
        if (st_local("prices") != "") {
            // Clip the supporting price line to the visible first-quadrant window.
            xlo = max((0,(optimum-price[2]*limits[2]*scale[2])/price[1]))
            xhi = min((limits[1]*scale[1],optimum/price[1]))
            st_store((1\2),st_local("ix"),(xlo\xhi))
            st_store((1\2),st_local("iy"),(optimum:-price[1]*(xlo\xhi)):/price[2])
        }
    }
}

// Return the segments inside the plotted unit box. Never connect two clipped
// pieces by an artificial edge along the outside of the box.
real matrix _graphdea_clipline(real matrix path, real scalar kind)
{
    real matrix segments
    real rowvector a, d
    real scalar i, j, k, lo, hi, t0, t1
    segments = J(rows(path)-1,7,.)
    k = 0
    for (i=2; i<=rows(path); i++) {
        a = path[i-1,]
        d = path[i,]-a
        if (!any(d)) continue
        lo = 0
        hi = 1
        for (j=1; j<=3; j++) {
            if (d[j]==0) {
                if (a[j]<0 | a[j]>1) hi = -1
            }
            else {
                t0 = -a[j]/d[j]
                t1 = (1-a[j])/d[j]
                lo = max((lo,min((t0,t1))))
                hi = min((hi,max((t0,t1))))
            }
        }
        if (hi>lo) segments[++k,] = (kind,a+lo*d,a+hi*d)
    }
    if (!k) return(J(0,7,.))
    return(segments[|1,1 \ k,7|])
}

// For each cutting plane construct its DEA boundary, including disposal edges.
// perm lists the two in-plane coordinates followed by the slicing coordinate.
real matrix _graphdea_meshline(real matrix data, real rowvector perm,
    real scalar q, real scalar fixedinput, real scalar shape)
{
    real matrix h, path
    h = _graphdea_vrssection(data[,perm[1..2]],data[,perm[3]],q,fixedinput,shape)
    if (!rows(h)) return(J(0,7,.))
    if (shape==1) path = (0,h[1,2]) \ h \ (h[rows(h),1],0)
    else {
        path = h \ (max((1,h[rows(h),1])),h[rows(h),2])
        if (shape==0) path = (h[1,1],max((1,h[1,2]))) \ path
        else          path = (h[1,1],0) \ path
    }
    path = path,J(rows(path),1,q)
    return(_graphdea_clipline(path[,order(perm',1)'],1))
}

// Between consecutive changes in the eligible FDH corners, the same
// staircase extends vertically. Both rims and the uprights are axis-aligned.
real matrix _graphdea_fdhslab(real matrix path, real scalar za, real scalar zb)
{
    real matrix low, high
    real colvector start, stop
    real scalar n
    n = rows(path)
    low = path,J(n,1,min((za,zb)))
    high = path,J(n,1,max((za,zb)))
    start = 1::(n-1)
    stop = start:+1
    return((J(n-1,1,1),low[start,],low[stop,]) \
           (J(n-1,1,1),high[start,],high[stop,]) \ (J(n,1,1),low,high))
}

real matrix _graphdea_fdhmesh(real matrix obs, real scalar outputset)
{
    real matrix data, groups, corners, nextcorners, path, nextpath, mesh
    real scalar i, j, from, to, level, previous
    real rowvector a, b
    // As input budget rises (or required output falls), observations enter.
    data = sort(obs,outputset ? 3 : -3)
    groups = panelsetup(data,3)
    corners = J(0,2,.)
    path = J(2,2,1-outputset)
    mesh = J(0,7,.)
    for (i=1;i<=rows(groups);i++) {
        from = groups[i,1]
        to = groups[i,2]
        level = data[from,3]
        nextcorners = _graphdea_slicehull(corners \ data[|from,1 \ to,2|],outputset,1)
        if (rows(corners)==rows(nextcorners)) {
            if (all(nextcorners:==corners)) continue
        }
        nextpath = _graphdea_sectionpath(_graphdea_fdh(nextcorners,outputset),outputset,(1,1))
        if (rows(corners)) mesh = mesh \ _graphdea_fdhslab(path,previous,level)
        // Close the exposed ledge where it meets the sides of the plot window.
        for (j=1;j<=2;j++) {
            a = path[j==1 ? 1 : rows(path),]
            b = nextpath[j==1 ? 1 : rows(nextpath),]
            if (any(a:!=b)) mesh = mesh \ (1,a,level,b,level)
        }
        corners = nextcorners
        path = nextpath
        previous = level
    }
    mesh = mesh \ _graphdea_fdhslab(path,previous,outputset)
    return(uniqrows(sort(mesh,1..7)))
}

// Painter ordering for one horizontal face, adapted from the projected polygon
// layers in Choonjoo Lee's From automatic layout to 3D geometry example.
// See the graphics reference in help graphdea for the related Statalist discussion.
// Split a crossing exactly at z=q so only its far portion goes below the fill.
real matrix _graphdea_sectiondepth(real matrix source, real scalar q, real scalar elevation)
{
    real matrix drawing, behind
    real rowvector a, b, cut
    real scalar i, k, side, da, db
    side = sign(elevation)
    if (!side) return(source)
    drawing = source
    behind = J(rows(drawing),7,.)
    k = 0
    for (i=1; i<=rows(drawing); i++) {
        a = drawing[i,2..4]
        da = side*(a[3]-q)
        if (drawing[i,1]==4 & da < -1e-12) drawing[i,1]=10
        if (drawing[i,1]!=1) continue
        b = drawing[i,5..7]
        db = side*(b[3]-q)
        if (abs(da)<=1e-12) da=0
        if (abs(db)<=1e-12) db=0
        if (min((da,db))>=0) continue
        if (max((da,db))<=0) {
            drawing[i,1]=9
            continue
        }
        cut = a + (da/(da-db))*(b-a)
        if (da<0) {
            behind[++k,]=(9,a,cut)
            drawing[i,2..4]=cut
        }
        else {
            behind[++k,]=(9,cut,b)
            drawing[i,5..7]=cut
        }
    }
    if (k) return(drawing \ behind[|1,1 \ k,7|])
    return(drawing)
}

void _graphdea_surface()
{
    real matrix obs, data, drawing, path, world, proj, bounds, points, horizontal, ends, face
    real colvector sample, levels, visible, boundaryrows, dest, roles, shared
    real rowvector lim, base, tip, tick, location, offset, along, labelpos
    real scalar outputset, q, n, i, j, k, step, stepcount, top, az, el, length2d, other, stride
    string colvector labels, pointlabels
    string rowvector names

    n = strtoreal(st_local("N"))
    sample = 1::n
    names = (st_local("axis1"),st_local("axis2"),st_local("fixed"))
    obs = st_data(sample,names)
    q = st_numscalar(st_local("q"))
    top = max((q,max(obs[,3])))
    lim = (strtoreal(st_local("xlimit")),strtoreal(st_local("ylimit")),
           _graphdea_axis("z",1.1,top)*top)
    outputset = st_local("view")=="outputset"
    obs = obs:/lim
    data = obs
    if (st_local("rts")=="crs") {
        // Truncate the cone at the largest total input allowed by the box.
        // Its convex hull with the origin equals the cone throughout the box.
        if (outputset) data = data :/ data[,3]
        else           data = data :* (2:/rowsum(data[,1..2]))
        data = (0,0,0) \ data
    }

    if (st_local("rts")=="fdh") drawing = _graphdea_fdhmesh(obs,outputset)
    else {
        drawing = J(0,7,.)
        // Include the feasible interval endpoints, even for a narrow or flat VRS set.
        levels = uniqrows(sort((rangen(0,1,9) \ min(obs[,3]) \ max(obs[,3])),1))
        for (i=1; i<=rows(levels); i++) {
            if (abs(levels[i]-q/lim[3])>1e-12) {
                drawing = drawing \ _graphdea_meshline(data,(1,2,3),levels[i],outputset,outputset)
            }
        }
        levels = uniqrows(sort((rangen(0,1,11) \ min(obs[,1]) \ max(obs[,1])),1))
        for (i=1; i<=rows(levels); i++) {
            // Mixed sections always put input on their first axis and output second.
            if (outputset) drawing = drawing \ _graphdea_meshline(data,(3,2,1),levels[i],0,2)
            else           drawing = drawing \ _graphdea_meshline(data,(2,3,1),levels[i],1,2)
        }
    }

    // Lift the actual vertices used by the adjacent two-dimensional graph.
    boundaryrows = selectindex(st_data(.,st_local("bx")):<.)
    horizontal = st_data(boundaryrows,(st_local("bx"),st_local("by"))) :/ lim[1..2]
    path = horizontal,J(rows(horizontal),1,q/lim[3])
    drawing = drawing \ _graphdea_clipline(path,2)

    visible = selectindex(rowmax(obs):<=1)
    drawing = drawing \ (J(length(visible),1,4), obs[visible,], J(length(visible),3,.))
    el = strtoreal(st_local("elevation")) * pi()/180
    if (st_local("sectionfill")!="" & el!=0) {
        drawing = _graphdea_sectiondepth(drawing,q/lim[3],el)
        // Complete the same clipped free-disposal polygon shaded in panel (b).
        if (outputset) face = path \ (0,0,q/lim[3]) \ path[1,]
        else           face = path \ (1,1,q/lim[3]) \ path[1,]
        drawing = drawing \ (J(rows(face),1,11),face,J(rows(face),3,.))
    }
    labels = J(rows(drawing),1,"")
    if (strtoreal(st_local("focused"))) {
        points = st_matrix(st_local("targets"))
        points = (points[,1..2]:/lim[1..2]),J(rows(points),1,q/lim[3])
        pointlabels = st_sdata(1::rows(points),st_local("role"))
        if (st_local("draw_radial")!="" & any(points[1,]:!=points[2,])) {
            drawing = drawing \ (5,points[1,],points[2,])
            labels = labels \ ""
        }
        roles = selectindex(pointlabels:!="")
        drawing = drawing \ (J(length(roles),1,6),points[roles,],J(length(roles),3,.))
        labels = labels \ pointlabels[roles]
    }

    // Orthographic camera. At zero azimuth axis 1 points right and the
    // observer is on the negative axis-2 side. Elevation is above the base.
    az = strtoreal(st_local("azimuth")) * pi()/180
    proj = (cos(az),-sin(az)*sin(el) \ sin(az),cos(az)*sin(el) \ 0,cos(el))
    proj = proj :* (abs(proj):>1e-14)
    proj = (lim'/max(lim)) :* proj
    proj = proj / max(sqrt(rowsum(proj:^2)))
    world = (drawing[,1],drawing[,2..4]*proj,drawing[,5..7]*proj)
    // Distinct targets can coincide in this view, e.g. along the line of sight.
    roles = selectindex(world[,1]:==6)
    for (i=2; i<=length(roles); i++) {
        for (j=1; j<i; j++) {
            if (world[roles[j],1]==6 & max(abs(world[roles[i],2..3]-world[roles[j],2..3]))<1e-12) {
                labels[roles[j]] = labels[roles[j]] + "/" + labels[roles[i]]
                world[roles[i],1] = 0
                break
            }
        }
    }
    ends = J(0,3,.)
    for (j=1; j<=3; j++) {
        along = proj[j,]
        length2d = sqrt(along*along')
        if (length2d<1e-12) continue
        base = (0,0,0)
        if (j==3) {
            // Use the left silhouette edge for the vertical scale.
            base[1] = proj[1,1]<0
            base[2] = proj[2,1]<0
            offset = (-1,0)
        }
        else {
            other = 3-j
            offset = (along[2],-along[1])/length2d
            if (offset[2]>0 | (offset[2]==0 & offset[1]>0)) offset = -offset
            // Near a level view both horizontal axes can project onto the same
            // line. Put the second scale on the opposite edge in that case.
            if (j==2 & abs(el)<.05 & abs(proj[1,1])>.05 & abs(along[1])>.05) {
                offset = -offset
            }
            base[other] = proj[other,]*offset'>0
            base[3] = proj[3,]*offset'>0
        }
        tick = base*proj
        world = world \ (3,tick,tick+along)
        labels = labels \ ""
        step = strtoreal(st_local(("xstep","ystep","zstep")[j]))
        stepcount = round(lim[j]/step)
        stride = max((1,ceil(.075*stepcount/length2d)))
        for (k=0; k<=stepcount; k++) {
            if (k!=stepcount & mod(k,stride)!=0) continue
            tick = base*proj + along*(k/stepcount)
            labelpos = tick+.05*offset
            if (rows(ends) & (k==0 | k==stepcount)) {
                shared = selectindex(rowsum((ends[,1..2]:-tick):^2):<1e-20)
                if (length(shared)) {
                    if (k==0 | any(ends[shared,3]:==k*step)) continue
                    labelpos = labelpos-.055*along/length2d
                }
            }
            // A nearly end-on scale has room for only one number.
            if (length2d<.075 & k!=stepcount) continue
            world = world \ (3,tick,tick+.016*offset) \ (7,labelpos,.,.)
            labels = labels \ "" \ strtrim(strofreal(k*step,"%10.4g"))
        }
        ends = ends \ (base*proj,0) \ (base*proj+along,stepcount*step)
        location = base*proj + .5*along + .17*offset
        if (j==3) location = base*proj + along + (0,.10)
        world = world \ (8,location,.,.)
        labels = labels \ (st_varlabel(names[j])!="" ? st_varlabel(names[j]) : names[j])
    }
    bounds = world[,2..3] \ select(world[,4..5],world[,4]:<.)
    base = colmin(bounds) :- (.12,.09)
    tip = colmax(bounds) :+ (.12,.09)
    st_local("umin",strofreal(base[1],"%24.17g"))
    st_local("umax",strofreal(tip[1],"%24.17g"))
    st_local("vmin",strofreal(base[2],"%24.17g"))
    st_local("vmax",strofreal(tip[2],"%24.17g"))
    if (rows(world)>st_nobs()) st_addobs(rows(world)-st_nobs())
    dest = 1::rows(world)
    st_store(dest,(st_local("kind"),st_local("u"),st_local("v"),st_local("uend"),st_local("vend")),world)
    st_sstore(dest,st_local("label"),labels)
}
end
