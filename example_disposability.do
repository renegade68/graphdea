* From this directory: do example_disposability.do
* Try a plan in B's free-disposal region: do example_disposability.do 7 5
version 16.0
args plan_input plan_output
if "`plan_input'`plan_output'" == "" {
    local plan_input 7
    local plan_output 6.5
}
preserve
clear
input str1 plant double(hours output)
"A" 2 2
"B" 4 6
"C" 8 8
"D" 6 4
end
label variable hours "Labor input (hours)"
label variable output "Output (units)"
graphdea hours = output, view(disposability) dmu(plant) focus("B") ///
    plan(`plan_input' `plan_output') name(dea_disposability, replace)
matrix list r(disposal)
restore
