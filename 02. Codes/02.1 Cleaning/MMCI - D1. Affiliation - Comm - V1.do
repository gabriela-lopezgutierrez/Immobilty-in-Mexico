/*==============================================================================
                   MMCI - Cleaning community level variables                    
==============================================================================*/
/*

Project:               (Im)mobility in Mexico
Database:              Mexico Life Survey - Wave 1, 2 and 3
Level:                 Community databases
Book:                  Community characteristics
Subsection:            AC - Community activities
Dofile author:         Gabriela Judith López Gutiérrez
Creation date:         July 2026 /10
Modification date:     June 2026 /20
Product 1:             Produce MMCI Dimension 1. Variable 1
Nussbaum 10:           Affiliation
Dimension (study):
Variable:              Community meetings
Flow:                  1. Merge database with cover data
                          1.1. Prepare cover for merging
						  1.2. Prepare your data for merging
						  1.3. Merge them
                       2. Keep only relevant variables
					   3. Value labels and generate variables
					   4. Merge with household level data
					      1.1. Prepare hh cover for merging
						  1.2. Clean raster hh dataset for merging
						  1.3. Merge the two hh datasets
						  1.4. Merge with community final dataset
					   Note: Repeat for each wave, as needed
Changes per wave:      In wave II/III, there is two observations per locality
Note:                  The flow changes for wave II and III, we first clean and consolidate
				

*/

/*==============================================================================
                           WAVE 1 (PERIOD T-1)
==============================================================================*/

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                     Variable 1: Community meetings (AC)
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

/*==============================================================================
 0.General setup / Work environment (Wave 1) and merging                               
==============================================================================*/

set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave I\Community\Community - loc02dta_bcc"

*------------1.1: Merge with cover data at community level
use "${rawdata}\loc_portad"
merge 1:1 folio using "${rawdata}/loc_ac", generate(_merge_1)

/*==============================================================================
 2.Add label variables - Affiliation - community level (wave 1) 
==============================================================================*/

*------------2.1: Meeting organization
label define yesno 1"Yes" 3"No"
label values ac01 yesno

*------------2.2: Type reported
label define type_report 1"Number participation" 2"Percentage participation" ///
8"Don't know"
label values ac03_1 type_report

*Note: You could save the dataset here

/*==============================================================================
* 3. Generate variables - Affiliation - community level (wave 1)               *
==============================================================================*/

*------------3.1: Indicator 1 - Var 1: Meeting organization
gen D1_V1_I1_meetings=ac01
label values D1_V1_I1_meetings yesno
label variable D1_V1_I1_meetings "D1_V1_I1. The community organizes meetings"

------------3.2: Indicator 2 - Var 2: Percentage: population in meetings
gen D1_V1_I2_percpart=.
replace D1_V1_I2_percpart=1 if ac03_3>50 & ac03_3!=.
replace D1_V1_I2_percpart=0 if ac03_3<50
label define part_perc 1"Participation above 50%" 0"Participation below 50%"
label values D1_V1_I2_percpart part_perc
label variable D1_V1_I2_percpar "D1_V1_I2. Activate population attendance to community meetings"

*Note: this variable is incomplete

/*==============================================================================
* 4. Save final version - Affiliation - community level (wave 1)               *
==============================================================================*/

*------------4.1: Seva unmerged dataset at community level
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"

keep folio id_loc l_ent l_loc l_mun ug_ent ug_loc ug_mun ac_mismo ac01 ac02_2 ac03_1 ac03_2 ac03_3 D1_V1_I1_meetings D1_V1_I2_percpart _merge_1

save "${finaldata}\MMCI_D1.Affiliation_comm_v1_w1_fin.dta", replace

/*==============================================================================
* 5. Merge with hh level data (population)- Affiliation - community level (wave 1)               *
==============================================================================*/

*------------5.1: Merge the household datasets
set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave I\Household\hh02dta_bc - Book C (Control book) W1"

use "${rawdata}\c_ls"
tostring folio, gen(folio_str) format(%15.0f)
save "${rawdata}\population_auxiliary.dta", replace

use "${rawdata}\c_portad"
tostring folio, gen(folio_str) format(%15.0f)
** Note: 3 appear without folio id hh
drop if folio==.
merge m:m folio_str using "${rawdata}/population_auxiliary", generate(_merge_1)

** Note: not matched 13 from using

drop rel reh edo mpio loc control estrato edad secuencia ls02_1 ls02_2 ls03_1 ls03_21 ls03_22 ls04 ls05_1 ls06- _merge_1

global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
save "${finaldata}\population_auxiliary.dta", replace

*------------5.2: Merge with community dataset
merge m:1 id_loc using "${finaldata}\MMCI_D1.Affiliation_comm_v1_w1_fin.dta", generate(_merge_2)


/*==============================================================================
* 6. Complete indicator 2- Affiliation - community level (wave 1)               *
==============================================================================*/

*------------6.1: Keep mostly identification variables from hh dataset
drop ug_ent ug_loc ug_mun ls
drop _merge_1 _merge_2

*------------6.2: Generate population size and collapse
preserve

collapse (count) population=ls00 (first) folio folio_str l_ent l_loc l_mun ac_mismo ac01 ac02_2 ac03_1 ac03_2 ac03_3 D1_V1_I1_meetings D1_V1_I2_percpart , by(id_loc)

*------------6.3: Restore names of variables
label var folio "Household ID" 
label var folio_str"Household ID" 
label var id_loc "ID LOCALITY" 
label var population "Population per location" 
label var l_ent "LOCATION STATE" 
label var l_loc "LOCATION TOWN" 
label var l_mun "LOCATION MUNICIPALITY" 
label var ac_mismo "SAME RESPONDANT"
label var ac01 "ACTIVITIES/MEETINGS COMMUNITY" 
label var ac02_2 "#ACTIVITIES/ASSEMBLES" 
label var ac03_1 "INHABITANTS PARTICIPATE ACTIVITIES" 
label var ac03_2 "# INHABITANTS" 
label var ac03_3 "% OF INHABITANTS" 
label variable D1_V1_I1_meetings "D1_V1_I1. The community organizes meetings"
label variable D1_V1_I2_percpar "D1_V1_I2. Activate population attendance to community meetings"

*------------6.4: Restore value labels
label values ac01 yesno
label values ac03_1 type_report
label values D1_V1_I1_meetings yesno
label values D1_V1_I2_percpar part_perc

drop if id_loc==.

*------------6.5: Correct D1_V1_I2_percpar
replace ac03_3 = (ac03_2/population)*100 if ac03_1==1
replace ac03_3 = round((ac03_2/population)*100, 1) if ac03_1==1
replace D1_V1_I2_percpart=1 if ac03_3>50 & ac03_3!=.
replace D1_V1_I2_percpart=0 if ac03_3<50

gen panel_wave=1
save "${finaldata}\MMCI_D1.Affiliation_comm_v1_w1_fin.dta", replace


/*==============================================================================
                           WAVE 2 (PERIOD T)
==============================================================================*/

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                     Variable 1: Community meetings (AC)
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

/*==============================================================================
 0.General setup / Work environment (Wave 2) and merging                               
==============================================================================*/

set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave II\Community\Community - loc05dta_bcc"

/*==============================================================================
 2. Clean and add label variables - Affiliation - community level (wave 2) 
==============================================================================*/

*------------1.1: Consolidate V1_I1
**Note: Given that community surveys now have official and unofficial
**we must consolidate the data following some assumptions

use "${rawdata}\loc_ac"
keep folio tipo ac_mismo ac01 ac03_1 ac03_2 ac03_3

egen nn_communities = tag(folio)
*egen nn_localities = tag(id_loc)
count if nn_communities
*count if nn_localities
gen meeting_aux=1 if ac01==1
replace meeting_aux=0 if ac01==3
bysort folio: egen meeting_org = max(meeting_aux)
drop meeting_aux

*------------1.2: Consolidate V1_I2
**Note: Given that community surveys now have official and unofficial
**we must consolidate the data following some assumptions
bysort folio : egen ac03_2_cons = mean(ac03_2)
bysort folio : egen ac03_3_cons = mean(ac03_3)
replace ac03_2=ac03_2_cons
replace ac03_3=ac03_3_cons
drop ac03_2_cons ac03_3_cons
drop nn_communities meeting_org

*------------1.3: Keep only one row per community
bysort folio : keep if _n == 1

*------------1.4: Meeting organization
label define yesno 1"Yes" 3"No"
label values ac01 yesno

*------------1.5: Type reported
label define type_report 1"Number participation" 2"Percentage participation" ///
8"Don't know"
label values ac03_1 type_report

*Note: You could save the dataset here

merge m:m folio tipo using "${rawdata}/loc_portad", generate(_merge_1)

/*==============================================================================
* 3. Generate variables - Affiliation - community level (wave 2)               *
==============================================================================*/

*------------3.1: Indicator 1 - Var 1: Meeting organization
gen D1_V1_I1_meetings=ac01
label values D1_V1_I1_meetings yesno
label variable D1_V1_I1_meetings "D1_V1_I1. The community organizes meetings"

*------------3.2: Indicator 2 - Var 2: Percentage: population in meetings
gen D1_V1_I2_percpart=.
replace D1_V1_I2_percpart=1 if ac03_3>50 & ac03_3!=.
replace D1_V1_I2_percpart=0 if ac03_3<50
label define part_perc 1"Participation above 50%" 0"Participation below 50%"
label values D1_V1_I2_percpart part_perc
label variable D1_V1_I2_percpar "D1_V1_I2. Activate population attendance to community meetings"

*Note: this variable is incomplete

/*==============================================================================
* 4. Save final version - Affiliation - community level (wave 2)               *
==============================================================================*/

*------------4.1: Save unmerged dataset at community level
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"

save "${finaldata}\MMCI_D1.Affiliation_comm_v1_w2_fin.dta", replace

*------------4.2: Prepare cover data for merging
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave II\Community\Community - loc05dta_bcc"
use "${rawdata}\loc_portad"
*Note: it is okay to keep only the first observation because loc_id 
* does not change per respondant
bysort folio : keep if _n == 1

*------------4.3: Merge database with cover info
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
merge 1:1 folio using "${finaldata}/MMCI_D1.Affiliation_comm_v1_w2_fin.dta", generate(_merge_1)
*Note: merge is exact: 150 communities

save "${finaldata}\MMCI_D1.Affiliation_comm_v1_w2_fin.dta", replace

/*==============================================================================
* 5. Merge with hh level data (population)- Affiliation - community level (wave 2)               *
==============================================================================*/

*------------5.1: Merge the household datasets
set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave II\Household\hh05dta_bc - Book C (Control book) W2"

use "${rawdata}\c_ls"
keep folio ls ls00 ls00i ls01a ls01b ls01c ls19c ls19d ls19e_1 panel pid_link
tostring folio, gen(folio_str) format(%15.0f)
save "${rawdata}\population_auxiliary.dta", replace

use "${rawdata}\c_portad"
tostring folio, gen(folio_str) format(%15.0f)
gen folio_str=folio
merge m:m folio using "${rawdata}/population_auxiliary", generate(_merge_1)

** Note: not matched 13 from using

drop catorcena control edad ent estrato mpio reh rel ls01a ls01b ls01c ls19c ls19d ls19e_1 _merge_1 loc

global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
save "${finaldata}\population_auxiliary.dta", replace

*------------5.2: Merge with community dataset
destring folio, replace
recast float folio
merge m:1 id_loc using "${finaldata}\MMCI_D1.Affiliation_comm_v1_w2_fin.dta", generate(_merge_2)

/*==============================================================================
* 6. Complete indicator 2- Affiliation - community level (wave 2)               *
==============================================================================*/

*------------6.1: Keep mostly identification variables from hh dataset
drop ug_ent ug_loc ug_mun ls
drop _merge_1 _merge_2

*------------6.2: Generate population size and collapse
sort id_loc folio ls00
drop ls00i panel pid_link libro resent semlev
preserve
destring ls00, replace float
collapse (count) population=ls00 (first) folio folio_str l_ent l_loc l_mun ac_mismo ac01 ac02_2 ac03_1 ac03_2 ac03_3 D1_V1_I1_meetings D1_V1_I2_percpart , by(id_loc)

*------------6.3: Restore names of variables
label var folio "Household ID" 
label var folio_str"Household ID" 
label var id_loc "ID LOCALITY" 
label var population "Population per location" 
label var l_ent "LOCATION STATE" 
label var l_loc "LOCATION TOWN" 
label var l_mun "LOCATION MUNICIPALITY" 
label var ac_mismo "SAME RESPONDANT"
label var ac01 "ACTIVITIES/MEETINGS COMMUNITY" 
label var ac03_1 "INHABITANTS PARTICIPATE ACTIVITIES" 
label var ac03_2 "# INHABITANTS" 
label var ac03_3 "% OF INHABITANTS" 
label variable D1_V1_I1_meetings "D1_V1_I1. The community organizes meetings"
label variable D1_V1_I2_percpar "D1_V1_I2. Activate population attendance to community meetings"

*------------6.4: Restore value labels
label values ac01 yesno
label values ac03_1 type_report
label values D1_V1_I1_meetings yesno
label values D1_V1_I2_percpar part_perc

drop if id_loc==.

*------------6.5: Correct D1_V1_I2_percpar
replace ac03_3 = (ac03_2/population)*100 if ac03_1==1
replace ac03_3 = round((ac03_2/population)*100, 1) if ac03_1==1
replace D1_V1_I2_percpart=1 if ac03_3>50 & ac03_3!=.
replace D1_V1_I2_percpart=0 if ac03_3<50

gen panel_wave=2
use"${finaldata}\MMCI_D1.Affiliation_comm_v1_w2_fin.dta", replace

save "${finaldata}\MMCI_D1.Affiliation_comm_v1_w1_fin.dta", replace
gen panel_wave=1


/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                     Panel merge (MxFLS 1 / MxFLS 2)
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/
use"${finaldata}\MMCI_D1.Affiliation_comm_v1_w2_fin.dta", replace
drop folio_str tipo ac01 ac03_1 ac03_2 ac03_3 ac_mismo
destring id_loc, replace float

global paneldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.3 Panel data"
save "${paneldata}\MMCI_D1.Affiliation_comm_v1_w2_panelaux.dta", replace

use"${finaldata}\MMCI_D1.Affiliation_comm_v1_w1_fin.dta", replace
drop folio_str ac_mismo ac01 ac02_2 ac03_1 ac03_2 ac03_3

global paneldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.3 Panel data"
save "${paneldata}\MMCI_D1.Affiliation_comm_v1_w1_panelaux.dta", replace

append using "${paneldata}\MMCI_D1.Affiliation_comm_v1_w2_panelaux.dta"

save "${paneldata}\MMCI_D1.Affiliation_comm_v1_panel.dta", replace