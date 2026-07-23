/*==============================================================================
                   MMCI - Cleaning community level variables                  
==============================================================================*/
/*

Project:               (Im)mobility in Mexico
Database:              Mexico Life Survey - Wave 1, 2 and 3
Level:                 Community databases
Book:                  Community characteristics
Subsection:            CM - Migrants clubs
Dofile author:         Gabriela Judith López Gutiérrez
Creation date:         July 2026 /10
Modification date:     June 2026 /20
Product 1:             
Nussbaum 10:           
Dimension (study):     Destination social capital
Variable:              Collective information and active collective support
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

      Variable 1 & 2: Collective information and active collective support
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

/*==============================================================================
 0.General setup / Work environment (Wave 1) and merging                               
==============================================================================*/

set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave I\Community\Community - loc02dta_bcc"

/*==============================================================================
 1.Labels and renaming                       
==============================================================================*/

*-----------1.1 Import and keep relevant data
use "${rawdata}\loc_cm2"
keep folio secuencia cm02

*-----------1.2 Contact with MC information proxy (D3_V1_I1)
replace cm02=1 if cm02==1
replace cm02=0 if cm02==3
replace cm02=. if cm02==8
label define yesno 1"Yes" 0"No"
label values cm02 yesno
label var cm02 "D3_V1_I1: Does the community inhabitants have contact with any migrant clubs or associations located in"
rename cm02 D3_V1_I1_collinfomg
bysort folio: egen any_yes = max(D3_V1_I1_collinfomg)
label values any_yes yesno
replace D3_V1_I1_collinfomg=any_yes
label values D3_V1_I1_collinfomg yesno
drop any_yes
bysort folio (secuencia): keep if _n == 1
save "${rawdata}\temporary_mg", replace

/*==============================================================================
* 2.Merging with cover data                                                    *
==============================================================================*/

*------------1.1: Merge with cover data at community level
use "${rawdata}\loc_portad"
merge 1:1 folio using "${rawdata}/temporary_mg", generate(_merge_1)


/*==============================================================================
* 4. Save final version - (wave 1)                                            *
==============================================================================*/

*------------4.1: Save unmerged dataset at community level
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
drop libro semlev secuencia

gen panel_wave=1
label var panel_wave "Panel wave from MxFLS"
order panel_wave, b( folio)
save "${finaldata}\MMCI_D3.Socialcap_comm_v1_w1_fin.dta", replace




/*==============================================================================
                           WAVE 2 (PERIOD T)
==============================================================================*/

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

      Variable 1 & 2: Collective information and active collective support
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

/*==============================================================================
 0.General setup / Work environment (Wave 1) and merging                               
==============================================================================*/

set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave II\Community\Community - loc05dta_bcc"

/*==============================================================================
 1.Labels and renaming                       
==============================================================================*/

*-----------1.1 Import and keep relevant data
use "${rawdata}\loc_cm2"
keep folio secuencia cm02

*-----------1.2 Contact with MC information proxy (D3_V1_I1)
replace cm02=1 if cm02==1
replace cm02=0 if cm02==3
replace cm02=. if cm02==8
label define yesno 1"Yes" 0"No"
label values cm02 yesno
label var cm02 "D3_V1_I1: Does the community inhabitants have contact with any migrant clubs or associations located in"
rename cm02 D3_V1_I1_collinfomg
bysort folio: egen any_yes = max(D3_V1_I1_collinfomg)
label values any_yes yesno
replace D3_V1_I1_collinfomg=any_yes
label values D3_V1_I1_collinfomg yesno
drop any_yes
bysort folio (secuencia): keep if _n == 1
save "${rawdata}\temporary_mg", replace

/*==============================================================================
* 2.Merging with cover data                                                    *
==============================================================================*/

*------------2.1: Prepare cover data for merging
use "${rawdata}\loc_portad.dta", replace
bysort folio : keep if _n == 1
destring id_loc, replace float

*------------2.2: Merge with cover data at community level
merge 1:1 folio using "${rawdata}/temporary_mg", generate(_merge_1)


/*==============================================================================
* 3. Save final version - (wave 2)               *
==============================================================================*/

*------------3.1: Save unmerged dataset at community level
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
drop libro semlev secuencia resent tipo

gen panel_wave=2
label var panel_wave "Panel wave from MxFLS"
order panel_wave, b( folio)
save "${finaldata}\MMCI_D3.Socialcap_comm_v1_w2_fin.dta", replace


/*==============================================================================
                           WAVE 3 (PERIOD T+1)
==============================================================================*/

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

      Variable 1 & 2: Collective information and active collective support
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

/*==============================================================================
 0.General setup / Work environment (Wave 1) and merging                               
==============================================================================*/

set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave III\Community\Community - eeloc09dta_bcc1"

/*==============================================================================
 1.Labels and renaming                       
==============================================================================*/

*-----------1.1 Import and keep relevant data
use "${rawdata}\loc_cm2"
keep folio secuencia cm02

*-----------1.2 Contact with MC information proxy (D3_V1_I1)
replace cm02=1 if cm02==1
replace cm02=0 if cm02==3
replace cm02=. if cm02==8
label define yesno 1"Yes" 0"No"
label values cm02 yesno
label var cm02 "D3_V1_I1: Does the community inhabitants have contact with any migrant clubs or associations located in"
rename cm02 D3_V1_I1_collinfomg
bysort folio: egen any_yes = max(D3_V1_I1_collinfomg)
label values any_yes yesno
replace D3_V1_I1_collinfomg=any_yes
label values D3_V1_I1_collinfomg yesno
drop any_yes
bysort folio (secuencia): keep if _n == 1
save "${rawdata}\temporary_mg", replace

/*==============================================================================
* 2.Merging with cover data                                                    *
==============================================================================*/

*------------2.1: Merge with cover data at community level
use "${rawdata}\loc_portad"
merge 1:1 folio using "${rawdata}/temporary_mg", generate(_merge_1)

*------------2.2: Convert all keys to float
foreach var of varlist id_loc l_ent l_mun ug_ent ug_mun {
    destring `var', replace float
}

/*==============================================================================
* 4. Save final version - (wave 1)                                            *
==============================================================================*/

*------------4.1: Save unmerged dataset at community level
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
drop resent secuencia

gen panel_wave=3
label var panel_wave "Panel wave from MxFLS"
order panel_wave, b( folio)
save "${finaldata}\MMCI_D3.Socialcap_comm_v1_w3_fin.dta", replace

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                     Panel merge (MxFLS 1 / MxFLS 2 / MxFLS 3)
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

*------------P.1: Append panels

use"${finaldata}\MMCI_D3.Socialcap_comm_v1_w1_fin.dta", replace
append using "${finaldata}\MMCI_D3.Socialcap_comm_v1_w2_fin.dta"
append using "${finaldata}\MMCI_D3.Socialcap_comm_v1_w3_fin.dta"
sort folio panel_wave
drop _merge_1
global paneldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.3 Panel data"
save "${paneldata}\MMCI_D3.Socialcap_comm_v1_panel.dta", replace


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

merge 1:m l_ent using "${paneldata}\MMCI_D3.Socialcap_comm_v1_panel.dta", ///
generate(_merge_1)
drop if _merge_1==1
drop if _merge_1==2
sort l_ent

sort folio panel_wave
drop _merge_1

save "${paneldata}\MMCI_D3.Socialcap_comm_v1_panel.dta", replace