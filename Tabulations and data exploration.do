/*==============================================================================
                      Tabulations and data exploration                         
==============================================================================*/
/*

Project:               (Im)mobility in Mexico
Database:              Mexico Life Survey - Wave 1, 2 and 3
Level:                 Individual and household databases
Book:                  Several
Subsection(s):         TB - Employment and LS - Household roster
Dofile author:         Gabriela Judith López Gutiérrez
Creation date:         May 2026 /26
Modification date:     June 2026 /01
Product 1:             Contrast two unidimensional capability measurements
                       - Figure 2: Four quadrants graphic
Product 2:             Generate transition graphics between categories
                       - Figure 3: Transitions between categories	   
Code inspo:            https://github.com/asjadnaqvi/stata-sankey/blob/main/README.md
*/

/*==============================================================================
                     Wave 1 or period t-1 (comparing first two proxies)
==============================================================================*/

/*==============================================================================
 0.General setup / Work environment (Wave 1)                                  
==============================================================================*/

clear all
global mergeddata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.4 Merged data"

*---------0.2: Install necessary packages
ssc install spineplot, replace
ssc install schemepack, replace
ssc install sankey, replace
net install sankey, from("https://raw.githubusercontent.com/asjadnaqvi/stata-sankey/main/installation/") replace
ssc install palettes, replace
ssc install colrspace, replace
ssc install graphfunctions, replace

/*==============================================================================
 1.Import (Wave 1)                                                            
==============================================================================*/

use "${mergeddata}/empl_and_demo_w1_mg.dta"
numlabel, add

/*==============================================================================
 2.Perform cross tabulations (Wave 1)    
==============================================================================*/

tab recent_anyjob
tab tb32p formal_worker, row nofreq
tab tb32p worker_withinc if recent_anyjob==1, row nofreq
tab college recent_anyjob, row chi2

/*==============================================================================
 3. Create comparison graphs and tables (Wave 1) 
==============================================================================*/
clear all
global mergeddata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.4 Merged data"
use "${mergeddata}/empldemo_asp_w1_mg.dta"
numlabel, add

*------------3.1: Defining aspirations-capability labels
label define asp_lbl 3"No aspiration to migrate" 1 "Aspiration to migrate"
label values asp_wave1 asp_lbl
label define emp_lbl 0 "Low capability (employment proxy)" 1"High capability (employment proxy)"
label values recent_anyjob emp_lbl
label define edu_lbl 0 "Low capability (education proxy)" 1"High capability (education proxy)"
label values highschool_edu edu_lbl
label values college edu_lbl
label values educated edu_lbl

*------------3.3: Generate secondary education
gen secondary_edu=1 if ls14>=4 & ls14!=98 & ls14!=.
replace secondary_edu=0 if ls14<4
label define secondary 1"Has secondary education" ///
0"Doesn't have secondary education"
label values secondary_edu secondary
label values secondary_edu edu_lbl

*------------3.2: Cross-tabulations of aspirations-capabilities
tab asp_wave1 recent_anyjob , cell
tab asp_wave1 highschool_edu, cell
tab asp_wave1 college, cell
tab asp_wave1 secondary_edu, cell

**Note: for graphs 3.3, from 3.2

cd "C:\Users\hp\Desktop\Thesis\Stata procedure\03. Output\03.2 Figures"

*------------3.3: Combined graphic
* Figure 2: Operationalized (im)mobility categories using various proxies
twoway function y=0, range(0 100) ///
lcolor(none) ///
, ///
xscale(range(0 100)) ///
yscale(range(0 100)) ///
xline(50, lpattern(dash) lcolor(black)) ///
yline(50, lpattern(dash) lcolor(black)) ///
xtitle("Mobility capability (employment versus education proxies)") ///
ytitle("Migration aspirations") ///
xlabel(25 "Low capability" 75 "High capability", noticks) ///
ylabel(25 "Low aspiration" 75 "High aspiration", angle(vertical) noticks) ///
text(82 25 "{bf:Involuntary immobility}", size(medium)) ///
text(72 25 "Employment: 7.08%" "Secondary: 4.61%" "College: 14.24%", size(medium)) ///
text(82 75 "{bf:Mobility}", size(medium)) ///
text(72 75 "Employment: 10.02%" "Secondary: 12.51%" "College: 2.86%", size(medium)) ///
text(32 25 "{bf:Acquiescent immobility}", size(medium)) ///
text(22 25 "Employment: 38.56%" "Secondary: 45.68%" "College: 77.21%", size(medium)) ///
text(32 75 "{bf:Voluntary immobility}", size(medium)) ///
text(22 75 "Employment: 44.34%" "Secondary: 37.20%" "College: 5.69%", size(medium)) ///
legend(off)

graph export fig2_combined_proxies.svg, replace


/*==============================================================================
 4. Create transition matrix and sankey graph (wave 1)
==============================================================================*/

clear all
global mergeddata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.4 Merged data"
use "${mergeddata}/empldemo_asp_w1_mg.dta"

*------------4.1: Create (im)mobility labels
label define immob_cat 4"Mobility" 3"Voluntary immobility" ///
2"Involuntary immobility" 1"Acquiescent immobility"

*------------4.2: Create job immobility variable
gen immob_job=.
replace immob_job=4 if recent_anyjob==1 & asp_wave1==1
replace immob_job=3 if recent_anyjob==1 & asp_wave1==3
replace immob_job=2 if recent_anyjob==0 & asp_wave1==1
replace immob_job=1 if recent_anyjob==0 & asp_wave1==3
label values immob_job immob_cat

*------------4.3: Create education (hs) immobility variable
gen immob_edu1=.
replace immob_edu1=4 if highschool_edu==1 & asp_wave1==1
replace immob_edu1=3 if highschool_edu==1 & asp_wave1==3
replace immob_edu1=2 if highschool_edu==0 & asp_wave1==1
replace immob_edu1=1 if highschool_edu==0 & asp_wave1==3
label values immob_edu1 immob_cat

*------------4.4: Create education (college) immobility variable
gen immob_edu2=.
replace immob_edu2=4 if college==1 & asp_wave1==1
replace immob_edu2=3 if college==1 & asp_wave1==3
replace immob_edu2=2 if college==0 & asp_wave1==1
replace immob_edu2=1 if college==0 & asp_wave1==3
label values immob_edu2 immob_cat

*------------4.5: Create education (secondary) immobility variable
gen immob_edu3=.
replace immob_edu3=4 if secondary_edu==1 & asp_wave1==1
replace immob_edu3=3 if secondary_edu==1 & asp_wave1==3
replace immob_edu3=2 if secondary_edu==0 & asp_wave1==1
replace immob_edu3=1 if secondary_edu==0 & asp_wave1==3
label values immob_edu3 immob_cat

*-----------4.5:  Create custom labels before collapsing
label define immob_job_2 1"Acquiescent (38.56%)" 2"Involuntary immobility (7.08%)" /// 
3"Voluntary immobility (44.34%)" 4 "Mobility (10.02%)"
label values immob_job immob_job_2

save "empldemo_asp_w1_mg.dta", replace

*-----------4.6:  Create collapsed transition matrix
cd "C:\Users\hp\Desktop\Thesis\Stata procedure\03. Output\03.2 Figures"
preserve
keep immob_job immob_edu3
gen value=1
collapse (sum) value, by(immob_job immob_edu3)
drop if immob_job==. | immob_edu3==. 
bysort immob_job: egen rowtotal = total(value)
gen pct_transition = 100 * value / rowtotal
format pct_transition %4.1f

*-----------4.7:  Create sankey graph
sankey value, from(immob_job) to(immob_edu3) format(%15.0fc) ///
    smooth(8) palette(HCL intense) sort1(value) sort2(value) labs(3) ///
    laba(0) labpos(3 3) labg(0.5) gap(2) ///
    noval showtot lw(none) title("", size(0)) ///
    note("", size(0)) plotregion(margin(l+5 r+5 b+0)) ///
	ctitle("{bf:Employment}" "{bf:Education (secondary)}") ctwrap(8) ///
    ctgap(5) xsize(2) ysize(1) offset(30)
graph export fig3_transitionsankey1.svg, replace

*-----------4.8:  Save transition data
global mergeddata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.4 Merged data"
save "${mergeddata}/first_transition_matrix.dta"

/*==============================================================================
 5. Create second transition matrix and sankey graph (wave 1)
==============================================================================*/

clear all
global mergeddata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.4 Merged data"
use "${mergeddata}/empldemo_asp_w1_mg.dta"

/*
gen value=1
gen immob_edu3=.
replace immob_edu3=4 if secondary_edu==1 & asp_wave1==1
replace immob_edu3=3 if secondary_edu==1 & asp_wave1==3
replace immob_edu3=2 if secondary_edu==0 & asp_wave1==1
replace immob_edu3=1 if secondary_edu==0 & asp_wave1==3
label values immob_edu3 immob_cat
*/

*-----------4.1:  Create layers
tempfile layer1 layer2

*-----------4.2:  Create first transition: immob_job to immob_edu3
preserve
keep immob_job immob_edu3 value
rename immob_job source
rename immob_edu3 destination
gen layer = 1
save `layer1'
restore

*-----------4.1:  Create second transition: immob_edu3 to immob_edu2
preserve
keep immob_edu3 immob_edu2 value
rename immob_edu3 source
rename immob_edu2 immob_edu2 destination
gen layer = 2
save `layer2'
restore

* Combine layers
use `layer1', clear
append using `layer2'

* Sankey graph
sankey value, from(source) to(destination) by(layer) palette(HCL intense) ///
smooth(8) recenter(bot) sort1(value) sort2(value) ///
laba(0) labpos(3 3) labg(0.5) gap(2) labs(3) ///
noval showtot lw(none) title("", size(0)) ///
note("", size(0)) plotregion(margin(l+5 r+5 b+0)) ///
ctitle("{bf:Employment}" "{bf:Secondary}" "{bf:College}") ctwrap(8) ///
ctgap(5) xsize(2) ysize(1) offset(23)
graph export fig3_transitionsankey2.svg, replace

global mergeddata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.4 Merged data"
save "${mergeddata}/second_transition_matrix.dta"

/*==============================================================================
                     Wave 1 or period t-1 (comparing with asset proxy)
==============================================================================*/

/*==============================================================================
 5.General setup / Work environment (Wave 1)                                  
==============================================================================*/

clear all
global mergeddata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.4 Merged data"

*---------5.1: Install necessary packages
/*
ssc install spineplot, replace
ssc install schemepack, replace
ssc install sankey, replace
net install sankey, from("https://raw.githubusercontent.com/asjadnaqvi/stata-sankey/main/installation/") replace
ssc install palettes, replace
ssc install colrspace, replace
ssc install graphfunctions, replace
*/

/*==============================================================================
 6.Import (Wave 1)                                                            
==============================================================================*/

use "${mergeddata}/empldemoassets_asp_w1_mg.dta"
numlabel, add

/*==============================================================================
 7. Create comparison graphs and tables (Wave 1) 
==============================================================================*/

*------------7.1: Cross-tabulations of aspirations-capabilities
tab asp_wave1 recent_anyjob , cell
tab asp_wave1 college, cell
tab asp_wave1 secondary_edu, cell
tab asp_wave1 immob_asset2, cell

*------------7.2: Combined graphic
* Figure 2: Operationalized (im)mobility categories using various proxies
twoway function y=0, range(0 100) ///
lcolor(none) ///
, ///
xscale(range(0 100)) ///
yscale(range(0 100)) ///
xline(50, lpattern(dash) lcolor(black)) ///
yline(50, lpattern(dash) lcolor(black)) ///
xtitle("Mobility capability (employment versus education proxies)") ///
ytitle("Migration aspirations") ///
xlabel(25 "Low capability" 75 "High capability", noticks) ///
ylabel(25 "Low aspiration" 75 "High aspiration", angle(vertical) noticks) ///
text(82 25 "{bf:Involuntary immobility}", size(medium)) ///
text(65 25 "Employment: 7.08%" "Secondary: 4.61%" "College: 14.24%" "Assets: 8.59%", size(medium)) ///
text(82 75 "{bf:Mobility}", size(medium)) ///
text(65 75 "Employment: 10.02%" "Secondary: 12.51%" "College: 2.86%" "Assets: 8.22%", size(medium)) ///
text(32 25 "{bf:Acquiescent immobility}", size(medium)) ///
text(15 25 "Employment: 38.56%" "Secondary: 45.68%" "College: 77.21%" "Assets: 53.34%", size(medium)) ///
text(32 75 "{bf:Voluntary immobility}", size(medium)) ///
text(15 75 "Employment: 44.34%" "Secondary: 37.20%" "College: 5.69%" "Assets: 29.85%", size(medium)) ///
legend(off)

cd "C:\Users\hp\Desktop\Thesis\Stata procedure\03. Output\03.2 Figures"

graph export fig2_combined_proxies2.svg, replace

/*==============================================================================
 8. Create third transition matrix and sankey graph (wave 1)
==============================================================================*/
clear all
global mergeddata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.4 Merged data"
use "${mergeddata}/empldemoassets_asp_w1_mg.dta"

gen value=1
gen immob_edu3=.
replace immob_edu3=4 if secondary_edu==1 & asp_wave1==1
replace immob_edu3=3 if secondary_edu==1 & asp_wave1==3
replace immob_edu3=2 if secondary_edu==0 & asp_wave1==1
replace immob_edu3=1 if secondary_edu==0 & asp_wave1==3
label values immob_edu3 immob_cat

*------------8.1: Create (im)mobility labels
label define immob_cat 4"Mobility" 3"Voluntary immobility" ///
2"Involuntary immobility" 1"Acquiescent immobility"

*------------8.2: Create education (secondary) immobility variable
gen immob_asset2_final=.
replace immob_asset2_final=4 if immob_asset2==1 & asp_wave1==1
replace immob_asset2_final=3 if immob_asset2==1 & asp_wave1==3
replace immob_asset2_final=2 if immob_asset2==0 & asp_wave1==1
replace immob_asset2_final=1 if immob_asset2==0 & asp_wave1==3
label values immob_asset2_final immob_cat

*-----------8.3:  Create collapsed transition matrix
cd "C:\Users\hp\Desktop\Thesis\Stata procedure\03. Output\03.2 Figures"
preserve
keep immob_job immob_asset2_final
gen value=1
collapse (sum) value, by(immob_job immob_asset2_final)
drop if immob_job==. | immob_asset2_final==. 
bysort immob_job: egen rowtotal = total(value)
gen pct_transition = 100 * value / rowtotal
format pct_transition %4.1f

*-----------8.4:  Create sankey graph
sankey value, from(immob_job) to(immob_asset2_final) format(%15.0fc) ///
    smooth(8) palette(HCL intense) sort1(value) sort2(value) labs(3) ///
    laba(0) labpos(3 3) labg(0.5) gap(2) ///
    noval showtot lw(none) title("", size(0)) ///
    note("", size(0)) plotregion(margin(l+5 r+5 b+0)) ///
	ctitle("{bf:Employment}" "{bf:Asset index}") ctwrap(8) ///
    ctgap(5) xsize(2) ysize(1) offset(30)
graph export fig3_transitionsankey4.svg, replace

/*==============================================================================
 9. Create fourth transition matrix and sankey graph (wave 1)
==============================================================================*/

*-----------9.5:  Create layers
tempfile layer1 layer2

*-----------9.6:  Create first transition: immob_job to immob_edu3
preserve
keep immob_job immob_edu3 value
rename immob_job source
rename immob_edu3 destination
gen layer = 1
save `layer1'
restore

*-----------9.7: Create second transition: immob_edu3 to immob_assets
preserve
keep immob_edu3 immob_asset2_final value
rename immob_edu3 source
rename immob_asset2_final destination
gen layer = 2
save `layer2'
restore

*-----------9.8: Combine layers
use `layer1', clear
append using `layer2'

*-----------9.9: Sankey graph
sankey value, from(source) to(destination) by(layer) palette(HCL intense) ///
smooth(8) recenter(bot) sort1(value) sort2(value) ///
laba(0) labpos(3 3) labg(0.5) gap(2) labs(3) ///
noval showtot lw(none) title("", size(0)) ///
note("", size(0)) plotregion(margin(l+5 r+5 b+0)) ///
ctitle("{bf:Employment}" "{bf:Secondary}" "{bf:Assets}") ctwrap(8) ///
ctgap(5) xsize(2) ysize(1) offset(23)
graph export fig3_transitionsankey3.svg, replace

*-----------9.10: Save transition matrix

global mergeddata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.4 Merged data"
save "${mergeddata}/third_transition_matrix.dta"

/*==============================================================================
 9. Create fourth transition matrix and sankey graph (wave 1)
==============================================================================*/

clear all
global mergeddata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.4 Merged data"
use "${mergeddata}/empldemoassets_asp_w1_mg.dta"

*-----------4.6:  Create collapsed transition matrix
cd "C:\Users\hp\Desktop\Thesis\Stata procedure\03. Output\03.2 Figures"
preserve
keep immob_job immob_asset2_final
gen value=1
collapse (sum) value, by(immob_job immob_asset2_final)
drop if immob_job==. | immob_asset2_final==. 
bysort immob_job: egen rowtotal = total(value)
gen pct_transition = 100 * value / rowtotal
format pct_transition %4.1f

*-----------4.7:  Create sankey graph
sankey value, from(immob_job) to(immob_asset2_final) format(%15.0fc) ///
    smooth(8) palette(HCL intense) sort1(value) sort2(value) labs(3) ///
    laba(0) labpos(3 3) labg(0.5) gap(2) ///
    noval showtot lw(none) title("", size(0)) ///
    note("", size(0)) plotregion(margin(l+5 r+5 b+0)) ///
	ctitle("{bf:Employment}" "{bf:Asset index}") ctwrap(8) ///
    ctgap(5) xsize(2) ysize(1) offset(30)
graph export fig4_transitionsankey5.svg, replace

*-----------4.8:  Save transition data
global mergeddata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.4 Merged data"
save "${mergeddata}/fourth_transition_matrix.dta"

/*==============================================================================
                     Wave 1 or period t-1 (comparing with land /house)
==============================================================================*/

/*==============================================================================
 10.General setup / Work environment (Wave 1)                                  
==============================================================================*/

clear all
global mergeddata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.4 Merged data"

/*==============================================================================
 11.Import (Wave 1)                                                            
==============================================================================*/

use "${mergeddata}/allproxies_w1_mg.dta"
numlabel, add

/*==============================================================================
 12.Generate (im)mobility categories according to land/house ownerhip                                                      
==============================================================================*/
*------------12.1: Create owns either house or land
gen owns_property=1 if hh_house==1
replace owns_property=1 if hh_land==1
replace owns_property=0 if (hh_land==0 & hh_house==0)
replace owns_property=0 if (hh_land==. & hh_house==0)
replace owns_property=0 if (hh_land==0 & hh_house==.)
replace owns_property=0 if (hh_land==. & hh_house==.)

*------------12.2: Generate immobility categories based on property
gen immob_property=.
replace immob_property=4 if owns_property==1 & asp_wave1==1
replace immob_property=3 if owns_property==1 & asp_wave1==3
replace immob_property=2 if owns_property==0 & asp_wave1==1
replace immob_property=1 if owns_property==0 & asp_wave1==3
label values immob_property immob_cat
tab immob_property

*------------12.3: Generate immobility categories based on land only
gen hh_land2=hh_land
replace hh_land2=0 if hh_land==.
gen immob_land=.
replace immob_land=4 if hh_land2==1 & asp_wave1==1
replace immob_land=3 if hh_land2==1 & asp_wave1==3
replace immob_land=2 if hh_land2==0 & asp_wave1==1
replace immob_land=1 if hh_land2==0 & asp_wave1==3
label values immob_land immob_cat
tab immob_land

*------------12.4: Generate immobility categories based on house ownership only
gen immob_house=.
replace immob_house=4 if hh_house==1 & asp_wave1==1
replace immob_house=3 if hh_house==1 & asp_wave1==3
replace immob_house=2 if hh_house==0 & asp_wave1==1
replace immob_house=1 if hh_house==0 & asp_wave1==3
label values immob_house immob_cat
tab immob_house

/*==============================================================================
 13. Create comparison graphs and tables (Wave 1) 
==============================================================================*/

*------------13.1: Cross-tabulations of aspirations-capabilities
tab asp_wave1 recent_anyjob , cell
tab asp_wave1 college, cell
tab asp_wave1 secondary_edu, cell
tab asp_wave1 immob_asset2, cell
tab asp_wave1 owns_property, cell

*------------13.2: Combined graphic
* Figure 2: Operationalized (im)mobility categories using all proxies
twoway function y=0, range(0 100) ///
lcolor(none) ///
, ///
xscale(range(0 100)) ///
yscale(range(0 100)) ///
xline(50, lpattern(dash) lcolor(black)) ///
yline(50, lpattern(dash) lcolor(black)) ///
xtitle("Mobility capability (selected unidimensional proxies)") ///
ytitle("Migration aspirations") ///
xlabel(25 "Low capability" 75 "High capability", noticks) ///
ylabel(25 "Low aspiration" 75 "High aspiration", angle(vertical) noticks) ///
text(82 25 "{bf:Involuntary immobility}", size(medium)) ///
text(65 25 "Employment: 7.08%" "Secondary: 4.61%" "College: 14.24%" "Assets: 8.59%" "Property: 6.20%", size(medium)) ///
text(82 75 "{bf:Mobility}", size(medium)) ///
text(65 75 "Employment: 10.02%" "Secondary: 12.51%" "College: 2.86%" "Assets: 8.22%" "Property: 10.90%", size(medium)) ///
text(32 25 "{bf:Acquiescent immobility}", size(medium)) ///
text(15 25 "Employment: 38.56%" "Secondary: 45.68%" "College: 77.21%" "Assets: 53.34%" "Property: 24.77%", size(medium)) ///
text(32 75 "{bf:Voluntary immobility}", size(medium)) ///
text(15 75 "Employment: 44.34%" "Secondary: 37.20%" "College: 5.69%" "Assets: 29.85%" "Property: 58.13%", size(medium)) ///
legend(off)

cd "C:\Users\hp\Desktop\Thesis\Stata procedure\03. Output\03.2 Figures"

graph export fig2_combined_proxies3.svg, replace

save "${mergeddata}/allproxies_w1_mg.dta", replace

/*==============================================================================
 14. Create fifth transition matrix and sankey graph (wave 1)
==============================================================================*/

*-----------14.1:  Create collapsed transition matrix
cd "C:\Users\hp\Desktop\Thesis\Stata procedure\03. Output\03.2 Figures"
preserve
keep immob_asset2_final immob_property
gen value=1
collapse (sum) value, by(immob_asset2_final immob_property)
drop if immob_asset2_final==. | immob_property==. 
bysort immob_property: egen rowtotal = total(value)
gen pct_transition = 100 * value / rowtotal
format pct_transition %4.1f

*-----------14.2:  Create sankey graph
sankey value, from(immob_asset2_final) to(immob_property) format(%15.0fc) ///
    smooth(8) palette(HCL intense) sort1(value) sort2(value) labs(3) ///
    laba(0) labpos(3 3) labg(0.5) gap(2) ///
    noval showtot lw(none) title("", size(0)) ///
    note("", size(0)) plotregion(margin(l+5 r+5 b+0)) ///
	ctitle("{bf:Asset index}" "{bf:Property ownership}") ctwrap(8) ///
    ctgap(5) xsize(2) ysize(1) offset(30)
graph export fig4_transitionsankey6.svg, replace

*-----------14.3:  Save transition data
global mergeddata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.4 Merged data"
save "${mergeddata}/fifth_transition_matrix.dta"

/*==============================================================================
 15. Create sixth transition matrix (wave 1)
==============================================================================*/
*-----------15.1:  Create layers
tempfile layer1 layer2

*-----------15.2:  Create first transition: immob_job immob_asset2_final
preserve
keep immob_job immob_asset2_final value
rename immob_job source
rename immob_asset2_final destination
gen layer = 1
save `layer1'
restore

*-----------15.3: Create second transition: immob_asset2_final immob_property
preserve
keep immob_asset2_final immob_property value
rename immob_asset2_final source
rename immob_property destination
gen layer = 2
save `layer2'
restore

*-----------15.4: Combine layers
use `layer1', clear
append using `layer2'

*-----------15.5: Sankey graph
sankey value, from(source) to(destination) by(layer) palette(HCL intense) ///
smooth(8) recenter(bot) sort1(value) sort2(value) ///
laba(0) labpos(3 3) labg(0.5) gap(2) labs(3) ///
noval showtot lw(none) title("", size(0)) ///
note("", size(0)) plotregion(margin(l+5 r+5 b+0)) ///
ctitle("{bf:Employment}" "{bf:Asset index}" "{bf:Property}") ctwrap(8) ///
ctgap(5) xsize(2) ysize(1) offset(23)
graph export fig3_transitionsankey7.svg, replace

*-----------15.6: Save transition matrix

global mergeddata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.4 Merged data"
save "${mergeddata}/sixth_transition_matrix.dta"