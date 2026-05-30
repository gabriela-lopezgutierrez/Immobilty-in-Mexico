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
                       - Figure 2: Four quadrants graphic
Product 2:             Generate transition graphics between categories
                       - Figure 3: Transitions between categories	   
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
