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
Modification date:     May 2026 /27
Product 1:             Contrast two unidimensional capability measurements
                       - Figure 2: Operationalized (im)mobility categories 
					     using the employment proxy
					   - Figure 3: Operationalized (im)mobility categories
					     using the education proxy
Product 2:             Generate transition graphics between categories
                       - Figure 4: Transitions between categories	   
Code inspo:            https://github.com/asjadnaqvi/stata-sankey/blob/main/README.md
*/

/*==============================================================================
                            Wave 1 or period t-1
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

*------------3.2: Cross-tabulations of aspirations-capabilities
tab asp_wave1 recent_anyjob , cell
tab asp_wave1 highschool_edu, cell
tab asp_wave1 college, cell

**Note: for graphs 3.3, 3.4 and 3.5 percentages are extracted from 3.2

cd "C:\Users\hp\Desktop\Thesis\Stata procedure\03. Output\03.2 Figures"

*------------3.3: Graph of employment proxy for capability
* Figure 2: Operationalized (im)mobility categories using the employment proxy
twoway function y=0, range(0 100) ///
lcolor(none) ///
, ///
xscale(range(0 100)) ///
yscale(range(0 100)) ///
xline(50, lpattern(dash) lcolor(black)) ///
yline(50, lpattern(dash) lcolor(black)) ///
xtitle("Mobility capability (employment proxy)") ///
ytitle("Migration aspirations") ///
xlabel(25 "Low capability" 75 "High capability", noticks) ///
ylabel(25 "No aspiration" 75 "Aspiration", angle(horizontal) noticks) ///
text(75 25 "Potential involuntary immobility" "7.08%", size(medium)) ///
text(75 75 "Potential mobility" "10.02%", size(medium)) ///
text(25 25 "Potential acquiescent immobility" "38.56%", size(medium)) ///
text(25 75 "Potential voluntary immobility" "44.34%", size(medium)) ///
legend(off)
graph export fig2_employment_proxy.svg, replace


*------------3.4: Graph of education (high-school) proxy for capability
twoway function y=0, range(0 100) ///
lcolor (none) ///
, ///
xscale(range(0 100)) ///
yscale(range(0 100)) ///
xline(50, lpattern(dash) lcolor(black)) ///
yline(50, lpattern(dash) lcolor(black)) ///
xtitle("Mobility capability (education proxy)") ///
ytitle("Migration aspirations") ///
xlabel(25 "Low capability" 75 "High capability", noticks) ///
ylabel(25 "No aspiration" 75 "Aspiration", angle(horizontal) noticks) ///
text(75 25 "Potential involuntary immobility" "9.97%", size(medium)) ///
text(75 75 "Potential mobility" "7.15%", size(medium)) ///
text(25 25 "Potential acquiescent immobility" "66.89%", size(medium)) ///
text(25 75 "Potential voluntary immobility" "15.99%", size(medium)) ///
legend(off)

*------------3.5: Graph of education (college) proxy for capability
* Figure 2: Operationalized (im)mobility categories using the employment proxy
twoway function y=0, range(0 100) ///
lcolor(none) ///
, ///
xscale(range(0 100)) ///
yscale(range(0 100)) ///
xline(50, lpattern(dash) lcolor(black)) ///
yline(50, lpattern(dash) lcolor(black)) ///
xtitle("Mobility capability (education proxy)") ///
ytitle("Migration aspirations") ///
xlabel(25 "Low capability" 75 "High capability", noticks) ///
ylabel(25 "No aspiration" 75 "Aspiration", angle(horizontal) noticks) ///
text(75 25 "Potential involuntary immobility" "14.24%", size(medium)) ///
text(75 75 "Potential mobility" "2.86%", size(medium)) ///
text(25 25 "Potential acquiescent immobility" "77.21%", size(medium)) ///
text(25 75 "Potential voluntary immobility" "5.69%", size(medium)) ///
legend(off)
graph export fig2_education_proxy.svg, replace

save "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.4 Merged data/empldemo_asp_w1_mg.dta", replace


/*==============================================================================
 4. Create transition matrix and sankey graph (wave 1)
==============================================================================*/

clear all
use "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.4 Merged data/empldemo_asp_w1_mg.dta"

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

*-----------4.5:  Create custom labels before collapsing
label define immob_job_2 1"Acquiescent (38.56%)" 2"Involuntary immobility (7.08%)" /// 
3"Voluntary immobility (44.34%)" 4 "Mobility (10.02%)"
label values immob_job immob_job_2

*-----------4.6:  Create collapsed transition matrix
cd "C:\Users\hp\Desktop\Thesis\Stata procedure\03. Output\03.2 Figures"
preserve
keep immob_job immob_edu2
gen value=1
collapse (sum) value, by(immob_job immob_edu2)
drop if immob_job==. | immob_edu2==.
bysort immob_job: egen rowtotal = total(value)
gen pct_transition = 100 * value / rowtotal
format pct_transition %4.1f

*-----------4.7:  Create sankey graph
sankey value, from(immob_job) to(immob_edu2) format(%15.0fc) ///
    smooth(8) palette(HCL intense) sort1(value) sort2(value) labs(3) ///
    laba(0) labpos(3 3) labg(0.5) gap(2) ///
    noval showtot lw(none) title("", size(0)) ///
    note("", size(0)) plotregion(margin(l+5 r+5 b+0)) ///
	ctitle("{bf:Employment}" "{bf:Education}") ctwrap(8) ///
    ctgap(5) xsize(2) ysize(1) offset(30)
graph export fig3_transitionsankey1.svg, replace


*-----------4.7:  Save transition data
global mergeddata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.4 Merged data"
save "${mergeddata}/first_transition_matrix.dta"
