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
                       2. Keep only relevant variables
					   3. Value labels and generate variables
					   4. Repeat per wave
					   5. Create panel
Changes per wave:      In wave II, there is two observations per locality
Note:                  The flow changes for wave II, we first clean and consolidate
Keys community:        communitary id joins cover data with community data
Keys hh level:         HH id joins cover data with hh level data
Keys two levels:       Locality id joins community with hh-level data
Note:                  You need to keep all keys (portad and specific database)
Note:                  All labels must have the same values across waves
				
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

*Note: You could save the dataset here

/*==============================================================================
* 3. Generate variables - Affiliation - community level (wave 1)               *
==============================================================================*/

*------------3.1: Indicator 1 - Var 1: Meeting organization
gen D1_V1_I1_meetings=.
replace D1_V1_I1_meetings=1 if ac01==1
replace D1_V1_I1_meetings=0 if ac01==3
label define yesno2 1"Yes" 0"No"
label values D1_V1_I1_meetings yesno2
label variable D1_V1_I1_meetings "D1_V1_I1. The community organizes meetings"


/*==============================================================================
* 4. Save final version - Affiliation - community level (wave 1)               *
==============================================================================*/

*------------4.1: Seva unmerged dataset at community level
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
drop ac01-_merge_1 libro semlev

gen panel_wave=1
label var panel_wave "Panel wave from MxFLS"
order panel_wave, b( folio)
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
 1. Clean and add label variables - Affiliation - community level (wave 2) 
==============================================================================*/

*------------1.1: Consolidate V1_I1
**Note: Given that community surveys now have official and unofficial
**we must consolidate the data following some assumptions

use "${rawdata}\loc_ac"

egen nn_communities = tag(folio)
*egen nn_localities = tag(id_loc)
count if nn_communities
*count if nn_localities
gen meeting_aux=1 if ac01==1
replace meeting_aux=0 if ac01==3
bysort folio: egen meeting_org = max(meeting_aux)
drop meeting_aux

drop ac01- ac05_5b2

*------------1.3: Keep only one row per community
bysort folio : keep if _n == 1

*------------1.4: Meeting organization
label define yesno2 1"Yes" 0"No"
label values meeting_org yesno2

/*==============================================================================
* 2. Generate variables - Affiliation - community level (wave 2)               *
==============================================================================*/

*------------3.1: Indicator 1 - Var 1: Meeting organization
gen D1_V1_I1_meetings=meeting_org
label values D1_V1_I1_meetings yesno2
drop nn_communities meeting_org
label variable D1_V1_I1_meetings "D1_V1_I1. The community organizes meetings"

save "${rawdata}\MMCI_D1.Affiliation_comm_v1_w2_auxiliar.dta", replace


/*==============================================================================
 3. Merge with cover data (Wave 2 - Affiliation - community level)
==============================================================================*/

*------------3.1: Prepare cover data for merging
use "${rawdata}\loc_portad.dta", replace
bysort folio : keep if _n == 1

*------------3.2: Merge
merge 1:1 folio using "${rawdata}/MMCI_D1.Affiliation_comm_v1_w2_auxiliar.dta", generate(_merge_1)


/*==============================================================================
* 4. Save final version - Affiliation - community level (wave 2)               *
==============================================================================*/

*------------4.1: Seva unmerged dataset at community level
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
drop libro resent semlev tipo _merge_1
gen panel_wave=2
label var panel_wave "Panel wave from MxFLS"
order panel_wave, b( folio)
destring id_loc, replace float
save "${finaldata}\MMCI_D1.Affiliation_comm_v1_w2_fin.dta", replace



/*==============================================================================
                           WAVE 3 (PERIOD T+1)
==============================================================================*/

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                     Variable 1: Community meetings (AC)
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

/*==============================================================================
 0.General setup / Work environment (Wave 3) and merging                               
==============================================================================*/

set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave III\Community\Community - eeloc09dta_bcc1"

*------------1.1: Merge with cover data at community level
use "${rawdata}\loc_portad"
merge 1:1 folio using "${rawdata}/loc_ac", generate(_merge_1)

/*==============================================================================
 2.Add label variables - Affiliation - community level (wave 3) 
==============================================================================*/

*------------2.1: Meeting organization
label define yesno 1"Yes" 3"No"
label values ac01 yesno

*Note: You could save the dataset here

*------------2.2: Convert all keys to float
foreach var of varlist id_loc l_ent l_mun ug_ent ug_mun {
    destring `var', replace float
}

/*==============================================================================
* 3. Generate variables - Affiliation - community level (wave 3)               *
==============================================================================*/

*------------3.1: Indicator 1 - Var 1: Meeting organization
gen D1_V1_I1_meetings=.
replace D1_V1_I1_meetings=1 if ac01==1
replace D1_V1_I1_meetings=0 if ac01==3
label define yesno2 1"Yes" 0"No"
label values D1_V1_I1_meetings yesno2
label variable D1_V1_I1_meetings "D1_V1_I1. The community organizes meetings"

/*==============================================================================
* 4. Save final version - Affiliation - community level (wave 3)               *
==============================================================================*/

*------------4.1: Seva unmerged dataset at community level
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
drop ac01-_merge_1 resent 

gen panel_wave=3
label var panel_wave "Panel wave from MxFLS"
order panel_wave, b( folio)
gen ac_mismo=.
save "${finaldata}\MMCI_D1.Affiliation_comm_v1_w3_fin.dta", replace



/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                     Panel merge (MxFLS 1 / MxFLS 2 / MxFLS 3)
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

*------------P.1: Append panels

use"${finaldata}\MMCI_D1.Affiliation_comm_v1_w1_fin.dta", replace
append using "${finaldata}\MMCI_D1.Affiliation_comm_v1_w2_fin.dta"
append using "${finaldata}\MMCI_D1.Affiliation_comm_v1_w3_fin.dta"
sort folio panel_wave
global paneldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.3 Panel data"
save "${paneldata}\MMCI_D1.Affiliation_comm_v1_panel.dta", replace

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                     Check panel characteristics
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

global paneldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.3 Panel data"

*------------P.2: Verify panel characteristics

xtset folio panel_wave
xtdescribe
xtsum
*Note: Verify that there is not within variation for static variables (i.e ids)
bys folio: gen n_waves = _N
tab n_waves
tab panel_wave
isid folio panel_wave
misstable summarize

*------------P.3: Generate some additional variables
gen year = .
replace year = 2002 if panel_wave == 1
replace year = 2005 if panel_wave == 2
replace year = 2009 if panel_wave == 3
order year, a(panel_wave)
label var year "Survey year per wave"

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                     Merge INEGI codes (State level)
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/
*------------I.1: Merge INEGI codes (States)

import excel "${paneldata}/INEGI_STATECODES.xlsx", firstrow clear
drop CVEGEO NOM_ABR POB_TOTAL POB_MASCULINA POB_FEMENINA ///
TOTALDEVIVIENDASHABITADAS
rename CVE_ENT l_ent
label var l_ent "INEGI state code"
rename NOM_ENT state_name
label var state_name "INEGI state name"

merge 1:m l_ent using "${paneldata}\MMCI_D1.Affiliation_comm_v1_panel.dta", ///
generate(_merge_1)
drop if _merge_1==1
drop if _merge_1==2
sort l_ent

sort folio panel_wave
drop _merge_1
save "${paneldata}\MMCI_D1.Affiliation_comm_v1_panel.dta", replace
