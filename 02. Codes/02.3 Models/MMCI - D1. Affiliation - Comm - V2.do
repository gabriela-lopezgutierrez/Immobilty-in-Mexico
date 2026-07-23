/*==============================================================================
                   MMCI - Cleaning community level variables                  
==============================================================================*/
/*

Project:               (Im)mobility in Mexico
Database:              Mexico Life Survey - Wave 1, 2 and 3
Level:                 Community databases
Book:                  Community characteristics
Subsection:            Social attendance section (AS)
Dofile author:         Gabriela Judith López Gutiérrez
Creation date:         July 2026 /10
Modification date:     June 2026 /20
Product 1:             Produce MMCI Dimension 1. Variable 2 - Coope arrangements
Nussbaum 10:           
Dimension (study):
Variable:              Cooperative arrangements
Flow:                  1. Merge database with cover data
                       2. Keep only relevant variables
					   3. Value labels and generate variables
					   4. Repeat per wave
					   5. Create panel
Changes per wave:      
Note:                  
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

                     Variable 2: Cooperative arrangements (AS)
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

/*==============================================================================
 0.General setup / Work environment (Wave 1) and merging                               
==============================================================================*/

set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave I\Community\Community - loc02dta_bcc"

*------------1.1: Merge with cover data at community level
use "${rawdata}\loc_portad"
merge 1:1 folio using "${rawdata}/loc_as1", generate(_merge_1)
drop as01- as024_1 as06- _merge_1

/*==============================================================================
 2.Add label variables - Affiliation - community level (wave 1) 
==============================================================================*/

*------------2.1: Yesno label
label define yesno2 0"No" 1"Yes"

*Note: You could save the dataset here

/*==============================================================================
* 3. Generate variables - Affiliation - community level (wave 1)               *
==============================================================================*/

*------------3.1: Var 2 - Indicator 1: Number of cooperatives
gen D1_V2_I1_cooperative=.
replace D1_V2_I1_cooperative=1 if as03==1 
replace D1_V2_I1_cooperative=0 if as03==3 
label values D1_V2_I1_cooperative yesno2
label variable D1_V2_I1_cooperative "D1_V2_I1. The community has cooperatives"

*------------3.1: Var 2 - Indicator 2: Govt support cooperatives
gen D1_V2_I2_govtsupcoop=.
replace D1_V2_I2_govtsupcoop=0 if as05_2==0 | as05_2==.
replace D1_V2_I2_govtsupcoop=1 if as05_2>0 & as05_2!=.
label values D1_V2_I2_govtsupcoop yesno2
label variable D1_V2_I2_govtsupcoop "D1_V2_I2. The goverment gives support to cooperatives"

/*==============================================================================
* 4. Save final version - Affiliation - community level (wave 1)               *
==============================================================================*/

*------------4.1: Seva unmerged dataset at community level
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
drop libro semlev as03 as05_1 as05_2 as_mismo 

gen panel_wave=1
label var panel_wave "Panel wave from MxFLS"
order panel_wave, b( folio)
save "${finaldata}\MMCI_D1.Affiliation_comm_v2_w1_fin.dta", replace




/*==============================================================================
                           WAVE 2 (PERIOD T)
==============================================================================*/

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                     Variable 2: Cooperative arrangements (AS)
						   
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
use "${rawdata}\loc_as1"
drop as01 as06- as024_1
egen nn_communities = tag(folio)
count if nn_communities

*------------1.1: Consolidate V2_I1
**Note: Given that community surveys now have official and unofficial
**we must consolidate the data following some assumptions
gen coop_aux=1 if as03==1
replace coop_aux=0 if as03==3
bysort folio: egen cooperatives = max(coop_aux)
drop coop_aux
drop nn_communities

*------------1.2: Consolidate V2_I
gen subcoop_aux=1 if as05_2>0 & as05_2!=.
replace subcoop_aux=0 if subcoop_aux==.
bysort folio: egen support_coop = max(subcoop_aux)

*------------1.3: Keep only one row per community
bysort folio : keep if _n == 1

*------------1.4: Yes no label
label define yesno2 1"Yes" 0"No"

/*==============================================================================
* 2. Generate variables - Affiliation - community level (wave 2)               *
==============================================================================*/

*------------3.1: Indicator 1 - Var 1: Meeting organization
gen D1_V2_I1_cooperative=cooperatives
label values D1_V2_I1_cooperative yesno2
drop cooperatives
label variable D1_V2_I1_cooperative "D1_V2_I1. The community has cooperatives"

*------------3.1: Var 2 - Indicator 2: Govt support cooperatives
gen D1_V2_I2_govtsupcoop=support_coop
label values D1_V2_I2_govtsupcoop yesno2
label variable D1_V2_I2_govtsupcoop "D1_V2_I2. The goverment gives support to cooperatives"
drop subcoop_aux support_coop

save "${rawdata}\MMCI_D1.Affiliation_comm_v2_w2_auxiliar.dta", replace


/*==============================================================================
 3. Merge with cover data (Wave 2 - Affiliation - community level)
==============================================================================*/

*------------3.1: Prepare cover data for merging
use "${rawdata}\loc_portad.dta", replace
bysort folio : keep if _n == 1
destring id_loc, replace float

*------------3.2: Merge
merge 1:1 folio using "${rawdata}/MMCI_D1.Affiliation_comm_v2_w2_auxiliar.dta", generate(_merge_1)

/*==============================================================================
* 4. Save final version - Affiliation - community level (wave 2)               *
==============================================================================*/

*------------4.1: Seva unmerged dataset at community level
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
drop libro resent semlev tipo _merge_1 as_mismo as03 as05_1 as05_2 _merge_1 
gen panel_wave=2
label var panel_wave "Panel wave from MxFLS"
order panel_wave, b( folio)
destring id_loc, replace float
save "${finaldata}\MMCI_D1.Affiliation_comm_v2_w2_fin.dta", replace




/*==============================================================================
                           WAVE 3 (PERIOD T-1)
==============================================================================*/

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                     Variable 2: Cooperative arrangements (AS)
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

/*==============================================================================
 0.General setup / Work environment (Wave 1) and merging                               
==============================================================================*/

set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave III\Community\Community - eeloc09dta_bcc1"


*------------1.1: Merge with cover data at community level
use "${rawdata}\loc_portad"
merge 1:1 folio using "${rawdata}/loc_as1", generate(_merge_1)
drop resent _merge_1 _merge_1 _merge_1

/*==============================================================================
 2.Add label variables - Affiliation - community level (wave 3) 
==============================================================================*/

*------------2.1: Yesno label
label define yesno2 0"No" 1"Yes"

*Note: You could save the dataset here

*------------2.2: Convert all keys to float
foreach var of varlist id_loc l_ent l_mun ug_ent ug_mun {
    destring `var', replace float
}

/*==============================================================================
* 3. Generate variables - Affiliation - community level (wave 1)               *
==============================================================================*/

*------------3.1: Var 2 - Indicator 1: Number of cooperatives
gen D1_V2_I1_cooperative=.
replace D1_V2_I1_cooperative=1 if as03==1 
replace D1_V2_I1_cooperative=0 if as03==3 
label values D1_V2_I1_cooperative yesno2
label variable D1_V2_I1_cooperative "D1_V2_I1. The community has cooperatives"

*------------3.1: Var 2 - Indicator 2: Govt support cooperatives
gen D1_V2_I2_govtsupcoop=.
replace D1_V2_I2_govtsupcoop=0 if as05_2==0 | as05_2==.
replace D1_V2_I2_govtsupcoop=1 if as05_2>0 & as05_2!=.
label values D1_V2_I2_govtsupcoop yesno2
label variable D1_V2_I2_govtsupcoop "D1_V2_I2. The goverment gives support to cooperatives"

/*==============================================================================
* 4. Save final version - Affiliation - community level (wave 1)               *
==============================================================================*/

*------------4.1: Seva unmerged dataset at community level
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
drop as03 as05_1 as05_2

gen panel_wave=3
label var panel_wave "Panel wave from MxFLS"
order panel_wave, b( folio)
replace D1_V2_I2_govtsupcoop=. if D1_V2_I1_cooperative==.
save "${finaldata}\MMCI_D1.Affiliation_comm_v2_w3_fin.dta", replace


/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                     Panel merge (MxFLS 1 / MxFLS 2 / MxFLS 3)
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

*------------P.1: Append panels

use"${finaldata}\MMCI_D1.Affiliation_comm_v2_w1_fin.dta", replace
append using "${finaldata}\MMCI_D1.Affiliation_comm_v2_w2_fin.dta"
append using "${finaldata}\MMCI_D1.Affiliation_comm_v2_w3_fin.dta"
sort folio panel_wave
global paneldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.3 Panel data"
save "${paneldata}\MMCI_D1.Affiliation_comm_v2_panel.dta", replace


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

merge 1:m l_ent using "${paneldata}\MMCI_D1.Affiliation_comm_v2_panel.dta", ///
generate(_merge_1)
drop if _merge_1==1
drop if _merge_1==2
sort l_ent

sort folio panel_wave
drop _merge_1
save "${paneldata}\MMCI_D1.Affiliation_comm_v2_panel.dta", replace