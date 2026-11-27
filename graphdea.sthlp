{smcl}
{* *! version 0.30.1  27nov2026}{...}
{vieweralsosee "graph export" "help graph export"}{...}
{viewerjumpto "Description" "graphdea##description"}{...}
{viewerjumpto "Syntax" "graphdea##syntax"}{...}
{viewerjumpto "Quick start" "graphdea##quickstart"}{...}
{viewerjumpto "Guide to views" "graphdea##views"}{...}
{viewerjumpto "Graph appearance" "graphdea##appearance"}{...}
{viewerjumpto "Examples" "graphdea##examples"}{...}
{viewerjumpto "Stored results" "graphdea##results"}{...}
{title:graphdea — Data envelopment analysis graphs}

{marker description}{...}
{title:Description}

{pstd}{cmd:graphdea} draws data envelopment analysis (DEA) graphs from the
dataset in memory. It supports one input and one output, two inputs and one
output, or one input and two outputs. Each selected observation represents
a decision-making unit (DMU), or a DMU in a particular period for a
productivity comparison. The command draws a monochrome Stata graph, stores
view-specific results in {cmd:r()}, and preserves the dataset. It requires
Stata 16 or later and includes its Mata calculations.{p_end}

{marker syntax}{...}
{title:Syntax}

{p 8 12 2}
{cmd:graphdea} {it:input} {cmd:=} {it:output} {ifin} [{cmd:,} {it:options}]

{p 8 12 2}
{cmd:graphdea} {it:output} {ifin}{cmd:, inputs(}{it:input}{cmd:)} [{it:options}]

{p 8 12 2}
{cmd:graphdea} {it:input1 input2} {cmd:=} {it:output} {ifin}{cmd:,}
[{cmd:view(isoquant)}] [{cmd:at(}{it:focus | outputvar=#}{cmd:)}] [{it:options}]

{pstd}The output-first form also accepts {cmd:inputs(}{it:input1 input2}{cmd:)}.
With two inputs the default view is isoquant. With a selected DMU, the default
slice is its observed output, {cmd:at(focus)}.

{p 8 12 2}
{cmd:graphdea} {it:input} {cmd:=} {it:output1 output2} {ifin}{cmd:,}
[{cmd:view(outputset)}] [{cmd:at(}{it:focus | inputvar=#}{cmd:)}] [{it:options}]

{pstd}Two outputs select {cmd:view(outputset)} by default. The output-first
form is {cmd:graphdea} {it:output1 output2}{cmd:, inputs(}{it:input}{cmd:)}.
For either cross-section, supply an explicit slice or select a focus DMU.

{p 8 12 2}{cmd:graphdea} {it:input} {cmd:=} {it:good_output} {ifin}{cmd:, bad(}{it:undesirable_output}{cmd:)}
[{cmd:view(weakdisposal)} {cmd:at(}{it:focus | inputvar=#}{cmd:)} {cmd:plan(}{it:bad good}{cmd:)}]{p_end}

{pstd}The production diagrams use the same physical length per numeric unit on the horizontal
and vertical axes. Equal axis ranges produce a square plotting area. When the
ranges differ, the plotting area's height and width reflect their ratio.

{pstd}For fonts, colors, and reusable Graph Editor recordings, see
{help graphdea##appearance:Customizing graph appearance}.{p_end}

{marker quickstart}{...}
{title:Quick start}

{pstd}With your data in memory, substitute your input and output variable
names for {cmd:labor} and {cmd:output}. The first command draws the reference
frontier. The second evaluates plant D under variable returns to scale.
Replace {cmd:plant} and {cmd:"D"} with your identifier variable and a value
present in the selected sample.{p_end}

{phang2}{cmd:. graphdea labor = output}{p_end}
{phang2}{cmd:. graphdea labor = output, rts(vrs) dmu(plant) focus("D")}{p_end}
{phang2}{cmd:. matrix list r(projections)}{p_end}
{phang2}{cmd:. return list}{p_end}
{phang2}{cmd:. graph export "frontier.pdf"}{p_end}

{pstd}To try a complete example with its own data, use {cmd:net get} from
the same package directory or URL used for installation. Substitute that
location below. The files are copied to the current working directory by
default. The example restores the dataset in memory and leaves its named
graph available.{p_end}

{phang2}{cmd:. net get graphdea, from("/path/to/package")}{p_end}
{phang2}{cmd:. do example_1x1.do}{p_end}
{phang2}{cmd:. graph display dea_1x1}{p_end}

{marker views}{...}
{title:Guide to views}

{phang}For one input and one output, start with the
{help graphdea##production:production diagram}, including radial projections,
peers, slacks, and multiplier weights. For technology assumptions, see
{help graphdea##scale:returns to scale}, {help graphdea##convexity:convexity},
and {help graphdea##disposal:free disposability}.{p_end}

{phang}For efficiency measures, see {help graphdea##ddf:directional distance},
{help graphdea##additive:additive efficiency}, {help graphdea##super:super-efficiency},
and {help graphdea##sbm:slacks-based efficiency}.{p_end}

{phang}For two inputs or two outputs, see the
{help graphdea##isoquant:input isoquant and cost efficiency},
{help graphdea##outputset:output set and revenue efficiency}, {help graphdea##surface:three-dimensional surface}, or
{help graphdea##weakdisposal:joint weak disposability with an undesirable output}.{p_end}

{phang}For panel data, see {help graphdea##malmquist:two-period productivity},
{help graphdea##multifrontiers:two-input or two-output frontiers},
{help graphdea##overview:comparisons across DMUs}, {help graphdea##chain:chained indices},
and {help graphdea##global:global benchmarks}.{p_end}

{title:Compare technologies on your own data}

{pstd}With your data in memory and {cmd:graphdea.ado} on the ado-path,
call {cmd:graphdea} directly. Supply numeric quantity variables in input = output
order, or list the outputs first and use {cmd:inputs()}. Variable labels supply
axis titles. After {cmd:if} and {cmd:in}, observations with missing quantities
are excluded. Quantities must be strictly positive except that either or both
outputs may be zero in {cmd:view(weakdisposal)}. A focus
must identify one included observation, or one per selected period in
{cmd:view(malmquist)}. Quote string identifiers with
spaces. For numeric identifiers, use the underlying value even when a value
label is displayed.{p_end}

{phang}{cmd:compare(}{it:technologies}{cmd:)} draws a planar section for each
listed technology in order. Choose any distinct subset of {cmd:crs vrs fdh}.
The panels share the reference sample, slice level, focus prices, axis limits,
tick spacing, and length per coordinate unit. With a focus, the slice defaults
to its observed output or input. For a boundary-only comparison use an explicit
{cmd:at(}{it:fixedvar}{cmd:=}{it:#}{cmd:)}. The level must be feasible for
each requested technology. {cmd:w()} or {cmd:p()} accepts two price variables
in axis order; both prices must be positive at the focus. {cmd:show()},
{cmd:title()}, {cmd:xtitle()}, {cmd:ytitle()} and {cmd:name()} also apply.{p_end}

{phang2}{cmd:. graphdea labor capital = sales if year==2024, dmu(plant) focus("North Plant") compare(vrs fdh) w(wage rent)}{p_end}
{phang2}{cmd:. matrix list r(efficiency)}{p_end}
{phang2}{cmd:. matrix list r(targets)}{p_end}
{phang2}{cmd:. graphdea good1 good2, inputs(hours) compare(crs vrs fdh) at(hours=10)}{p_end}

{marker surface}{...}
{title:Three-dimensional frontier and its cross-section}

{pstd}{cmd:view(surface)} draws a native Stata figure for either two inputs and
one output, or one input and two outputs. Choose {cmd:rts(crs)} (the default),
{cmd:rts(vrs)}, or {cmd:model(fdh)}. The two quantities of the same type are the horizontal axes.
The third quantity is the vertical axis. The orthographic projection uses a
common scale in original units before rotation. The default view is isometric.
When the angle changes, axes pointing toward the viewer appear shorter.

{phang}{cmd:azimuth(}{it:#}{cmd:)} rotates the camera around the vertical axis in
degrees. At 0 the viewer faces the plot from the negative side of the second
horizontal axis, with the first axis pointing right. At 90 the viewer looks
from the positive side of the first axis. Angles wrap every 360 degrees.
The default is 45.{p_end}

{phang}{cmd:elevation(}{it:#}{cmd:)} sets the viewing height in degrees, from
-90 (directly below) through 0 (level) to 90 (directly above). The default is
approximately 35.2644. Either angle may be supplied alone. An axis pointing
directly at the camera projects to a point and its tick labels are omitted.
The adjacent cross-section retains its original orientation.{p_end}

{phang2}{cmd:. graphdea labor capital = output, view(surface) rts(vrs) dmu(firm) focus("D") azimuth(135) elevation(25)}{p_end}
{phang2}{cmd:. graphdea labor capital = output, view(surface) rts(vrs) dmu(firm) focus("D") azimuth(0) elevation(90)}{p_end}

{pstd}In panel (a), dots mark observations and a black line highlights the
selected horizontal section. For CRS and VRS, grey lines trace the DEA
boundary in sampled horizontal and vertical cutting planes, clipped to the
plotting window.{p_end}

{pstd}For {cmd:model(fdh)}, the staircase changes only when an observed activity
becomes eligible as the required output falls (two inputs) or the input
budget rises (two outputs). The wireframe joins identical staircase corners
vertically between successive changes. A narrow terrace is drawn at its
observed levels. Shared levels enter together. The black outline and optional
shaded face trace the same feasible section as panel (b).{p_end}

{phang2}{cmd:. graphdea labor capital = output, view(surface) model(fdh) dmu(firm) focus("D") azimuth(135) elevation(25) sectionfill}{p_end}

{phang}{cmd:sectionfill} fills the selected feasible section in panel (a) with
an opaque grey polygon. At fixed output it covers the feasible input bundles
above and to the right of the boundary, clipped to the plot window. At fixed
input it covers the feasible output bundles toward the origin. The face uses
the same boundary vertices as panel (b). Mesh segments crossing the selected
level are split there. The face masks the parts of far-side lines and observed
points that it covers in the projection. At {cmd:elevation(0)} the section
is seen edge-on and appears as a line. The default surface uses a wireframe.
The {cmd:show()} option controls shading in panel (b) separately.{p_end}

{phang2}{cmd:. graphdea labor capital = output, view(surface) rts(vrs) dmu(firm) focus("D") azimuth(135) elevation(25) sectionfill}{p_end}

{pstd}Panel (b) plots the highlighted boundary in its own coordinates, with
equal lengths per unit on both axes. {cmd:focus()} sets the section to the
selected DMU's level and adds its point D. The radial target R, and the cost
minimum C or revenue maximum M when prices are supplied, follow the same
{cmd:show()}, price and orientation options as the corresponding two-dimensional
view. {cmd:at(}{it:verticalvar=#}{cmd:)} sets an explicit level. Without either
a focus or an explicit level, the surface uses the sample median of the
vertical variable. In a focused graph the level must match the DMU.

{pstd}{cmd:title()} names the combined figure. The three-dimensional axes
use variable labels (or names); {cmd:xtitle()} and {cmd:ytitle()} customize
the adjacent two-dimensional axes. {cmd:name()} names the combined graph.
The returned output or input level, score and target matrix follow the same
conventions as the corresponding section command. {cmd:r(azimuth)} and
{cmd:r(elevation)} store the viewing angles in degrees, with the azimuth in [0,360).{p_end}

{marker scale}{...}
{title:Scale efficiency in one input and one output}

{p 8 12 2}{cmd:graphdea} {it:input} {cmd:=} {it:output} {ifin}{cmd:, view(scale) dmu(}{it:idvar}{cmd:) focus(}{it:id}{cmd:)}
[{cmd:orientation(input|output)} {cmd:title()} {cmd:xtitle()} {cmd:ytitle()} {cmd:name()}]

{pstd}The dashed CRS frontier and solid VRS frontier share one set of axes.
The ring marks the selected DMU, the square its CRS radial target, and the
diamond its VRS radial target. The guide from the selected unit runs horizontally
at fixed output for input orientation (the default) or vertically at fixed input
for output orientation. When the targets coincide, the diamond sits inside the square.

{pstd}Scale efficiency (SE) is CRS technical efficiency divided by VRS technical
efficiency in the selected orientation. On the input graph this equals CRS target
input divided by VRS target input. On the output graph it equals VRS target
output divided by CRS target output, using TE = 1/phi. The subtitle reports the
scores to three decimals. {cmd:view(scale)} fixes the technologies and layers.
Use {cmd:compare(crs vrs)} for separate production panels with selectable layers.

{pstd}The subtitle gives the returns to scale at the selected orientation's VRS
radial target. The auxiliary non-increasing returns to scale (NIRS) model imposes
sum(lambda) <= 1. If CRS and VRS efficiencies agree, the classification is
constant (CRS). Otherwise, agreement between NIRS and VRS gives decreasing
returns (DRS), and a difference gives increasing returns (IRS). Scores are
compared before rounding, with tolerance 1e-10 relative to the VRS score.
For an inefficient unit the two orientations can reach different frontier
segments and hence give different classifications.{p_end}

{phang2}{cmd:. graphdea x = y, view(scale) dmu(id) focus("D") orientation(output)}{p_end}
{phang2}{cmd:. display r(se)}{p_end}
{phang2}{cmd:. display "`r(rts)'"}{p_end}
{phang2}{cmd:. display r(te_nirs)}{p_end}

{marker convexity}{...}
{title:Convexity with one input and one output}

{p 8 12 2}{cmd:graphdea} {it:input} {cmd:=} {it:output} {ifin}{cmd:, view(convexity) dmu(}{it:idvar}{cmd:) pair(}{it:first_id second_id}{cmd:)}
[{cmd:share(}{it:#}{cmd:)} {cmd:compare(}{it:technologies}{cmd:)}]{p_end}

{pstd}The dashed segment joins the two observed production plans. The diamond
marks the plan obtained by combining a share of the first DMU with the
remaining share of the second. The same shares apply to both input and
output. {cmd:share()} defaults to 0.5 and accepts values from 0 to 1,
including the endpoints. Each ID must select one distinct observation in
the reference sample. Quote string IDs that contain spaces.{p_end}

{pstd}By default, two panels compare VRS and FDH on the same axes. VRS
includes the entire segment by convexity. FDH includes the chosen point
if an observed DMU uses at most the mixed input and produces at least the
mixed output. All reference observations can establish this, including
units outside the pair. Shading shows the feasible set in each panel.
Use {cmd:model(fdh)} or {cmd:rts(vrs)} for a single panel, or
{cmd:compare(crs vrs fdh)} to include CRS.{p_end}

{phang2}{cmd:. graphdea hours = units if year == 2024, view(convexity) dmu(plant) pair("North site" "South site") share(.75)}{p_end}
{phang2}{cmd:. matrix list r(mixture)}{p_end}

{marker disposal}{...}
{title:Free disposability with one input and one desirable output}

{p 8 12 2}{cmd:graphdea} {it:input} {cmd:=} {it:output} {ifin}{cmd:, view(disposability) dmu(}{it:idvar}{cmd:) focus(}{it:id}{cmd:)}
[{cmd:plan(}{it:input_value output_value}{cmd:)} {cmd:compare(}{it:technologies}{cmd:)}]{p_end}

{pstd}The darker rectangle shows the plans attainable from the selected
observation (x0,y0) by free disposal alone. These plans have x >= x0
and 0 <= y <= y0. The rectangle continues to the right beyond the plotting
window. Light gray shows the feasible set estimated using all observations in
the reference sample. The default panels compare VRS and FDH. Use
{cmd:rts(crs)}, {cmd:rts(vrs)}, or {cmd:model(fdh)} for a single panel.{p_end}

{pstd}{cmd:plan()} adds a diamond at the proposed quantities. Enter two
nonnegative numbers in the original units, input first in either command syntax.
Each panel reports whether the plan follows from the selected DMU and whether
it belongs to the technology. The same focus and plan are used in all panels.
Omit {cmd:plan()} to draw the regions alone.{p_end}

{phang2}{cmd:. graphdea hours = units if year==2024, view(disposability) dmu(plant) focus("North site") plan(7 6.5)}{p_end}
{phang2}{cmd:. matrix list r(disposal)}{p_end}

{marker weakdisposal}{...}
{title:Joint weak disposability of a desirable output and an undesirable output}

{pstd}{cmd:bad()} selects {cmd:view(weakdisposal)}. Give the undesirable
output separately from the desirable output on the command line. The
horizontal axis shows the exact undesirable output (for example, tonnes of
emissions). The vertical axis shows the desirable output. The shaded region
contains attainable combinations at the input budget. Observed activities
within budget are marked by dots. All complete reference observations
contribute to estimation, including higher-input activities in feasible mixes.{p_end}

{pstd}Supply {cmd:dmu()} and {cmd:focus()} to use the selected DMU's input,
or {cmd:at(}{it:inputvar}{cmd:=}{it:#}{cmd:)} for an explicit positive
budget. VRS is the default. {cmd:rts(crs)} uses constant returns to scale.
Each view displays one technology. Each output must be nonnegative.
An observation may produce positive desirable output at zero emissions.{p_end}

{pstd}The model uses nonnegative active intensities z and idle intensities w.
At input budget q and exact emissions b, it maximizes Y'z subject to
X'(z+w) <= q and B'z = b. VRS also imposes sum(z+w) = 1. Desirable output
can be freely reduced below the maximum. Along the dashed segment from the
origin to the selected DMU, both outputs change in the same proportion.
Combinations with other DMUs can deliver more desirable output at the same
emissions. The upper boundary can also slope downwards at high emissions.{p_end}

{pstd}The active and idle intensities follow the
{browse "https://github.com/renegade68/DEA-Stata/blob/main/ado/dea.sthlp":DEA-Stata weak-disposability specification}.
For the model with activity-specific abatement factors, see
{browse "https://doi.org/10.1111/j.1467-8276.2005.00788.x":Kuosmanen (2005)}.{p_end}

{pstd}{cmd:plan(}{it:b y}{cmd:)} specifies exact emissions first and proposed
desirable output second, in original units. A diamond marks the plan. With
a focus having positive emissions, a plus marks proportional output when the
specified emissions lie on its contraction segment.
{cmd:show(pps frontier contraction)} selects layers. The contraction layer requires a focus.
The default shows the feasible set, boundary and, with a focus, the segment.{p_end}

{phang2}{cmd:. graphdea hours = units if year==2024, bad(emissions) dmu(plant) focus("North site") plan(3 6)}{p_end}
{phang2}{cmd:. graphdea units, inputs(hours) bad(emissions) at(hours=10) rts(crs)}{p_end}
{phang2}{cmd:. matrix list r(frontier)}{p_end}

{marker ddf}{...}
{title:Directional distance with one input and one output}

{p 8 12 2}{cmd:graphdea} {it:input} {cmd:=} {it:output} {ifin}{cmd:, view(ddf) dmu(}{it:idvar}{cmd:) focus(}{it:id}{cmd:)}
[{cmd:gx(}{it:# | varname}{cmd:)} {cmd:gy(}{it:# | varname}{cmd:)} {cmd:compare(crs vrs fdh)}]{p_end}

{pstd}{cmd:view(ddf)} draws an arrow from the selected observation (x0,y0) to
the last feasible point (x0 - beta*gx, y0 + beta*gy). The square marks
that target even when the distance is zero. Each panel uses the indicated
technology and the same direction. CRS is the default.{p_end}

{pstd}{cmd:gx()} is the amount of input to save and {cmd:gy()} the amount
of output to gain per unit of beta. Each accepts a nonnegative number or a
numeric variable evaluated at the selected DMU. An omitted component uses
the DMU's observed input or output, respectively. Use {cmd:gx(0)} to hold
input fixed or {cmd:gy(0)} to hold output fixed. At least one component must
be positive. Direction variables are needed only at the focus. The
reference sample uses the complete input and output observations in {cmd:if}/{cmd:in}.{p_end}

{pstd}Beta measures the available improvement in multiples of the chosen
direction. Doubling both direction components halves beta and leaves the
target in place. A zero beta indicates that no further movement in this
direction is feasible. Movement in another direction may still be possible,
for example at a corner of an FDH step.{p_end}

{pstd}The default layers in {cmd:view(ddf)} are the feasible set, frontier,
and directional projection. Add {cmd:show(pps frontier radialin radialout)}
to compare the three targets. Alternatively, add {cmd:ddf} to the
{cmd:show()} list in the ordinary production diagram.{p_end}

{phang2}{cmd:. graphdea hours = output, view(ddf) rts(vrs) dmu(firm) focus("D") gx(1) gy(1)}{p_end}
{phang2}{cmd:. matrix list r(ddf)}{p_end}
{phang2}{cmd:. graphdea sales if year==2024, inputs(labor) dmu(plant) focus(12) view(ddf) gx(hours_saved) gy(sales_gained) compare(crs vrs fdh)}{p_end}

{marker additive}{...}
{title:Additive DEA with one input and one desirable output}

{p 8 12 2}{cmd:graphdea} {it:input} {cmd:=} {it:output} {ifin}{cmd:, view(additive) dmu(}{it:idvar}{cmd:) focus(}{it:id}{cmd:)}
[{cmd:slackweights(}{it:input_weight output_weight}{cmd:)} {cmd:compare(crs vrs fdh)}]{p_end}

{pstd}For the selected observation (x0,y0), a target (x,y) must be feasible
with x <= x0 and y >= y0. The model maximizes the weighted sum of the input
saving (x0 - x) and output gain (y - y0). A zero optimum means the DMU
is Pareto efficient. A positive value measures the available weighted
improvement in the chosen units. Both slack weights must be positive.
The default {cmd:slackweights(1 1)} gives the ordinary additive model.
If hours are converted to minutes, divide the input weight by 60 to preserve
the same objective and physical targets.{p_end}

{pstd}{cmd:model(additive)} also selects this view. The default technology
is VRS. Use {cmd:rts(crs)}, {cmd:model(fdh)} with {cmd:view(additive)}, or
{cmd:compare()} to select technologies. Each panel uses the same sample,
focus, weights, and axes. Open diamonds mark optimal targets. For a tied
CRS or VRS optimum, every point on the highlighted segment is optimal. FDH
can yield several distinct optimal observed bundles, shown separately.{p_end}

{pstd}The default {cmd:show(pps frontier slacks)} draws the feasible set,
boundary, and horizontal and vertical arrows for the additive slacks.
When optima are tied, the arrows illustrate the target with the smallest
input. {cmd:show(pps frontier)} hides the arrows. The slack weights are
supplied by the user and appear below the figure.{p_end}

{phang2}{cmd:. graphdea hours = units if year==2024, view(additive) dmu(plant) focus("North site") compare(vrs fdh)}{p_end}
{phang2}{cmd:. graphdea units, inputs(hours) model(additive) dmu(plant) focus("North site") slackweights(2 1)}{p_end}
{phang2}{cmd:. matrix list r(additive)}{p_end}

{marker malmquist}{...}
{title:Two-period Malmquist productivity change with one input and one output}

{p 8 12 2}{cmd:graphdea} {it:input} {cmd:=} {it:output} {ifin}{cmd:, view(malmquist)}
{cmd:dmu(}{it:idvar}{cmd:) focus(}{it:id}{cmd:) time(}{it:numeric_timevar}{cmd:)}
[{cmd:periods(}{it:base followup}{cmd:)} {cmd:orientation(input|output)} {cmd:decompose} {cmd:title()} {cmd:xtitle()} {cmd:ytitle()} {cmd:name()}]{p_end}

{pstd}Use long-form data with an observation for the selected DMU in each
period. Supply positive input and output quantities. The two reference samples
may differ in size and membership. Missing IDs, time values, or quantities are
excluded. Each included period must contain exactly one complete observation
of the focus. With two distinct times in the sample, the earlier is the base.
For more than two times, select a pair with {cmd:periods()} or {cmd:if}/{cmd:in},
or use {cmd:chain} to plot the changes over time.
An explicit pair sets the direction in the order written. For a Stata date
variable use its underlying numeric values in {cmd:periods()}. The legend uses
its display format. {cmd:model(malmquist)} also selects this view.{p_end}

{pstd}This view implements the constant-returns-to-scale Malmquist index with
one input and one output. Output orientation is the default. The solid line is the base
frontier, the dashed line the follow-up frontier. The arrow joins the two
observations of the focus, and plus signs indicate maximum output at its
observed input under its own period's technology. With {cmd:orientation(input)},
each plus sign marks the minimum input needed to sustain the observed output.
The dotted horizontal segment gives the potential input saving.{p_end}

{pstd}Each row of {cmd:r(distances)} is an observed focus bundle and each column
is a reference technology, both ordered base then follow-up. For output orientation, d_ij is the
observed output in period i divided by attainable output at that input on
frontier j. A cross-period value can exceed 1. With periods numbered 1 and 2,
efficiency change is d_22 / d_11. Technical change is the geometric mean of
d_11 / d_12 and d_21 / d_22. Their product is the Malmquist index. A value
above 1 means growth and a value below 1 means decline. In this 1x1 CRS
case the index also equals the change in observed output per unit of input.
See {browse "https://www.jstor.org/stable/2117971":Färe et al. (1994)}.{p_end}

{pstd}For input orientation, {cmd:r(distances)} contains Shephard input
distances, calculated as observed input divided by minimum input at the observed output.
An own-period input distance is at least 1. A cross-period distance may be
below 1. Use the reciprocal of each input distance in the change formulas
above, so that a Malmquist index above 1 always denotes growth. With one
input, one output, and CRS, both orientations give the same productivity
index, CRS efficiency change, and technical change. The VRS component of
the decomposition can differ by orientation.
See {browse "https://doi.org/10.1016/S0377-2217(97)00450-5":Simar and Wilson (1999)}.{p_end}

{pstd}Add {cmd:decompose} to split CRS efficiency change into pure technical
efficiency change and scale efficiency change. Each period has its own panel
with common axis limits. The solid VRS frontier and dashed CRS frontier give
the own-period radial targets, marked by a diamond and a square, respectively.
The filled dot marks the observed bundle. When a target coincides with the focus,
its outline surrounds the dot.{p_end}

{pstd}Pure technical efficiency (TE_VRS) is observed output divided by the
VRS target output in output orientation. In input orientation it is the
VRS target input divided by observed input. Scale efficiency is TE_CRS / TE_VRS
in either orientation. Each change factor is its
follow-up level divided by its base level. The product of pure efficiency
change and scale efficiency change gives CRS efficiency change. Multiplying
again by CRS technical change gives the Malmquist index. The four entries
in {cmd:r(distances)} always use CRS reference technologies.{p_end}

{phang2}{cmd:. graphdea hours = units, view(malmquist) dmu(plant) focus("North site") time(year) periods(2023 2024) orientation(input) decompose}{p_end}
{phang2}{cmd:. matrix list r(period_efficiency)}{p_end}
{phang2}{cmd:. graphdea hours = units, view(malmquist) time(year) periods(2023 2024) dmu(plant) focus("North site")}{p_end}
{phang2}{cmd:. matrix list r(distances)}{p_end}
{phang2}{cmd:. display r(malmquist)}{p_end}

{marker multifrontiers}{...}
{title:Two-period Malmquist frontiers with two inputs or two outputs}

{p 8 12 2}{cmd:graphdea} {it:inputvars} {cmd:=} {it:outputvars} {ifin}{cmd:, view(malmquist)}
{cmd:time(}{it:timevar}{cmd:) dmu(}{it:idvar}{cmd:) focus(}{it:id}{cmd:)}
[{cmd:periods(}{it:base followup}{cmd:)} {cmd:orientation(input|output)} {cmd:decompose}
{cmd:title()} {cmd:xtitle()} {cmd:ytitle()} {cmd:name()}]{p_end}

{pstd}Each panel takes one observation of the focus and evaluates it on both
periods' CRS frontiers. For two inputs the axes show input 1 and input 2 per
unit of output, the unit isoquant representation in
{browse "https://doi.org/10.2307/2343100":Farrell (1957)}.
For two outputs they show output 1 and output 2 per unit of input. Both panels have the same axes and equal physical length per numeric
unit. Each frontier uses all complete peers in its period. The focus must
have one complete observation in each selected period.{p_end}

{pstd}The dot marks the observed ratios. Follow the dotted ray from the origin
to the square on the base frontier and the triangle on the follow-up frontier.
With two inputs, moving inward uses fewer inputs per unit of output.
With two outputs, moving outward yields more output per unit of input.
A cross-period target may be on either side of the dot.
Under CRS, the relative positions of these targets are the same for either
orientation. {cmd:r(distances)} follows the selected Shephard distance
convention described above.{p_end}

{pstd}With {cmd:decompose}, a diamond marks the focus's own-period VRS radial
target in the same ratio coordinates. It is computed at the observed scale
in the selected orientation. The two frontier lines continue to show CRS.
The subtitle reports the pure and scale components of efficiency change.{p_end}

{phang2}{cmd:. graphdea labor machine = units, view(malmquist) time(year) periods(2023 2024) dmu(plant) focus(West) orientation(input)}{p_end}
{phang2}{cmd:. graphdea hours = visits procedures, view(malmquist) time(year) periods(2022 2025) dmu(clinic) focus(Harbor) decompose}{p_end}
{phang2}{cmd:. matrix list r(distances)}{p_end}
{phang2}{cmd:. matrix list r(ratio_targets)}{p_end}

{marker overview}{...}
{title:Comparing Malmquist productivity change across DMUs}

{p 8 12 2}{cmd:graphdea} {it:inputvars} {cmd:=} {it:outputvars} {ifin}{cmd:, view(malmquist) overview}
{cmd:dmu(}{it:idvar}{cmd:) time(}{it:numeric_timevar}{cmd:)}
[{cmd:periods(}{it:base followup}{cmd:)} {cmd:orientation(input|output)} {cmd:decompose}
{cmd:top(}{it:#}{cmd:)} {cmd:title()} {cmd:xtitle()} {cmd:ytitle()} {cmd:name()}]{p_end}

{pstd}Use {cmd:overview} to compare all DMUs observed in both periods. Each DMU
may have one complete observation per selected period after {cmd:if}/{cmd:in}.
Supply one input and one output, two inputs and one output, or one input and
two outputs. A DMU present only once still contributes to its period's frontier. With two
distinct times the default comparison runs from earlier to later. Otherwise
specify the two periods to compare, in the desired order.{p_end}

{pstd}The graph ranks matched DMUs by decreasing Malmquist index, breaking
ties by ID. A filled circle marks productivity change and an open square marks
efficiency change. With {cmd:decompose}, the square marks pure efficiency change
and a triangle marks scale efficiency change. The dotted vertical line marks 1
(no change). With one input and one output, the dashed line marks the common
CRS technical change. With a second input or output, open diamonds show
technical change at each DMU's observed mixes. Symbols are offset vertically
within each row so that coincident factors remain visible. Use {cmd:top(10)} to display the first
ten rows while keeping the full reference samples and all matched results.{p_end}

{phang2}{cmd:. graphdea hours = units, view(malmquist) overview dmu(plant) time(year) periods(2023 2024)}{p_end}
{phang2}{cmd:. graphdea labor machine = units, view(malmquist) overview dmu(plant) time(year) orientation(input)}{p_end}
{phang2}{cmd:. graphdea hours = visits procedures, view(malmquist) overview dmu(clinic) time(year) decompose}{p_end}
{phang2}{cmd:. matrix list r(overview)}{p_end}

{marker chain}{...}
{title:Chained Malmquist indices over time}

{p 8 12 2}{cmd:graphdea} {it:inputvars} {cmd:=} {it:outputvars} {ifin}{cmd:, view(malmquist) chain}
{cmd:dmu(}{it:idvar}{cmd:) focus(}{it:id}{cmd:) time(}{it:numeric_timevar}{cmd:)}
[{cmd:periods(}{it:numlist}{cmd:)} {cmd:orientation(input|output)} {cmd:benchmark(contemporaneous|global)} {cmd:decompose}
{cmd:title()} {cmd:xtitle()} {cmd:ytitle()} {cmd:name()}]{p_end}

{pstd}{cmd:chain} uses all distinct times among the included complete observations
in increasing order. To choose specific periods, supply two or more distinct numeric
values in strictly increasing or decreasing order, for example {cmd:periods(2020 2022 2025)}.
Each selected period must have one complete observation of the focus. Its peers
come from that period and may differ in number and membership over time.
Supply one input and one output, two inputs and one output, or one input and
two outputs. With the default {cmd:benchmark(contemporaneous)}, for each adjacent pair, the command evaluates the focus at both
dates against both periods' CRS frontiers. With {cmd:decompose}, the selected
orientation also determines the own-period VRS efficiency used in the split.{p_end}

{pstd}The left panel plots the change from the preceding selected period to the
time on the horizontal axis. A factor of 0.8 represents a 20% decline over that
interval, including intervals longer than one year. The right panel multiplies
successive factors from a base of 1. With contemporaneous frontiers and two inputs or two outputs the final
chained index can differ from a direct comparison of the first and last periods.
For example, {cmd:periods(2022 2025)} gives the direct change, while
{cmd:periods(2022/2025)} links the three annual changes in that span. See
{browse "https://doi.org/10.1016/j.econlet.2005.02.013":Pastor and Lovell (2005)}.
Both panels use the same time and factor
scales. The dotted horizontal line marks 1. With {cmd:decompose}, the graph
displays pure efficiency and scale efficiency separately. Their product is the
overall efficiency change. {cmd:xtitle()} labels the time axis and {cmd:ytitle()}
labels the change factor.{p_end}

{phang2}{cmd:. graphdea hours = units if year>=2020, view(malmquist) chain time(year) dmu(plant) focus("North site")}{p_end}
{phang2}{cmd:. graphdea hours = visits procedures, view(malmquist) chain time(year) dmu(clinic) focus(Harbor)}{p_end}
{phang2}{cmd:. graphdea labor machine = units, view(malmquist) chain time(year) dmu(plant) focus(North) orientation(input) decompose}{p_end}
{phang2}{cmd:. matrix list r(chain)}{p_end}
{phang2}{cmd:. matrix list r(cumulative)}{p_end}

{marker global}{...}
{title:Global Malmquist productivity change}

{pstd}Add {cmd:benchmark(global)} to a Malmquist {cmd:chain} command to use
one CRS frontier constructed from all complete observations in the selected
periods. Peers can enter or leave the panel. The focus must appear once in each
selected period. {cmd:if}, {cmd:in}, and {cmd:periods()} determine the pooled
reference sample as well as the observations plotted. Changing the sample
can change previously calculated indices.{p_end}

{pstd}Let G be the focus DMU's radial efficiency against the pooled frontier
and E its efficiency against its own period's CRS frontier, each expressed on
the Farrell efficiency scale (1 at the radial frontier). The global productivity
index is the ratio of the later G to the earlier G. It is the product of
efficiency change (the ratio of the two E values) and best practice change
(the ratio of the two G/E values). A best practice change above 1 means the
period frontier has moved closer to the global benchmark along the mixes being
evaluated. With {cmd:decompose}, pure and scale efficiency changes further
split the own-period efficiency component.
See {browse "https://doi.org/10.1016/j.econlet.2005.02.013":Pastor and Lovell (2005)}.{p_end}

{pstd}Within a run the product of successive global changes equals the
endpoint ratio. To compare the endpoints on the four-year reference, run
{cmd:periods(2022/2025)} and read the final row of {cmd:r(cumulative)}.
Specifying {cmd:periods(2022 2025)} pools just those two years.{p_end}

{phang2}{cmd:. graphdea hours = visits procedures, view(malmquist) chain benchmark(global) time(year) dmu(clinic) focus(Harbor) periods(2022/2025)}{p_end}
{phang2}{cmd:. matrix list r(global_levels)}{p_end}
{phang2}{cmd:. matrix list r(cumulative)}{p_end}

{marker super}{...}
{title:Radial super-efficiency with one input and one output}

{p 8 12 2}{cmd:graphdea} {it:input} {cmd:=} {it:output} {ifin}{cmd:, view(super) dmu(}{it:idvar}{cmd:) focus(}{it:id}{cmd:)}
[{cmd:orientation(input|output)}] [{cmd:rts(crs|vrs)} | {cmd:model(fdh)} | {cmd:compare(}{it:technologies}{cmd:)}]{p_end}

{pstd}The {browse "https://doi.org/10.1287/mnsc.39.10.1261":Andersen–Petersen}
procedure evaluates the focus against the technology formed by the other
observations. The command constructs both the full and the peer frontier after
applying {cmd:if}/{cmd:in} and excluding missing quantities. It removes exactly
the selected observation from the peer sample. Another DMU with identical
quantities remains a peer. At least one peer is required. The default is CRS
with input orientation. {cmd:model(super)} also selects this view.{p_end}

{pstd}Input orientation holds output fixed and finds the minimum peer input.
The score is target input / observed input. Output orientation holds input
fixed and finds the maximum peer output. The score is observed output / target
output (the reciprocal of the expansion factor). Thus a score above one
indicates that the focus outperforms its peers in the chosen direction. A
score of one indicates a tie at that coordinate. The radial target may lie
on a disposal edge.{p_end}

{pstd}The default {cmd:show(pps frontier radial)} shades the peer technology,
draws the full frontier as a solid line and the peer frontier as a dashed line,
and marks the peer target with a diamond. An arrow connects the focus to
a distinct target. With VRS or FDH, a focus above the largest peer output
has no input-oriented target. A focus to the left of the smallest peer input
has no output-oriented target. Such panels display {it:No radial target}.
The other comparison panels still report their results.{p_end}

{phang2}{cmd:. graphdea hours = units if year==2024, view(super) dmu(plant) focus("North site") compare(crs vrs fdh)}{p_end}
{phang2}{cmd:. matrix list r(super)}{p_end}

{marker sbm}{...}
{title:Slacks-based efficiency (SBM) with one input and one desirable output}

{p 8 12 2}{cmd:graphdea} {it:input} {cmd:=} {it:output} {ifin}{cmd:, view(sbm) dmu(}{it:idvar}{cmd:) focus(}{it:id}{cmd:)}
[{cmd:orientation(nonoriented|input|output)}]
[{cmd:rts(crs|vrs)} | {cmd:model(fdh)} | {cmd:compare(}{it:technologies}{cmd:)}]{p_end}

{pstd}For a focus at (x0,y0), let s_input = x0 - x and s_output = y - y0
at an attainable target with x <= x0 and y >= y0. The nonoriented
{browse "https://doi.org/10.1016/S0377-2217(99)00407-5":slacks-based measure of Tone (2001)}
minimizes rho = (1 - s_input/x0)/(1 + s_output/y0). With one positive input and
one positive output, this equals (x/x0)*(y0/y). By default, {cmd:orientation(nonoriented)}
scores both slacks. Its score is positive and at most 1, with 1 indicating
Pareto efficiency. Changing the measurement
units leaves the relative slacks and rho unchanged.{p_end}

{pstd}{cmd:orientation(input)} minimizes x/x0 subject to y >= y0. At the
minimum input, the command selects the greatest attainable output.
{cmd:orientation(output)} maximizes y/y0 subject to x <= x0 and reports its
reciprocal, rho = y0/y, on the same efficiency scale. At the maximum
output, the command selects the smallest attainable input. The diamond marks
this Pareto-efficient target for each technology. The solid arrow shows the
scored change and the dashed arrow shows any additional slack in the other
variable. An oriented score of 1 can coexist with a positive slack in that
other variable. With one input and one output the oriented scores coincide
with the corresponding radial efficiency scores.{p_end}

{pstd}{cmd:model(sbm)} also selects this view. VRS is the default.
For the nonoriented model, diamonds mark optimal targets. A highlighted segment joins equally optimal
CRS or VRS endpoints. Under FDH, distinct optimal observed bundles are plotted
individually. The default {cmd:show(pps frontier slacks)} shows arrows for the
optimum with the smallest input and reports its input saving and output gain
as percentages of the observed quantities. Use {cmd:show(pps frontier)} for a
figure without the arrows and percentages.{p_end}

{phang2}{cmd:. graphdea units if year==2024, inputs(hours) view(sbm) dmu(plant) focus("North site") compare(vrs crs)}{p_end}
{phang2}{cmd:. graphdea hours = units if year==2024, view(sbm) orientation(output) dmu(plant) focus("North site") compare(vrs fdh)}{p_end}
{phang2}{cmd:. matrix list r(sbm)}{p_end}

{marker production}{...}
{title:Production diagram options}

{phang}{cmd:rts(crs|vrs)} selects the convex radial technology. Default is CRS.
{cmd:model(te)} is optional. Use {cmd:model(fdh)} for the ordinary free disposal hull.{p_end}
{phang}{cmd:compare(}{it:list}{cmd:)} draws one panel per technology on common axes, in list order.
Use any distinct subset of {cmd:crs vrs fdh}. This option supplies the model specification.{p_end}
{phang}{cmd:dmu(}{it:idvar}{cmd:)} labels observed units. {cmd:focus(}{it:id}{cmd:)} selects
one unit within the {cmd:if}/{cmd:in} sample for evaluation and highlights it with a ring.
Quote string IDs containing spaces. For a numeric ID, supply the numeric value.
All observations in the reference sample contribute to the boundary.{p_end}
{phang}{cmd:show(}{it:layers}{cmd:)} selects any combination of {cmd:pps}, {cmd:frontier},
{cmd:radial}, {cmd:radialin}, {cmd:radialout}, {cmd:ddf}, {cmd:peers}, {cmd:lambda}, {cmd:slacks}, and {cmd:weights}. The default is {cmd:pps frontier},
plus {cmd:radial} when a focus is supplied. {cmd:orientation(input|output)} sets the
direction used by {cmd:radial}; the default is input. Explicit {cmd:radialin} and
{cmd:radialout} allow both directions in one graph. Radial layers require a focus.
Arrows with zero length are omitted.{p_end}
{phang}{cmd:peers} marks reference DMUs with triangles. {cmd:lambda} also labels
their intensity weights. A diamond marks the radial target. {cmd:slacks} draws a
dashed arrow from this point to the Pareto-efficient final target when further
input reduction or output increase is possible. Each of these layers requires
{cmd:dmu()} and {cmd:focus()}. They follow {cmd:orientation()}. If orientation
is omitted, they use input orientation unless the only radial layer is
{cmd:radialout}.{p_end}

{pstd}The weighted sum of the observed peer coordinates gives the final target.
CRS scales one unit with the highest computed output/input ratio. VRS uses one
extreme unit or two adjacent extreme units whose weights sum to one. FDH uses
one undominated unit with weight one. The graph shows one representation when
alternatives exist. Tied CRS slopes and duplicate vertices use the first eligible
observation in sample order.{p_end}

{phang}{cmd:weights} draws one optimal multiplier supporting line through the radial
target (diamond) of the selected DMU in a one-input, one-output CRS or VRS
production graph. Its equation is {it:u y - v x + w = 0}. Every reference
observation satisfies {it:u y - v x + w <= 0}. The header gives the input
multiplier {it:v}, output multiplier {it:u}, and signed constant {it:w} in
this equation. CRS sets {it:w = 0}. With positive {it:u}, the slope is {it:v/u}.
Use {cmd:lambda} to label the intensities of the reference DMUs.{p_end}

{pstd}For a focus at (x0,y0), input orientation fixes v*x0 = 1 and maximizes
u*y0 + w = theta. Output orientation fixes u*y0 = 1 and minimizes
v*x0 - w = phi. The displayed output efficiency is 1/phi. The orientation
follows the same rule as the reference layers. The calculation permits zero
multipliers on free-disposal edges. At a VRS vertex with multiple supporting
lines the input graph uses the edge arriving from below, and the output graph
uses the edge leaving to the right. These choices include the outer vertical
and horizontal edges.{p_end}

{phang2}{cmd:. graphdea x = y, dmu(id) focus("D") compare(crs vrs) orientation(input) show(pps frontier radial weights)}{p_end}
{phang2}{cmd:. matrix list r(multipliers)}{p_end}

{phang}{cmd:view(production)} and {cmd:layout(panel)} select the one-input production view and panel layout.
{cmd:name(}{it:graphname}[{cmd:, replace}]{cmd:)} names the Stata graph.
Use {help graph export} to export it.{p_end}
{phang}{cmd:title()}, {cmd:xtitle()}, and {cmd:ytitle()} accept standard Stata
graph title text and suboptions. The figure title appears once above the panels.
Use {cmd:title("")} when the manuscript supplies the caption.
To include units, specify, for example, {cmd:xtitle("Labor (hours)")}.{p_end}

{marker appearance}{...}
{title:Customizing graph appearance}

{pstd}{bf:Style a title in the command.} With input {cmd:hours} and output
{cmd:units} in memory, this example gives the figure a navy Georgia title
and smaller axis titles. Substitute a font installed on your computer.
Use {cmd:color(gs4)} for a dark-gray title suitable for monochrome printing.{p_end}

    {cmd:graphdea hours = units, rts(vrs) ///}
        {cmd:title("{c -(}fontface Georgia:Frontier{c )-}", color(navy) size(medlarge)) ///}
        {cmd:xtitle("Labor (hours)", size(small)) ///}
        {cmd:ytitle("Output (units)", size(small)) ///}
        {cmd:name(frontier, replace)}

{pstd}The same font tag works inside axis titles. For a portable serif face,
use {cmd:"{c -(}stSerif:Frontier{c )-}"}. To italicize just a variable symbol,
use {cmd:xtitle("Input ({c -(}it:x{c )-})")}. See {help graph_text:Text in graphs}
and {help colorstyle:Color choices}.{p_end}

{pstd}{bf:Change line and marker colors.} {cmd:graphdea} draws its layers
with explicit styles and the {cmd:s1mono} scheme. Open the Graph Editor
from the Graph window toolbar. Double-click the frontier line and choose
its color, width, or pattern. Double-click a marker to change its plot's
marker color or symbol. For overlapping layers, select the intended plot in
the Object Browser and open its properties. Solid and dashed frontiers can
also distinguish models in grayscale. See {help graph_editor:Graph Editor}.{p_end}

{pstd}{bf:Reuse the edits.} Click {bf:Start Recording} in the Graph Editor
before changing the styles. Stop recording and save the recording as
{cmd:dea_style}. After drawing another graph with the same view, layers, and
panel layout, apply the recording to the current graph. Save an editable
Stata copy and export the figure for a manuscript with the following commands.{p_end}

    {cmd:graph play dea_style}
    {cmd:graph save "frontier_styled.gph", replace}
    {cmd:graph export "frontier_styled.pdf", replace}

{pstd}For a one-off edit, use the two file commands immediately after leaving
the editor. See {help graph_editor##recorder:Graph Recorder} and
{help graph_play:graph play} for details.{p_end}

{pstd}{bf:Set a preferred font for the Graph window.} For a persistent
preference across graphs, {cmd:graph set window fontface "Arial"} sets the
main font and {cmd:graph set window fontfaceserif "Georgia"} sets the face used
by {cmd:{c -(}stSerif{c )-}} in default figure titles. To restore Stata's defaults,
use {cmd:graph set window fontface default} and
{cmd:graph set window fontfaceserif default}. See {help graph_set:graph set}
for Graph window and export-format settings.{p_end}

{marker isoquant}{...}
{title:Two-input isoquant and Farrell decomposition}

{pstd}Both axes measure inputs in the original units. The black boundary shows
the inputs needed to produce at least the stated output level; additional inputs
are feasible above and to the right. All complete observations selected by
{cmd:if}/{cmd:in} define the technology. The plot labels the evaluation points.
Axis titles come from the two input labels or {cmd:xtitle()} and {cmd:ytitle()}.

{phang}{cmd:rts(crs|vrs)} chooses one convex technology; the default is CRS.
Under CRS the observed input bundles are scaled to the target output before
constructing the lower envelope. Under VRS the slice includes observations
that meet the output requirement and mixtures of observations straddling it.
A target above the largest sample output is infeasible under VRS.{p_end}

{phang}{cmd:model(fdh)} draws the free disposal hull at the specified output.
Each observation producing at least that output contributes the input bundles
above and to its right. Their union gives the staircase. The radial input
factor is the smallest, over eligible observations, of the larger of the two
input ratios to the selected DMU. With {cmd:w()}, the cost minimum is attained
at an eligible observed input bundle. Specify {cmd:model(fdh)} on its own
as the technology option.{p_end}

{phang2}{cmd:. graphdea labor capital = output, model(fdh) dmu(firm) focus("D") w(wage rent)}{p_end}

{phang}{cmd:at(}{it:outputvar}{cmd:=}{it:#}{cmd:)} draws a specified positive
output slice. {cmd:dmu()} and {cmd:focus()} identify the unit D for efficiency
evaluation. When a focus is specified, the slice must match its output.{p_end}

{phang}{cmd:model(te)} gives input-oriented radial technical efficiency.
{cmd:model(allocative) w(}{it:price1 price2}{cmd:)} adds cost minimization using
the selected DMU's two positive prices in input order. Specifying {cmd:w()}
alone also selects the cost decomposition. The point R equals TE times the
observed bundle D. At the cost-minimizing bundle C, CE = cost(C)/cost(D)
and AE = cost(C)/cost(R). If several vertices tie for lowest computed cost,
the one with smallest first input is displayed.{p_end}

{phang}{cmd:show()} selects overlays on the input boundary, which is always drawn.
{cmd:pps} shades the feasible inputs, {cmd:radial} shows the focus ray and R,
{cmd:costmin} marks C, and {cmd:isocost} draws the minimum-cost line at the focus
prices. The default draws all layers supported by the supplied inputs. Coincident
point labels are combined. Input prices and costs are measured in original units.{p_end}

{marker outputset}{...}
{title:Two-output possibility set and revenue efficiency}

{pstd}At the stated input budget, the shaded region contains the nonnegative
output combinations that can be produced. The horizontal and vertical axes show
the first and second outputs, respectively. The black boundary includes the
horizontal and vertical segments implied by free disposal.

{phang}{cmd:at(focus)} fixes input at the selected DMU's observed level.
Alternatively, {cmd:at(}{it:inputvar}{cmd:=}{it:#}{cmd:)} draws a specified
positive input budget. With a focus this must equal its input. The reference
sample includes all complete observations selected by {cmd:if}/{cmd:in}.
Under CRS the outputs are scaled to the budget; under VRS units using at most
that budget and convex mixtures spanning the budget determine the boundary.
A budget below the smallest observed input is infeasible under VRS.{p_end}

{phang}{cmd:model(fdh)} selects observations using at most the input budget.
Each contributes all output bundles below and to its left. The radial expansion
factor is the largest, over eligible observations, of the smaller of the two
output ratios to the selected DMU. With {cmd:p()}, the maximum revenue is
attained at an eligible observed output bundle. A unit on a step can have
TE = 1 and still increase one output while holding the other fixed.{p_end}

{phang2}{cmd:. graphdea hours = good1 good2, model(fdh) dmu(firm) focus("D") p(price1 price2)}{p_end}
{phang2}{cmd:. do example_fdh.do}{p_end}

{phang}{cmd:show(slacks)} shows the radial target R, then draws an arrow for
each feasible additional output gain at the same input budget. It requires
{cmd:dmu()} and {cmd:focus()}. Each arrow holds the other output at R and
ends at the largest feasible value of the improving output. Two arrows on
an FDH step represent alternative production plans. When R is already
Pareto efficient in the output section, the graph reports zero residual
output slack. Prices are optional. Use with {cmd:compare()} to compare
technologies or with {cmd:view(surface)} to show the arrows on its planar
section. Include {cmd:pps} in {cmd:show()} for feasible-set shading.{p_end}

{phang2}{cmd:. graphdea hours = good1 good2, dmu(firm) focus("D") compare(vrs fdh) show(pps slacks)}{p_end}
{phang2}{cmd:. matrix list r(slacks)}{p_end}

{phang}{cmd:orientation(output)} is the default for this view. With a focus,
{cmd:model(te)} gives the maximum proportional expansion phi. The target
R = phi times D lies on the boundary. Reported technical efficiency TE = 1/phi.{p_end}

{phang}{cmd:model(allocative) p(}{it:price1 price2}{cmd:)} adds revenue maximization
using the focus DMU's positive prices in output order. Supplying {cmd:p()} alone
also selects this decomposition. At the revenue maximum M,
RE = revenue(D)/revenue(M), AE = revenue(R)/revenue(M), and RE = TE times AE.
If several vertices tie for maximum computed revenue, M is the tied vertex
with smallest first output.{p_end}

{phang}{cmd:show()} selects overlays on the output boundary. {cmd:pps} shades
feasible outputs, {cmd:radial} or {cmd:radialout} shows the ray and target R,
{cmd:isorevenue} draws the maximum-revenue line, and {cmd:revenuemax} marks M.
By default the figure includes all layers supported by the supplied data.{p_end}

{title:Reading the one-input diagram}

{pstd}The horizontal axis is input and the vertical axis is output. Variable labels
supply the axis titles when available. The graph uses Stata's {cmd:s1mono} scheme.
The left and bottom axes meet at the origin in each panel. Comparison panels
use the same ticks and are lettered in the order given to {cmd:compare()}.
Grey shading shows the feasible production set inside the plotting window.
The black line includes weakly efficient free-disposal segments. A radial target
on such a segment can have additional slack. The left arrow holds output fixed; the
dashed upward arrow holds input fixed. When a focus is supplied, panel headers
show input efficiency theta and output efficiency 1/phi, rounded to three decimals.

{pstd}CRS scales the observation with maximum output/input ratio. VRS forms the
upper concave envelope of observations and allows free disposal. FDH takes the
union of the regions dominated by individual observations. Equal inputs, duplicate
points, and dominated observations are permitted. The one-input, one-output
production view requires strictly positive, finite quantities. Observations
missing either quantity are excluded.
Geometry is computed directly in Mata. No external DEA command is required.

{marker examples}{...}
{title:Examples}

{phang2}{cmd:. graphdea x = y, dmu(id) focus("D") compare(crs vrs fdh) show(pps frontier radialin radialout)}{p_end}
{phang2}{cmd:. matrix list r(projections)}{p_end}
{phang2}{cmd:. graphdea x = y, dmu(id) focus("D") compare(crs vrs fdh) orientation(input) show(pps frontier radial lambda slacks)}{p_end}
{phang2}{cmd:. matrix list r(peers)}{p_end}
{phang2}{cmd:. matrix list r(benchmarks)}{p_end}
{phang2}{cmd:. graphdea y if x < 8, inputs(x) rts(vrs)}{p_end}
{phang2}{cmd:. graph export "frontier.pdf", replace}{p_end}

{phang2}{cmd:. graphdea labor capital = output, dmu(firm) focus("D") model(allocative) w(wage rent) rts(vrs) at(focus)}{p_end}
{phang2}{cmd:. matrix list r(targets)}{p_end}
{phang2}{cmd:. graphdea output, inputs(labor capital) rts(vrs) at(output=10)}{p_end}

{phang2}{cmd:. graphdea hours = good1 good2, dmu(firm) focus("D") rts(vrs) model(allocative) p(price1 price2)}{p_end}
{phang2}{cmd:. matrix list r(targets)}{p_end}
{phang2}{cmd:. graphdea good1 good2, inputs(hours) rts(vrs) at(hours=10)}{p_end}

{phang2}{cmd:. graphdea labor capital = output, view(surface) rts(vrs) dmu(firm) focus("D")}{p_end}
{phang2}{cmd:. graphdea good1 good2, inputs(hours) view(surface) rts(vrs) at(hours=6)}{p_end}

{marker results}{...}
{title:Stored results}

{pstd}Type {cmd:return list} immediately after {cmd:graphdea} to see the results
for the selected view. Save any needed scalars or matrices before running
another command that replaces {cmd:r()}.{p_end}

{phang}{cmd:r(N)} is the number of observations in the reference sample.{p_end}
{phang}{cmd:r(technologies)} contains the technology names in panel order.{p_end}
{phang}For a two-period frontier diagram with {cmd:view(malmquist)}, {cmd:r(malmquist)}, {cmd:r(efficiency_change)},
and {cmd:r(technical_change)} are change factors from base to follow-up.
{cmd:r(technologies)} contains {cmd:crs}, or {cmd:crs vrs} with {cmd:decompose}.
{cmd:r(orientation)} gives the chosen direction. {cmd:r(distances)} contains
the four Shephard distances in that direction. {cmd:r(base)} and
{cmd:r(followup)} are the numeric times, and {cmd:r(N_base)},
{cmd:r(N_followup)}, and {cmd:r(N)} report both sample sizes and their sum.{p_end}
{phang}In the two-period diagram with {cmd:decompose}, {cmd:r(pure_efficiency_change)}
and {cmd:r(scale_efficiency_change)} are the two factors of CRS efficiency
change. Rows of {cmd:r(period_efficiency)} are {cmd:base} and {cmd:followup}.
With one input and one output, columns {cmd:y_observed}, {cmd:y_vrs}, and {cmd:y_crs} give the focus output
and its own-period targets at its input for output orientation. Input orientation
gives {cmd:x_observed}, {cmd:x_vrs}, and {cmd:x_crs} at the observed output.
Columns {cmd:te_vrs}, {cmd:te_crs},
and {cmd:scale_eff} give the corresponding efficiency levels.{p_end}
{phang}For the two-input or two-output focus diagram, {cmd:r(ratio_targets)}
has a row per observed period and paired columns for the plotted coordinates.
{cmd:observed_1 observed_2} give the observation, {cmd:base_1 base_2} the
target on the base CRS frontier, and {cmd:followup_1 followup_2} the target
on the follow-up CRS frontier. {cmd:decompose} adds {cmd:vrs_1 vrs_2} for
the own-period VRS target. The coordinate order matches the two variables
on the same side of the equals sign. Here {cmd:r(period_efficiency)} with
{cmd:decompose} contains {cmd:te_vrs}, {cmd:te_crs}, and {cmd:scale_eff}.{p_end}
{phang}With {cmd:overview}, each row of {cmd:r(overview)} gives a matched DMU in
rank order. The first two columns, {cmd:base_obs} and {cmd:followup_obs}, identify
its observations in the data as ordered when the command was called. Use these
keys to recover exact IDs if the matrix row labels are abbreviated.
The remaining columns are {cmd:malmquist}, {cmd:efficiency_change},
and {cmd:technical_change}, followed by {cmd:pure_efficiency_change} and
{cmd:scale_efficiency_change} with {cmd:decompose}. Scalars {cmd:r(N_base)}
and {cmd:r(N_followup)} count the reference observations, {cmd:r(N_matched)}
counts paired DMUs, and {cmd:r(N_shown)} counts displayed rows.
For one input and one output, {cmd:r(technical_change)} also stores the
common frontier shift. With two inputs or two outputs, read the
{cmd:technical_change} column for the shift evaluated at each DMU.{p_end}

{phang}With {cmd:chain}, {cmd:r(chain)} and {cmd:r(cumulative)} contain one
row per selected time, in the requested order. Columns are {cmd:period},
{cmd:n_ref} (period sample size), {cmd:malmquist}, {cmd:efficiency_change},
and {cmd:technical_change}. {cmd:decompose} adds {cmd:pure_efficiency_change}
and {cmd:scale_efficiency_change}. The base row has missing interval factors
and cumulative factors equal to 1. The named change scalars return the last
cumulative factors. {cmd:r(N_periods)} counts periods and {cmd:r(N)} counts
included observations across the full series. {cmd:r(base)} and {cmd:r(followup)}
identify the first and last selected periods, and {cmd:r(N_base)} and
{cmd:r(N_followup)} give their sample sizes. {cmd:r(benchmark)} gives
{cmd:contemporaneous} or {cmd:global}.{p_end}
{phang}With {cmd:benchmark(global)}, the fifth column in {cmd:r(chain)} and
{cmd:r(cumulative)} is {cmd:best_practice_change}, with the final factor also
in {cmd:r(best_practice_change)}. {cmd:r(global_levels)} records {cmd:period},
{cmd:n_ref}, {cmd:te_global}, {cmd:te_period}, and {cmd:best_practice_ratio}.
With {cmd:decompose} it also records {cmd:te_vrs} and {cmd:scale_eff}.
{cmd:r(N)} gives the pooled reference count and {cmd:n_ref} the period count.{p_end}
{phang}In {cmd:view(super)}, {cmd:r(N)} counts the full sample and
{cmd:r(N_ref)} counts the remaining peers. {cmd:r(orientation)} gives the
chosen direction. Each row of {cmd:r(super)} reports {cmd:full_score},
the excluded-sample radial {cmd:factor}, the excluded-sample efficiency
{cmd:score}, {cmd:x_target}, {cmd:y_target}, and {cmd:feasible} (1 or 0).
For an infeasible direction the factor, score, and target coordinates are
missing. A single technology also returns scalar {cmd:r(super_score)}.
{cmd:r(projections)} gives ordinary full-sample projections.{p_end}
{phang}In {cmd:view(sbm)}, the row equations of {cmd:r(sbm)} identify the
technologies in panel order. {cmd:r(orientation)} records {cmd:nonoriented},
{cmd:input}, or {cmd:output}. The nonoriented model returns the unique optimum,
both endpoints of a convex optimal segment, or the distinct optimal FDH
bundles. Each oriented model returns one row per technology after exhausting
the remaining slack. Columns are
{cmd:x_target}, {cmd:y_target}, {cmd:s_input}, {cmd:s_output}, {cmd:rel_input},
{cmd:rel_output}, and {cmd:rho}. Relative slacks are fractions of the focus
input and output. Each single-technology call also returns scalar {cmd:r(rho)}.{p_end}
{phang}In {cmd:view(additive)}, the row equations of {cmd:r(additive)}
identify the technologies. Rows give the unique optimal target, the endpoints
of a convex optimal segment, or each tied FDH bundle, in increasing input
order. The columns {cmd:x_target}, {cmd:y_target}, {cmd:s_input},
{cmd:s_output}, and {cmd:objective} give the target coordinates, both slacks
in original units, and their weighted sum. {cmd:r(w_input)} and
{cmd:r(w_output)} contain the objective weights.{p_end}
{phang}In {cmd:view(weakdisposal)}, {cmd:r(input)} is the budget and
{cmd:r(bad)} and {cmd:r(good)} are the output variable names. Each row of
{cmd:r(frontier)} gives a vertex of the upper boundary in columns {cmd:bad}
and {cmd:good_max}, in ascending order of emissions. With {cmd:plan()},
{cmd:r(plan)} returns {cmd:bad_plan}, {cmd:good_plan}, {cmd:good_max},
{cmd:feasible} (1 or 0), and {cmd:good_joint}. If the specified emissions
exceed the attainable range, {cmd:good_max} is missing and {cmd:feasible}
is zero. {cmd:good_joint} is the proportional output on the focus contraction
segment. It is missing when there is no focus, its emissions are zero, or the
requested emissions exceed the focus emissions.{p_end}
{phang}In {cmd:view(disposability)}, {cmd:r(disposal)} has a row per technology.
{cmd:x_focus} and {cmd:y_focus} are the selected DMU's observed quantities.
{cmd:x_plan} and {cmd:y_plan} give the proposed quantities. {cmd:from_focus}
indicates membership in the selected DMU's rectangle. {cmd:y_max} is the
technology's maximum output at the proposed input. {cmd:feasible} indicates
membership in the technology. Both indicators use 1 for yes and 0 for no.
Below the minimum observed input, VRS and FDH return missing {cmd:y_max} and
{cmd:feasible}=0. When {cmd:plan()} is omitted, the five plan columns are missing.{p_end}
{phang}In {cmd:view(convexity)}, {cmd:r(first)} and {cmd:r(second)} identify the
DMUs in pair order. Each row of {cmd:r(mixture)} corresponds to one technology.
{cmd:share1} and {cmd:share2} are the mixing weights. {cmd:x_mix} and {cmd:y_mix}
are the mixed quantities in original units. {cmd:y_max} is the maximum feasible
output at {cmd:x_mix}. {cmd:feasible} is 1 when the mixed plan is feasible and
0 otherwise.{p_end}
{phang}{cmd:r(projections)} is returned in the one-input production view when {cmd:focus()} is supplied. Rows are
technologies. Columns are the input target {cmd:x_input} at fixed observed output,
input efficiency {cmd:theta}, the output target {cmd:y_output} at fixed observed
input, expansion factor {cmd:phi}, and output efficiency {cmd:eff_output} = 1/phi.
Both directions are returned regardless of the displayed arrow layers.{p_end}

{phang}With {cmd:view(ddf)} or {cmd:show(ddf)}, {cmd:r(ddf)} contains one
row per technology in panel order. Columns are {cmd:beta}, {cmd:gx},
{cmd:gy}, {cmd:x_target}, and {cmd:y_target}. Directions and target
coordinates are in the original data units.{p_end}

{phang}With {cmd:show(weights)}, {cmd:r(orientation)} records the multiplier
normalization. Rows of {cmd:r(multipliers)} correspond to technologies in
panel order. Columns are {cmd:v}, {cmd:u}, {cmd:w} and {cmd:objective}.
The objective is theta for input orientation and phi for output orientation.{p_end}

{phang}With {cmd:peers}, {cmd:lambda} or {cmd:slacks}, {cmd:r(ref_orientation)} records the
orientation. {cmd:r(peers)} contains one row per positive intensity, grouped by
technology. Its columns are the original observation number {cmd:obs},
{cmd:lambda}, and observed {cmd:x} and {cmd:y}. {cmd:r(benchmarks)} has one row
per technology with {cmd:x_radial}, {cmd:y_radial}, {cmd:x_final}, {cmd:y_final},
{cmd:s_input} (additional input reduction) and {cmd:s_output} (additional output
increase). All coordinates and slacks use original units.{p_end}

{phang}In {cmd:view(scale)}, {cmd:r(se)} is scale efficiency, {cmd:r(te_crs)} and
{cmd:r(te_vrs)} are the two technical efficiencies, and {cmd:r(orientation)}
records the chosen direction. {cmd:r(te_nirs)} is NIRS technical efficiency in
the same direction. {cmd:r(rts)} is {cmd:irs}, {cmd:crs}, or {cmd:drs} at
the VRS radial target. {cmd:r(projections)} contains the radial targets
and scores for both technologies in the production-view format.{p_end}

{phang}For a planar {cmd:compare()}, {cmd:r(axes)} has one row per displayed
variable and columns {cmd:maximum} and {cmd:step}; both axes start at zero.
With a focus, {cmd:r(efficiency)} has one row per technology, with {cmd:te},
also {cmd:phi} for output orientation, and {cmd:ae} and {cmd:ce} or {cmd:re}
when prices are supplied. {cmd:r(targets)} stacks the single-technology
target matrices, with technology names as equation names on the rows.
{cmd:r(N)}, {cmd:r(technologies)} and the slice level are common to the panels.
For a single-model call without {cmd:compare()}, results are as follows.{p_end}

{phang}For the two-input view, {cmd:r(output)} is the slice output.
With a focus, {cmd:r(te)} is the input efficiency and {cmd:r(targets)} gives
the observed and radial input bundles. With prices, a third row gives the
cost-minimizing bundle, the cost column is populated for all three rows,
and {cmd:r(ae)} and {cmd:r(ce)} give allocative and cost efficiency.{p_end}

{phang}In a two-output section with {cmd:show(slacks)}, {cmd:r(outputs)}
lists the output variables in axis order. {cmd:r(slacks)} gives original-unit
coordinates {cmd:radial1 radial2 target1 target2 slack1 slack2}. The two
slacks are the target coordinates minus R. {cmd:more1} and {cmd:more2} each
give one attainable target; use each row on its own. A {cmd:radial} row
reports R with both slacks zero. Row equation names identify the technology
in both single-technology graphs and comparisons. Numerical gains within
32 machine epsilons times the corresponding radial coordinate are treated
as zero.{p_end}

{phang}For the two-output view, {cmd:r(input)} is the input budget. With a focus,
{cmd:r(phi)} is the expansion factor and {cmd:r(te)} its reciprocal.
{cmd:r(targets)} lists the observed and radial bundles in original output units.
With prices the revenue column is populated, the {cmd:revenuemax} row gives M,
and {cmd:r(ae)} and {cmd:r(re)} give allocative and revenue efficiency.{p_end}

{title:Graphics reference}

{pstd}The projected polygon rendering for {cmd:sectionfill} draws on
Choonjoo Lee's {it:From automatic layout to 3D geometry} example
({cmd:stata_word3d_layout/run_layout_word3d.do} in {cmd:Archive 4.zip}).
That example credits Chen Samulsion's surface illustration. Here the polygon
vertices come from the DEA cross-section; the Stata renderer uses {cmd:twoway area}.{p_end}
