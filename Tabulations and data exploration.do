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
Modification date:     
Product 1:             Contrast two unidimensional capability measurements

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

gen highschool_edu=1 if ls14>=6 & ls14!=98 & ls14!=.
replace highschool_edu=0 if ls14<6

gen educated=1 if ls14>1 & ls14!=98 & ls14!=.
replace educated=0 if ls14==1

preserve
label define asp_lbl 3"No aspiration to migrate" 1 "Aspiration to migrate"
label values asp_wave1 asp_lbl
label define emp_lbl 0 "Low capability (employment proxy)" 1"High capability (employment proxy)"
label values recent_anyjob emp_lbl
label define edu_lbl 0 "Low capability (education proxy)" 1"High capability (education proxy)"
label values highschool_edu edu_lbl

tab asp_wave1 recent_anyjob , cell
tab asp_wave1 highschool_edu, cell

twoway function y=0, range(0 100) ///
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

twoway function y=0, range(0 100) ///
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

save "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.4 Merged data/empldemo_asp_w1_mg.dta", replace
