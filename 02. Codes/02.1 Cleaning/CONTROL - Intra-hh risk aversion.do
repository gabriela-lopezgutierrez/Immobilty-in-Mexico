/*==============================================================================
                   MMCI - Cleaning individual level variables                  
==============================================================================*/
/*

Project:               (Im)mobility in Mexico
Database:              Mexico Life Survey - Wave 1, 2 and 3
Level:                 Individual databases
Book:                  Book IIIB - Characteristics of Adult Household Members
                    
Subsection:            RG - Risk aversion
Dofile author:         Gabriela Judith López Gutiérrez
Creation date:         July 2026 /10
Modification date:     June 2026 /20
Product 1:             Build risk aversion control
Nussbaum 10:           
Dimension (study):
Variable:              Control variable risk aversion
Flow:                  1. Merge database with cover data (from hh control book)
                       2. Keep only relevant variables
					   3. Value labels and generate variables
					   4. Repeat for proxy book 
					   5. Join proxy book and official book (handle duplicates)
					   6. Repeat for each wave
					   5. Create panel
Changes per wave:      
Note:                  
Keys community:        Communitary id joins cover data with community data
Keys hh level:         HH id joins cover data with hh level data
Keys two levels:       Locality id joins community with hh-level data
Note:                  IDs are a combination of (folio + ls)
Note:                  Duplicate report and handling section varies by wave
Note:                  In wave 2 and 3 you keep pid_link (id 2002)
Note:                  Now for every merge do a post validation check with frames
*/

/*==============================================================================
                     WAVE 2 (PERIOD T) - REGULAR BOOK
==============================================================================*/

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                      Variables: Risk aversion control
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

/*==============================================================================
 0.General setup / Work environment (Wave 2) and merging                               
==============================================================================*/

set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave II\Individual\hh05dta_b3b - Wave 2"

*------------1.1: Prepare database VLI to merge (with individual datasets)
use "${rawdata}\iiib_rg"
gen folio_str=folio
gen ls_str=ls
gen individual_id = folio + "_" + ls
rename ls ls_individual
rename ls_str ls_str_individual
order folio_str- individual_id, a( pid_link)
save "${rawdata}\riskaversion_aux", replace

*------------1.2: Merge with cover data at household level (creating bridge)
* Note: Bridge to merge with community data through loc_id
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave II\Household\hh05dta_bc - Book C (Control book) W2"
use "${rawdata}\c_portad"
gen folio_str=folio
gen ls_str=ls
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave II\Individual\hh05dta_b3b - Wave 2"
drop if folio==""
duplicates report folio_str
duplicates list folio_str
save "${rawdata}\cbportad_aux", replace

merge 1:m folio using "${rawdata}\riskaversion_aux", generate(_merge_1)
drop if _merge_1==1

*------------1.3: Keep only relevant data
keep folio folio_str ls ls_str ent mpio loc edad id_loc individual_id _merge_1 ls_str_individual ls_individual rg01 rg02 rg03 rg04 rg05 rg06 rg07 pid_link
order ls_str_individual- _merge_1, a( ls_individual)


/*==============================================================================
 2.Add label / rename variables - Risk aversion (wave 2)
==============================================================================*/

*------------2.1: Label risk aversion intro question
label define lbl_riskaintro 1"Blue" 2"Yellow" 3"Same probability" 8"Don't know"
label values rg01 lbl_riskaintro

*------------2.2: Label risk aversion question 1
label define lbl_riska1 1"Bag 1: $1000" 2"Bag 2: $500 or $2000" 8"Don't know"
label values rg02 lbl_riska1

*------------2.3: Label risk aversion question 2
label define lbl_riska2 1"Bag 1: $500 or $2,000" 2"Bag 2: $300 or $3,000" ///
8"Don't know"
label values rg03 lbl_riska2

*------------2.4: Label risk aversion question 3
label define lbl_riska3 1"Bag 1: $100 or $4,000" 2"Bag 2: $100 or $7,000" ///
8"Don't know"
label values rg04 lbl_riska3

*------------2.5: Label risk aversion question 4
label define lbl_riska4 1"Bag 1: $1,000 or $1,000" 2"$800 or $2,000" ///
8"Don't know"
label values rg05 lbl_riska4

*------------2.6: Label risk aversion question 5
label define lbl_riska5 1"Bag 1: $1,000 or $1,000" 2"$800 or $4,000" ///
8"Don't know"
label values rg06 lbl_riska5

*------------2.6: Label risk aversion question 6
label define lbl_riska6 1"Bag 1: $1,000 or $1,000" 2"$800 or $8,000" ///
8"Don't know"
label values rg07 lbl_riska6

/*==============================================================================
 3.Create risk aversion scale (wave 2)
==============================================================================*/

*-----------3.1: Create risk aversion scale label
label define lbl_riskscale 1"Lowest risk aversion" ///
2"Second lowest risk aversion" 3"Third lowest risk aversion" ///
4"Fourth lowest risk aversion" 5"Third highest risk aversion" ///
6"Second highest risk aversion" 7"Highest risk aversion" ///
8"Non informative", modify

*-----------3.2: Create risk aversion scale
**Note code categories according to paths
gen risk_aversion=.
label values risk_aversion lbl_riskscale
label var risk_aversion "Individual-lottery: risk aversion score"

    *-------3.2.1: Create the two paths towards 7
replace risk_aversion=7 if rg02==1 & rg05==1 & rg06==1 & rg07==1
replace risk_aversion=7 if rg02==2 & rg03==1 & rg05==1 & rg06==1 & rg07==1

    *-------3.2.2: Create the two paths towards 6
replace risk_aversion=6 if rg02==1 & rg05==1 & rg06==1 & rg07==2
replace risk_aversion=6 if rg02==2 & rg03==1 & rg05==1 & rg06==1 & rg07==2

    *-------3.2.3: Create the two paths towards 5
replace risk_aversion=5 if rg02==1 & rg05==1 & rg06==2
replace risk_aversion=5 if rg02==2 & rg03==1 & rg05==1 & rg06==2

    *-------3.2.4: Create the one path towards 4
replace risk_aversion=4 if rg02==1 & rg05==2

    *-------3.2.5: Create the two paths towards 3
replace risk_aversion=3 if rg02==2 & rg03==1 & rg05==2

    *-------3.2.6: Create the two paths towards 2

replace risk_aversion=2 if rg02==2 & rg03==2 & rg04==1

    *-------3.2.7: Create the two paths towards 1
replace risk_aversion=1 if rg02==2 & rg03==2 & rg04==2

*-----------3.3: Creating supra-scale risk aversion
/*
gen risk_aversion_supra=1
*/

/*==============================================================================
 4.Cleaning risk aversion variable
==============================================================================*/

*------------4.1: Generate possible errors
foreach var of varlist rg01-rg07 {
    gen uncertain_`var' = (`var' == 8)
}
egen uncertain_sum=rowtotal(uncertain_*)
drop uncertain_rg01- uncertain_rg07
drop if uncertain_sum>0 & uncertain_sum!=.
gen error_exercise=1 if rg02==. & rg03==. & rg04==. & rg05==. & rg06!=. & ///
rg07==.
drop if error_exercise==1
drop if rg02==. & rg03==. & rg04==. & rg05==. & rg06==. & rg07==.
gen incorrect_jump=1 if rg02!=. & rg03==. & rg04==. & rg05==. & rg06!=. ///
& rg07==.
drop if incorrect_jump==1
gen incorrect_sequence=1 if rg02!=. & rg03!=. & rg04==. & rg05==. & rg06!=. ///
& rg07==.
drop if incorrect_sequence==1
drop uncertain_sum- incorrect_sequence

/*==============================================================================
 5. Generate intrahousehold measures
==============================================================================*/

*------------5.1: Intrahousehold measures
bys folio: egen avgrisk_hh_lott = mean(risk_aversion) 
label var avgrisk_hh_lott "Intra-lottery: average HH risk aversion"
bys folio: egen risksd_hh_lott = sd(risk_aversion)
label var risksd_hh_lott "Intra-lottery: HH risk-aversion dispersion"
gen ind_risk_gap = risk_aversion - avgrisk_hh_lott
label var ind_risk_gap "Intra-lottery: individual-HH risk aversion gap"
bys folio: egen riskmax_hh = max(risk_aversion)
label var riskmax_hh "Intra-lottery: maximum HH risk aversion"
bys folio: egen riskmin_hh = min(risk_aversion)
label var riskmin_hh "Intra-lottery: minimum HH risk aversion"
gen riskrange_hh = riskmax_hh-riskmin_hh
label var riskrange_hh "Intra-lottery: HH risk-aversion range"
bys folio: egen hhsize = count(individual_id)
bys folio: egen risk_total = total(risk_aversion)
gen risk_hh_excl = (risk_total - risk_aversion)/(hhsize - 1)
drop hhsize risk_total
label var risk_hh_excl "Intra-lottery: average HH -excluding ind - risk aversion"

/*==============================================================================
* 3. Save final version - Risk aversion                                       *
==============================================================================*/

*------------3.1: Seva unmerged dataset at individual level
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
gen panel_wave=2
label var panel_wave "Panel wave from MxFLS"
order panel_wave, b(folio)
gen origin_report="Official book"
label var origin_report "Type of book the data originated from"
label var ls "Individual ID from cover book"
label var ls_str "Individual ID from cover book"
sort folio ls_individual
drop rg01- _merge_1
save "${finaldata}\CONTROL1.Risk_aversion_w2_fin.dta", replace

/*==============================================================================
                     WAVE 3 (PERIOD T+1) - REGULAR BOOK
==============================================================================*/

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                      Variables: Risk aversion control
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/


/*==============================================================================
 0.General setup / Work environment (Wave 2) and merging                               
==============================================================================*/

set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave III\Individual\hh09dta_b3b - Wave 3"

*------------1.1: Prepare database VLI to merge (with individual datasets)
use "${rawdata}\iiib_rg"
gen folio_str=folio
gen ls_str=ls
gen individual_id = folio + "_" + ls
rename ls ls_individual
rename ls_str ls_str_individual
order folio_str- individual_id, a( pid_link)
save "${rawdata}\riskaversion_aux", replace

*------------1.2: Merge with cover data at household level (creating bridge)
* Note: Bridge to merge with community data through loc_id
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave III\Household\hh09dta_bc - Book C (Control book) W3"
use "${rawdata}\c_portad"
gen folio_str=folio
gen ls_str=ls
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave III\Individual\hh09dta_b3b - Wave 3"
drop if folio==""
duplicates report folio_str
duplicates list folio_str
save "${rawdata}\cbportad_aux", replace

merge 1:m folio using "${rawdata}\riskaversion_aux", generate(_merge_1)
drop if _merge_1==1

*------------1.3: Keep only relevant data
keep folio folio_str ls ls_str ent mpio loc edad id_loc individual_id _merge_1 ls_str_individual ls_individual rg01 rg02 rg03 rg04 rg05 rg06 rg07 pid_link
order ls_str_individual- _merge_1, a( ls_individual)
order pid_link, a( individual_id)

/*==============================================================================
 2.Add label / rename variables - Risk aversion (wave 3)
==============================================================================*/

*-----------3.1: Create risk aversion scale label
label define lbl_riskscalew3 1"Lowest risk aversion" ///
2"Second lowest risk aversion" 3"Third lowest risk aversion" ///
4"Fourth lowest risk aversion" 5"Highest risk aversion" ///
6"Gamble aversion" 7"Higher gamble aversion" ///
8"Non informative", modify

*-----------3.2: Create risk aversion scale
**Note code categories according to paths
gen risk_aversion_w3=.
label values risk_aversion_w3 lbl_riskscalew3
label var risk_aversion "Individual-lottery: risk aversion score"

    *-------3.2.1: Create the two paths towards 7
replace risk_aversion=7 if rg01==1 & rg02==1 & rg07==1 

    *-------3.2.2: Create the two paths towards 6
replace risk_aversion=6 if rg01==1 & rg02==1 & rg07==2

   *-------3.2.3: Create the two paths towards 5
replace risk_aversion=5 if rg01==1 & rg02==2 & rg03==1
replace risk_aversion=5 if rg01==2 & rg03==1

   *-------3.2.4: Create the two paths towards 4
replace risk_aversion=4 if rg01==1 & rg02==2 & rg03==2 & rg04==1 
replace risk_aversion=4 if rg01==2 & rg03==2 & rg04==1 

   *-------3.2.5: Create the two paths towards 3
replace risk_aversion=3 if rg01==1 & rg02==2 & rg03==2 & rg04==2 & rg05==1
replace risk_aversion=3 if rg01==2 & rg03==2 & rg04==2 & rg05==1

   *-------3.2.6: Create the two paths towards 2
replace risk_aversion=2 if rg01==1 & rg02==2 & rg03==2 & rg04==2 & rg05==2 & rg06==1
replace risk_aversion=2 if rg01==2 & rg03==2 & rg04==2 & rg05==2 & rg06==1

   *-------3.2.7: Create the two paths towards 1
replace risk_aversion=1 if rg01==1 & rg02==2 & rg03==2 & rg04==2 & rg05==2 & rg06==2
replace risk_aversion=1 if rg01==2 & rg03==2 & rg04==2 & rg05==2 & rg06==2

/*==============================================================================
 4.Cleaning risk aversion variable
==============================================================================*/

*------------4.1: Generate possible errors
foreach var of varlist rg01-rg07 {
    gen uncertain_`var' = (`var' == 8)
}
egen uncertain_sum=rowtotal(uncertain_*)
drop uncertain_rg01- uncertain_rg07
drop if uncertain_sum>0 & uncertain_sum!=.

*------------4.2: Generate missing errors
foreach var of varlist rg01-rg07 {
    gen missing_`var' = (`var' == .)
}
egen missing_sum=rowtotal(missing_*)
drop if missing_sum==7
drop missing_*

/*==============================================================================
 5. Generate intrahousehold measures
==============================================================================*/

*------------5.1: Intrahousehold measures
bys folio: egen avgrisk_hh_lott = mean(risk_aversion) 
label var avgrisk_hh_lott "Intra-lottery: average HH risk aversion"
bys folio: egen risksd_hh_lott = sd(risk_aversion)
label var risksd_hh_lott "Intra-lottery: HH risk-aversion dispersion"
gen ind_risk_gap = risk_aversion - avgrisk_hh_lott
label var ind_risk_gap "Intra-lottery: individual-HH risk aversion gap"
bys folio: egen riskmax_hh = max(risk_aversion)
label var riskmax_hh "Intra-lottery: maximum HH risk aversion"
bys folio: egen riskmin_hh = min(risk_aversion)
label var riskmin_hh "Intra-lottery: minimum HH risk aversion"
gen riskrange_hh = riskmax_hh-riskmin_hh
label var riskrange_hh "Intra-lottery: HH risk-aversion range"
bys folio: egen hhsize = count(individual_id)
bys folio: egen risk_total = total(risk_aversion)
gen risk_hh_excl = (risk_total - risk_aversion)/(hhsize - 1)
drop hhsize risk_total
label var risk_hh_excl "Intra-lottery: average HH -excluding ind - risk aversion"

/*==============================================================================
* 3. Save final version - Risk aversion                                       *
==============================================================================*/

*------------3.1: Seva unmerged dataset at individual level
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
gen panel_wave=3
label var panel_wave "Panel wave from MxFLS"
order panel_wave, b(folio)
gen origin_report="Official book"
label var origin_report "Type of book the data originated from"
label var ls "Individual ID from cover book"
label var ls_str "Individual ID from cover book"
sort folio ls_individual
drop rg01- _merge_1
save "${finaldata}\CONTROL1.Risk_aversion_w3_fin.dta", replace


/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                     Panel merge (MxFLS 1 / MxFLS 2 / MxFLS 3)
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

/*==============================================================================
* PHASE 2: Harmonize folio id variable ()                                      *
==============================================================================*/

*------------P.2.1: Harmonize folio variable (Wave 3)
*Do: extract only numerics 
clear all
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
use "${finaldata}\CONTROL1.Risk_aversion_w3_fin.dta"
gen folio_left = substr(folio, 1, 6)
gen folio_right = substr(folio, 9, 10)
gen folio_clean = folio_left + "" + folio_right
drop folio_str
replace folio=folio_clean
drop folio_left folio_right folio_clean
drop uncertain_sum
save "${finaldata}\CONTROL1.Risk_aversion_w3_fin.dta", replace

*------------P.2.1: Harmonize folio variable (Wave 2)
*Do: generate trailing zeroes for folio
clear all
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
use "${finaldata}\CONTROL1.Risk_aversion_w2_fin.dta"
/*gen folio_str_aux = string(folio, "%08.0f")
drop folio
rename folio_str_aux folio
order folio , a( panel_wave)
label var folio "HOUSEHOLD ID 2005"
*/
drop folio_str
save "${finaldata}\CONTROL1.Risk_aversion_w2_fin.dta", replace
*/

/*==============================================================================
* PHASE 2: Harmonize pidlink                                                   *
==============================================================================*/

*------------P.2.1: Harmonize pid_link variable (Wave 3)
*Do: extract only numerics 
clear all
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
use "${finaldata}\CONTROL1.Risk_aversion_w3_fin.dta"
gen pidlink_left = substr(pid_link, 1, 6)
gen pidlink_right = substr(pid_link, 9, 10)
gen pidlink_clean = pidlink_left + "" + pidlink_right
drop pidlink_right pidlink_left
order pidlink_clean, a(pid_link)
save "${finaldata}\CONTROL1.Risk_aversion_w3_fin.dta", replace


*------------P.2.2: Harmonize pid_link variable (Wave 2)
*Do: extract only numerics 
clear all
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
use "${finaldata}\CONTROL1.Risk_aversion_w2_fin.dta"
*Note: It looks like everything is harmonized
gen pidlink_clean=pid_link
order pidlink_clean, a(pid_link)
save "${finaldata}\CONTROL1.Risk_aversion_w2_fin.dta", replace


/*==============================================================================
* PHASE 3: First append                                                 *
==============================================================================*/

*------------P.3.1: Append waves
clear all
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
use "${finaldata}\CONTROL1.Risk_aversion_w3_fin.dta"
append using "${finaldata}\CONTROL1.Risk_aversion_w2_fin.dta"
sort pidlink_clean panel_wave
global paneldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.3 Panel data"
*Note: Unifiy don't know label differences
drop origin_report
rename risk_aversion risk_aversion_w2
order risk_aversion_w2, b( risk_aversion_w3)
save "${paneldata}\CONTROL1.Risk_aversion_panel.dta", replace

*------------P.3.2: Enconde id for panel analysis
encode pidlink_clean, gen(pid_id)
label var pid_id "Individual constant ID prepared for panel analysis"
duplicates report pid_id panel_wave
*Note: Found no duplicates
duplicates tag pid_id panel_wave, gen(dup)
list pid_link pidlink_clean pid_id folio panel_wave individual_id if dup
duplicates drop pidlink_clean panel_wave, force
*Note: No duplicates found
order pid_id, after(panel_wave)
order panel_wave pid_id, b( edad)
drop dup
sort pid_id panel_wave
order ls_str_individual individual_id, a( pidlink_clean)
save "${paneldata}\CONTROL1.Risk_aversion_panel.dta", replace


/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                 Post-append: Check panel characteristics
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/


global paneldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.3 Panel data"
use "${paneldata}\CONTROL1.Risk_aversion_panel.dta"

*------------PC.1: Verify panel characteristics

xtset pid_id panel_wave
xtdescribe

*------------PC.2: Verify gap patterns (general)
bys pid_id: gen n_waves = _N
bys pid_id: egen first_wave = min(panel_wave)
bys pid_id: egen last_wave  = max(panel_wave)
gen panel_pattern = .
replace panel_pattern = 1 if n_waves==3
replace panel_pattern = 2 if n_waves==2 & first_wave==1 & last_wave==2
replace panel_pattern = 3 if n_waves==2 & first_wave==2 & last_wave==3
replace panel_pattern = 4 if n_waves==2 & first_wave==1 & last_wave==3
replace panel_pattern = 5 if n_waves==1 & panel_wave==1
replace panel_pattern = 6 if n_waves==1 & panel_wave==2
replace panel_pattern = 7 if n_waves==1 & panel_wave==3
label define patt 1 "111 (all waves)" 2 "11. (waves 1-2)" ///
3 ".11 (waves 2-3)" 4 "1.1 (gap)" 5 "1.. (wave 1 only)" ///
6 ".1. (wave 2 only)" 7 "..1 (wave 3 only)"
label values panel_pattern patt
egen tag = tag(pid_id)
tab panel_pattern if tag

*------------PC.2: Verify gap patterns per variable
foreach var in risk_aversion_w2 risk_aversion_w3 avgrisk_hh_lott ///
risksd_hh_lott ind_risk_gap riskmax_hh riskmin_hh riskrange_hh risk_hh_excl {
	gen w1 = panel_wave == 1 & !missing(`var')
    gen w2 = panel_wave == 2 & !missing(`var')
    gen w3 = panel_wave == 3 & !missing(`var')
    bys pid_id: egen has1 = max(w1)
    bys pid_id: egen has2 = max(w2)
    bys pid_id: egen has3 = max(w3)
    gen p_`var' = string(has1) + string(has2) + string(has3)
    drop w1 w2 w3 has1 has2 has3
}


foreach var in risk_aversion_w2 risk_aversion_w3 avgrisk_hh_lott ///
risksd_hh_lott ind_risk_gap riskmax_hh riskmin_hh riskrange_hh risk_hh_excl {
    tab p_`var' if tag==1
}
drop p_*

*------------PC.3: Continue checking panel characteristics
xtsum
*Note: Verify that there is not within variation for static variables (i.e ids)
tab n_waves
tab panel_wave
isid pid_id panel_wave
misstable summarize

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                  Post-append: Check household changes and origin
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

*------------HHC1: Count number of unique households (folios) per individual
bysort pid_id folio: gen tag_folio = (_n == 1)
bysort pid_id: egen n_folios = total(tag_folio)

*------------HHC2: Create dummy of whether the individual changed
gen changed_house = (n_folios > 1)
label variable n_folios "Number of unique households (folios) across panel"
label variable changed_house "Individual changed household (folio) across panel"
label define yesno 0 "No" 1 "Yes", replace
label values changed_house yesno
drop tag_folio

*------------HHC3: Create indicator of wave of origin
gen household_origin = substr(pid_link, 7, 1)
gen household_origin_wave = .

replace household_origin_wave = 1 if household_origin == "A"
replace household_origin_wave = 2 if household_origin == "B"
replace household_origin_wave = 3 if household_origin == "C"
replace household_origin_wave = 1 if pid_link==""
/*replace household_origin_wave = 2 if household_origin_wave==. & panel_wave==2
*/

label variable household_origin_wave ///
"Wave in which household was first interviewed/formed"
label define hhorigin 1 "Wave 1 (2002): Original panel household" ///
2 "Wave 2 (2005-06): Split-off household" ///
3 "Wave 3 (2009-12): Split-off household"
label values household_origin_wave hhorigin
drop household_origin

save "${paneldata}\CONTROL1.Risk_aversion_panel.dta", replace

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                  Post-append: Last validation rules for panel merging
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

clear all
global paneldata "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.3 Panel data"
global finaldata "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
use "${paneldata}\CONTROL1.Risk_aversion_panel.dta", clear

*------------VR1: Create frames to do operations on multiple datasets
frame create wave2
frame create wave3

frame wave2: {
    use "${finaldata}\CONTROL1.Risk_aversion_w2_fin.dta", clear
    keep pidlink_clean folio
    duplicates drop
}

frame wave3: {
    use "${finaldata}\CONTROL1.Risk_aversion_w3_fin.dta", clear
    keep pidlink_clean folio
    duplicates drop
}

*------------VR2: Link the person id
frlink m:1 pidlink_clean, frame(wave2) gen(link_w2)
frlink m:1 pidlink_clean, frame(wave3) gen(link_w3)

*------------VR3: Create person level validation variable
gen person_w2 = (link_w2 < .)
gen person_w3 = (link_w3 < .)
label define yesno 0 "No" 1 "Yes", replace
label values person_w2 yesno
label values person_w3 yesno
label var person_w2 "Person exists in Wave 2 dataset"
label var person_w3 "Person exists in Wave 3 dataset"

save "${paneldata}\CONTROL1.Risk_aversion_panel.dta", replace

