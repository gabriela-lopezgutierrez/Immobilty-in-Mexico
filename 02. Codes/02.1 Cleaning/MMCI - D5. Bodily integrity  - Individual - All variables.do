/*==============================================================================
                   MMCI - Cleaning individual level variables                  
==============================================================================*/
/*

Project:               (Im)mobility in Mexico
Database:              Mexico Life Survey - Wave 1, 2 and 3
Level:                 Individual databases
Book:                  Book IIIB - Characteristics of Adult Household Members
                    
Subsection:            VLI - Individual Crime and Victimization
Dofile author:         Gabriela Judith López Gutiérrez
Creation date:         July 2026 /10
Modification date:     June 2026 /20
Product 1:             Produce MMCI Dimension 5. Individual variables
Nussbaum 10:           Bodily integrity
Dimension (study):
Variable:              Perceived risk and response to perceived risk
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
Note:                  Folio needs to be turn into string first
Note:                  (line 123) Keep track of type of book the data comes from
Note:                  Duplicate report and handling section varies by wave
Note:                  In wave 2 and 3 you keep pid_link (id 2002)
Note:                  Now for every merge do a post validation check with frames
Note:                  Variable on recent assault for wave 3 will have to be
Note:                  completed in the panel
*/


/*==============================================================================
                     WAVE 1 (PERIOD T-1) - REGULAR BOOK
==============================================================================*/

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

             Variables: Individual variables of security / crime
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

/*==============================================================================
 0.General setup / Work environment (Wave 1) and merging                               
==============================================================================*/

set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave I\Individual\hh02dta_b3a - Wave 1"

*------------1.1: Prepare database VLI to merge (with individual datasets)
use "${rawdata}\iiia_vli"
tostring folio, gen(folio_str) format(%15.0f)
tostring ls, gen(ls_str)
gen individual_id = folio_str + "_" + ls_str
rename ls ls_individual
rename ls_str ls_str_individual
save "${rawdata}\individualvict_aux", replace

*------------1.2: Merge with cover data at household level (creating bridge)
* Note: Bridge to merge with community data through loc_id
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave I\Household\hh02dta_bc - Book C (Control book) W1"
use "${rawdata}\c_portad"
tostring folio, gen(folio_str) format(%15.0f)
tostring ls, gen(ls_str)
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave I\Individual\hh02dta_b3a - Wave 1"
drop if folio==.
duplicates report folio_str
duplicates list folio_str
drop if folio==8486000 & ls==7
save "${rawdata}\cbportad_aux", replace

merge 1:m folio_str using "${rawdata}\individualvict_aux", generate(_merge_1)
drop if _merge_1==1


*------------1.3: Keep only relevant data
keep folio folio_str ls ls_str edo mpio loc edad id_loc vli01 vli02 vli03 vli04 vli05 vli26_1 vli26_21 vli26_22 vli27 vli28 vli29 vli30 vli31 vli32 vli33_1a individual_id _merge_1 ls_str_individual ls_individual
drop vli26_21 vli26_22

/*==============================================================================
 2.Add label / rename variables - Individual victimization (wave 1) 
==============================================================================*/

*------------2.1: Label scared attack
label define lbl_scared 1"Very scared" 2"Scared" 3"A little scared" ///
4 "Do not feel scared"

*------------2.2 Label and rename variables scared night and day
label values vli01 lbl_scared
label values vli02 lbl_scared
label var vli01 "D5_V1_I1. Do you feel (...) of being attacked or assaulted during the day?" 
rename vli01 D5_V1_I1_worassault_day
label var vli02 "D5_V1_I2. Do you feel (...) of being attacked or assaulted during the night?" 
rename vli02 D5_V1_I2_worassault_night

*------------2.3 Create rest of labels
label define lbl_safety 1"Safer" 2"Safe" 3"Less safe"
label define lbl_assaultfuture 1"It is very probable that it could happen" ///
2"It is probable that it could happen" ///
3"It is a little probable that it could happen" ///
4"Do not think that it could happen"
label define yesno 1"Yes" 0"No"
label define lbl_police 1"Days a week" 2"Days a month" 3"Haven't seen"
label define lbl_freq 1"Very frequently" 2"Frequently" 3"A little frequently" ///
4"Not frequently"
label define lbl_comp 1"More than then" 2"The same as then" 3"Less than then"

*------------2.4 Label variables - safety past
label values vli03 lbl_safety
label var vli03 "D5_V1_I3. VL1.03 Compared to 5 years ago, do you feel (...)"
rename vli03 D5_V1_I3_safetypast
label values D5_V1_I3_safetypast lbl_safety

*------------2.5 Label variables - next year assault
label values vli04 lbl_assaultfuture
label var vli04 "D5_V1_I4. Could be assaulted or robbed the next year?"
rename vli04 D5_V1_I4_assault_nextyear

*------------2.6 Assaulted past
replace vli05=0 if vli05==3
label values vli05 yesno
label var vli05 "D5_V2_I1.  Have you ever been assaulted, robbed, or have you been a victim of any violent"
rename vli05 D5_V2_I1_assaultpast

*------------2.7 Police protection
label values vli26_1 lbl_police
label var vli26_1 "D5_V2_I2. How frequently have you seen a policeman or a soldier, watch over the neighborhood where you live?"
rename vli26_1 D5_V2_I2_policepresence

*------------2.8 Avoid going out at night
label values vli27 lbl_freq
label var vli27 "D5_V2_I2. Currently, how frequently do you go out at night?"
rename vli27 D5_V2_I2_freqnight

*------------2.9 Compare going out at night 
label values vli28 lbl_comp
label var vli28 "D5_V2_I3. Compared with 5 years ago, do you currently go out at night (...)?"
rename vli28 D5_V2_I3_freqnightcomp

*------------2.10 Carry valuable objects
label values vli29 lbl_freq
label var vli29 "D5_V2_I4. How frequently do you carry valuable objects when you go out to the street?"
rename vli29 D5_V2_I4_valobjects

*------------2.11 Carry valuable objects - compare
label values vli30 lbl_comp
label var vli30 "D5_V2_I5. Compared with 5 years ago, you currently do you carry valuable objects when you go out to the street (...)?"
rename vli30 D5_V2_I5_valobjects_5years

*------------2.12 Change transportation, route, defense objects
foreach var in vli31 vli32 vli33_1a {
    replace `var' = 0 if `var' == 3
}
foreach var in vli31 vli32 vli33_1a {
    label values `var' yesno
}
label var vli31 "D5_V2_I6 As a security measure, do you change your transportation?"
rename vli31 D5_V2_I6_changetransp
label var vli32 "D5_V2_I7 As a security measure, do you change your route?"
rename vli32 D5_V2_I7_changeroute
label var vli33_1a "D5_V2_I8 Do you regularly carry any object or weapon?"
rename vli33_1a D5_V2_I8_selfdefeweapon

/*==============================================================================
* 3. Save final version - Individual victimization      (wave 1)               *
==============================================================================*/

*------------3.1: Seva unmerged dataset at individual level
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
gen panel_wave=1
label var panel_wave "Panel wave from MxFLS"
order panel_wave, b(folio)
gen origin_report="Official book"
label var origin_report "Type of book the data originated from"
label var ls "Individual ID from cover book"
label var ls_str "Individual ID from cover book"
sort folio ls_individual
save "${finaldata}\MMCI_D5.Bodilyinteg_ind_allvars_w1_fin.dta", replace



/*==============================================================================
                     WAVE 2 (PERIOD T) - REGULAR BOOK
==============================================================================*/

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

             Variables: Individual variables of security / crime
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

/*==============================================================================
 0.General setup / Work environment (Wave 2) and merging                               
==============================================================================*/

set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave II\Individual\hh05dta_b3a - Wave 2"

*------------1.1: Prepare database VLI to merge (with individual datasets)
use "${rawdata}\iiia_vli"
gen ls_str="placeholder"
gen folio_str="placeholder"
gen individual_id = folio + "_" + ls
rename ls ls_individual
rename ls_str ls_str_individual
save "${rawdata}\individualvict_aux", replace

*------------1.2: Merge with cover data at household level (creating bridge)
* Note: Bridge to merge with community data through loc_id
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave II\Household\hh05dta_bc - Book C (Control book) W2"
use "${rawdata}\c_portad"
gen ls_str="placeholder"
gen folio_str="placeholder"
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave II\Individual\hh05dta_b3a - Wave 2"
drop if folio==""
duplicates report folio
duplicates list folio
save "${rawdata}\cbportad_aux", replace

merge 1:m folio using "${rawdata}\individualvict_aux", generate(_merge_1)
drop if _merge_1==1
**Note: Most people from using data got match: meaning all people asked
*about their victimzation were also on the roster.


*------------1.3: Keep only relevant data
keep folio folio_str ls ls_str ent mpio loc edad id_loc vli01 vli02 vli03 vli04 vli05 vli26_1 vli27 vli28 vli29 vli30 vli31 vli32 vli33_1 individual_id _merge_1 ls_str_individual ls_individual pid_link
rename ent edo

/*==============================================================================
 2.Add label / rename variables - Individual victimization (wave 2) 
==============================================================================*/

*------------2.1: Label scared attack
label define lbl_scared 1"Very scared" 2"Scared" 3"A little scared" ///
4 "Do not feel scared"

*------------2.2 Label and rename variables scared night and day
label values vli01 lbl_scared
label values vli02 lbl_scared
label var vli01 "D5_V1_I1. Do you feel (...) of being attacked or assaulted during the day?" 
rename vli01 D5_V1_I1_worassault_day
label var vli02 "D5_V1_I2. Do you feel (...) of being attacked or assaulted during the night?" 
rename vli02 D5_V1_I2_worassault_night

*------------2.3 Create rest of labels
label define lbl_safety 1"Safer" 2"Safe" 3"Less safe"
label define lbl_assaultfuture 1"It is very probable that it could happen" ///
2"It is probable that it could happen" ///
3"It is a little probable that it could happen" ///
4"Do not think that it could happen"
label define yesno 1"Yes" 0"No"
label define lbl_police 1"Days a week" 2"Days a month" 3"Haven't seen"
label define lbl_freq 1"Very frequently" 2"Frequently" 3"A little frequently" ///
4"Not frequently"
label define lbl_comp 1"More than then" 2"The same as then" 3"Less than then"


*------------2.4 Label variables - safety past
label values vli03 lbl_safety
label var vli03 "D5_V1_I3. VL1.03 Compared to 5 years ago, do you feel (...)"
rename vli03 D5_V1_I3_safetypast
label values D5_V1_I3_safetypast lbl_safety

*------------2.5 Label variables - next year assault
label values vli04 lbl_assaultfuture
label var vli04 "D5_V1_I4. Could be assaulted or robbed the next year?"
rename vli04 D5_V1_I4_assault_nextyear

*------------2.6 Assaulted past
replace vli05=0 if vli05==3
label values vli05 yesno
label var vli05 "D5_V2_I1.  Have you ever been assaulted, robbed, or have you been a victim of any violent"
rename vli05 D5_V2_I1_assaultpast

*------------2.7 Police protection
label values vli26_1 lbl_police
label var vli26_1 "D5_V2_I2. How frequently have you seen a policeman or a soldier, watch over the neighborhood where you live?"
rename vli26_1 D5_V2_I2_policepresence

*------------2.8 Avoid going out at night
label values vli27 lbl_freq
label var vli27 "D5_V2_I2. Currently, how frequently do you go out at night?"
rename vli27 D5_V2_I2_freqnight

*------------2.9 Compare going out at night 
label values vli28 lbl_comp
label var vli28 "D5_V2_I3. Compared with 5 years ago, do you currently go out at night (...)?"
rename vli28 D5_V2_I3_freqnightcomp

*------------2.10 Carry valuable objects
label values vli29 lbl_freq
label var vli29 "D5_V2_I4. How frequently do you carry valuable objects when you go out to the street?"
rename vli29 D5_V2_I4_valobjects

*------------2.11 Carry valuable objects - compare
label values vli30 lbl_comp
label var vli30 "D5_V2_I5. Compared with 5 years ago, you currently do you carry valuable objects when you go out to the street (...)?"
rename vli30 D5_V2_I5_valobjects_5years

*------------2.12 Change transportation, route, defense objects
foreach var in vli31 vli32 vli33_1 {
    replace `var' = 0 if `var' == 3
}
foreach var in vli31 vli32 vli33_1 {
    label values `var' yesno
}
label var vli31 "D5_V2_I6 As a security measure, do you change your transportation?"
rename vli31 D5_V2_I6_changetransp
label var vli32 "D5_V2_I7 As a security measure, do you change your route?"
rename vli32 D5_V2_I7_changeroute
label var vli33_1 "D5_V2_I8 Do you regularly carry any object or weapon?"
rename vli33_1 D5_V2_I8_selfdefeweapon

/*==============================================================================
* 3. Save final version - Individual victimization      (wave 2)               *
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
drop if _merge_1==1
save "${finaldata}\MMCI_D5.Bodilyinteg_ind_allvars_w2_fin.dta", replace





/*==============================================================================
                     WAVE 3 (PERIOD T+1) - REGULAR BOOK
==============================================================================*/

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

             Variables: Individual variables of security / crime
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

/*==============================================================================
 0.General setup / Work environment (Wave 3) and merging                               
==============================================================================*/

set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave III\Individual\hh09dta_b3a - Wave 3"

*------------1.1: Prepare database VLI to merge (with individual datasets)
use "${rawdata}\iiia_vli"
gen ls_str="placeholder"
gen folio_str="placeholder"
gen individual_id = folio + "_" + ls
rename ls ls_individual
rename ls_str ls_str_individual
save "${rawdata}\individualvict_aux", replace

*------------1.2: Merge with cover data at household level (creating bridge)
* Note: Bridge to merge with community data through loc_id
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave III\Household\hh09dta_bc - Book C (Control book) W3"
use "${rawdata}\c_portad"
gen ls_str="placeholder"
gen folio_str="placeholder"
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave III\Individual\hh09dta_b3a - Wave 3"
drop if folio==""
duplicates report folio
duplicates list folio
save "${rawdata}\cbportad_aux", replace

merge 1:m folio using "${rawdata}\individualvict_aux", generate(_merge_1)
drop if _merge_1==1
**Note: Most people from using data got match: meaning all people asked
*about their victimzation were also on the roster.


*------------1.3: Keep only relevant data
keep folio folio_str ls ls_str ent mpio loc edad id_loc vli01 vli02 vli03 vli04 vli05 vli05a vli26_1 vli27 vli28 vli29 vli30 vli31 vli32 vli33_1 individual_id _merge_1 ls_str_individual ls_individual pid_link
rename ent edo

/*==============================================================================
 2.Add label / rename variables - Individual victimization (wave 2) 
==============================================================================*/

*------------2.1: Label scared attack
label define lbl_scared 1"Very scared" 2"Scared" 3"A little scared" ///
4 "Do not feel scared"

*------------2.2 Label and rename variables scared night and day
label values vli01 lbl_scared
label values vli02 lbl_scared
label var vli01 "D5_V1_I1. Do you feel (...) of being attacked or assaulted during the day?" 
rename vli01 D5_V1_I1_worassault_day
label var vli02 "D5_V1_I2. Do you feel (...) of being attacked or assaulted during the night?" 
rename vli02 D5_V1_I2_worassault_night

*------------2.3 Create rest of labels
label define lbl_safety 1"Safer" 2"Safe" 3"Less safe"
label define lbl_assaultfuture 1"It is very probable that it could happen" ///
2"It is probable that it could happen" ///
3"It is a little probable that it could happen" ///
4"Do not think that it could happen" 8"Don't know"
label define yesno 1"Yes" 0"No"
label define lbl_police 1"Days a week" 2"Days a month" 3"Haven't seen"
label define lbl_freq 1"Very frequently" 2"Frequently" 3"A little frequently" ///
4"Not frequently"
label define lbl_comp 1"More than then" 2"The same as then" 3"Less than then"

*-------------2.4 Crate new change labels for 2009 MxFLS
label define lbl_alternative_assaultfuture 1"Very likely" 2"Likely" ///
3"Not very likely" 4"Not likely" 8"Don't know"

*------------2.4 Label variables - safety past
label values vli03 lbl_safety
label var vli03 "D5_V1_I3. VL1.03 Compared to 5 years ago, do you feel (...)"
rename vli03 D5_V1_I3_safetypast
label values D5_V1_I3_safetypast lbl_safety

*------------2.5 Label variables - next year assault
gen orig_vli04=vli04
label values vli04 lbl_assaultfuture
label var vli04 "D5_V1_I4. Could be assaulted or robbed the next year?"
rename vli04 D5_V1_I4_assault_nextyear
label var orig_vli04 "D5_V1_I4. Original scale: Could be assaulted or robbed the next year?"
rename orig_vli04 orig_D5_V1_I4_assault_nextyear
label values orig_D5_V1_I4_assault_nextyear lbl_alternative_assaultfuture
order  orig_D5_V1_I4_assault_nextyear, a(D5_V1_I4_assault_nextyear)

*------------2.6 Assaulted past
replace vli05a=0 if vli05a==3
label values vli05a yesno
label var vli05a "D5_V2_I1.  Have you ever been assaulted, robbed, or have you been a victim of any violent"
rename vli05a D5_V2_I1_assaultpast

*------------2.7 Police protection
label values vli26_1 lbl_police
label var vli26_1 "D5_V2_I2. How frequently have you seen a policeman or a soldier, watch over the neighborhood where you live?"
rename vli26_1 D5_V2_I2_policepresence

*------------2.8 Avoid going out at night
label values vli27 lbl_freq
label var vli27 "D5_V2_I2. Currently, how frequently do you go out at night?"
rename vli27 D5_V2_I2_freqnight

*------------2.9 Compare going out at night 
label values vli28 lbl_comp
label var vli28 "D5_V2_I3. Compared with 5 years ago, do you currently go out at night (...)?"
rename vli28 D5_V2_I3_freqnightcomp

*------------2.10 Carry valuable objects
label values vli29 lbl_freq
label var vli29 "D5_V2_I4. How frequently do you carry valuable objects when you go out to the street?"
rename vli29 D5_V2_I4_valobjects

*------------2.11 Carry valuable objects - compare
label values vli30 lbl_comp
label var vli30 "D5_V2_I5. Compared with 5 years ago, you currently do you carry valuable objects when you go out to the street (...)?"
rename vli30 D5_V2_I5_valobjects_5years

*------------2.12 Change transportation, route, defense objects
foreach var in vli31 vli32 vli33_1 {
    replace `var' = 0 if `var' == 3
}
foreach var in vli31 vli32 vli33_1 {
    label values `var' yesno
}
label var vli31 "D5_V2_I6 As a security measure, do you change your transportation?"
rename vli31 D5_V2_I6_changetransp
label var vli32 "D5_V2_I7 As a security measure, do you change your route?"
rename vli32 D5_V2_I7_changeroute
label var vli33_1 "D5_V2_I8 Do you regularly carry any object or weapon?"
rename vli33_1 D5_V2_I8_selfdefeweapon

/*==============================================================================
* 3. Save final version - Individual victimization      (wave 3)               *
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
label define lbl_panelmem 1"It's panel member" 0"It's not panel member"
gen panel_assault_w3=0
replace panel_assault_w3=1 if D5_V2_I1_assaultpast==.
label values panel_assault_w3 lbl_panelmem
drop vli05
order panel_assault_w3, b( D5_V2_I1_assaultpast)
save "${finaldata}\MMCI_D5.Bodilyinteg_ind_allvars_w3_fin.dta", replace






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
use "${finaldata}\MMCI_D5.Bodilyinteg_ind_allvars_w3_fin.dta"
gen folio_left = substr(folio, 1, 6)
gen folio_right = substr(folio, 9, 10)
gen folio_clean = folio_left + "" + folio_right
drop folio_str
replace folio=folio_clean
drop folio_left folio_right folio_clean
save "${finaldata}\MMCI_D5.Bodilyinteg_ind_allvars_w3_fin.dta", replace


*------------P.2.1: Harmonize folio variable (Wave 2)
*Do: generate trailing zeroes for folio
clear all
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
use "${finaldata}\MMCI_D5.Bodilyinteg_ind_allvars_w2_fin.dta"
/*gen folio_str_aux = string(folio, "%08.0f")
drop folio
rename folio_str_aux folio
order folio , a( panel_wave)
label var folio "HOUSEHOLD ID 2005"
*/
drop folio_str
save "${finaldata}\MMCI_D5.Bodilyinteg_ind_allvars_w2_fin.dta", replace
*/

*------------P.2.1: Harmonize folio variable (Wave 1)
*Do: generate trailing zeroes for folio
clear all
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
use "${finaldata}\MMCI_D5.Bodilyinteg_ind_allvars_w1_fin.dta"
gen folio_str_aux = string(folio, "%08.0f")
drop folio
rename folio_str_aux folio
order folio , a( panel_wave)
label var folio "Household ID"
drop folio_str
save "${finaldata}\MMCI_D5.Bodilyinteg_ind_allvars_w1_fin.dta", replace


/*==============================================================================
* PHASE 2: Harmonize pidlink                                                   *
==============================================================================*/

*------------P.2.1: Harmonize pid_link variable (Wave 3)
*Do: extract only numerics 
clear all
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
use "${finaldata}\MMCI_D5.Bodilyinteg_ind_allvars_w3_fin.dta"
gen pidlink_left = substr(pid_link, 1, 6)
gen pidlink_right = substr(pid_link, 9, 10)
gen pidlink_clean = pidlink_left + "" + pidlink_right
drop pidlink_right pidlink_left
order pidlink_clean, a(pid_link)
save "${finaldata}\MMCI_D5.Bodilyinteg_ind_allvars_w3_fin.dta", replace


*------------P.2.2: Harmonize pid_link variable (Wave 2)
*Do: extract only numerics 
clear all
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
use "${finaldata}\MMCI_D5.Bodilyinteg_ind_allvars_w2_fin.dta"
*Note: It looks like everything is harmonized
gen pidlink_clean=pid_link
order pidlink_clean, a( pid_link)
save "${finaldata}\MMCI_D5.Bodilyinteg_ind_allvars_w2_fin.dta", replace


*------------P.2.3: Harmonize pid_link variable (Wave 1) 
clear all
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
use "${finaldata}\MMCI_D5.Bodilyinteg_ind_allvars_w1_fin.dta"
*I need to create an equal pidlink_clean
*first I need to put leading zeroes on the individual ls as these are the last
*2 digits of a pid_link, 6 first are folio
gen ls_ind_aux = string(ls_individual, "%02.0f")
gen pidlink_clean=folio + "" + ls_ind_aux
drop ls_ind_aux
order pidlink_clean, after( ls_str_individual)
tostring id_loc, replace
order ls_individual- individual_id, af( ls_str)
order individual_id- id_loc, a( pidlink_clean)
tostring ls, replace
tostring ls_individual, replace

save "${finaldata}\MMCI_D5.Bodilyinteg_ind_allvars_w1_fin.dta", replace

/*==============================================================================
* PHASE 3: First append                                                 *
==============================================================================*/

*------------P.3.1: Append waves
clear all
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
use "${finaldata}\MMCI_D5.Bodilyinteg_ind_allvars_w3_fin.dta"
append using "${finaldata}\MMCI_D5.Bodilyinteg_ind_allvars_w2_fin.dta"
sort pidlink_clean panel_wave
append using "${finaldata}\MMCI_D5.Bodilyinteg_ind_allvars_w1_fin.dta"
sort pidlink_clean panel_wave
global paneldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.3 Panel data"
*Note: Unifiy don't know label differences
replace D5_V1_I4_assault_nextyear=8 if D5_V1_I4_assault_nextyear==5
drop origin_report ls_ind_aux
save "${paneldata}\MMCI_D5.Bodilyinteg_ind_allvars_panel.dta", replace

*------------P.3.2: Enconde id for panel analysis
encode pidlink_clean, gen(pid_id)
label var pid_id "Individual constant ID prepared for panel analysis"
duplicates report pid_id panel_wave
*Note: Found no duplicates
duplicates tag pid_id panel_wave, gen(dup)
list pid_link pidlink_clean pid_id folio panel_wave individual_id if dup
duplicates drop pidlink_clean panel_wave, force
*Note: 9 people appear twice on the same wave
order pid_id, after(panel_wave)
drop dup
sort pid_id panel_wave
order ls_str_individual individual_id _merge_1, a( pidlink_clean)
save "${paneldata}\MMCI_D5.Bodilyinteg_ind_allvars_panel.dta", replace


/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                 Post-append: Check panel characteristics
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/


global paneldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.3 Panel data"
use "${paneldata}\MMCI_D5.Bodilyinteg_ind_allvars_panel.dta"


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
foreach var in D5_V1_I1_worassault_day D5_V1_I2_worassault_night ///
D5_V1_I3_safetypast D5_V1_I4_assault_nextyear orig_D5_V1_I4_assault_nextyear ///
D5_V2_I1_assaultpast D5_V2_I2_policepresence D5_V2_I2_freqnight ///
D5_V2_I3_freqnightcomp D5_V2_I4_valobjects D5_V2_I5_valobjects_5years ///
D5_V2_I6_changetransp D5_V2_I7_changeroute D5_V2_I8_selfdefeweapon {
	gen w1 = panel_wave == 1 & !missing(`var')
    gen w2 = panel_wave == 2 & !missing(`var')
    gen w3 = panel_wave == 3 & !missing(`var')
    bys pid_id: egen has1 = max(w1)
    bys pid_id: egen has2 = max(w2)
    bys pid_id: egen has3 = max(w3)
    gen p_`var' = string(has1) + string(has2) + string(has3)
    drop w1 w2 w3 has1 has2 has3
}

egen tag = tag(pid_id)

foreach var in D5_V1_I1_worassault_day D5_V1_I2_worassault_night ///
D5_V1_I3_safetypast D5_V1_I4_assault_nextyear orig_D5_V1_I4_assault_nextyear ///
D5_V2_I1_assaultpast D5_V2_I2_policepresence D5_V2_I2_freqnight ///
D5_V2_I3_freqnightcomp D5_V2_I4_valobjects D5_V2_I5_valobjects_5years ///
D5_V2_I6_changetransp D5_V2_I7_changeroute D5_V2_I8_selfdefeweapon {
    tab p_`var' if tag==1
}

*------------PC.3: Continue checking panel characteristics
xtsum
*Note: Verify that there is not within variation for static variables (i.e ids)
bys folio: gen n_waves = _N
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

save "${paneldata}\MMCI_D5.Bodilyinteg_ind_allvars_panel.dta", replace

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                  Post-append: Last validation rules for panel merging
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

clear all
global paneldata "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.3 Panel data"
global finaldata "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
use "${paneldata}\MMCI_D5.Bodilyinteg_ind_allvars_panel.dta", clear

*------------VR1: Create frames to do operations on multiple datasets
frame create wave1
frame create wave2
frame create wave3

frame wave1: {
    use "${finaldata}\MMCI_D5.Bodilyinteg_ind_allvars_w1_fin.dta", clear
    keep pidlink_clean folio
    duplicates drop
}

frame wave2: {
    use "${finaldata}\MMCI_D5.Bodilyinteg_ind_allvars_w2_fin.dta", clear
    keep pidlink_clean folio
    duplicates drop
}

frame wave3: {
    use "${finaldata}\MMCI_D5.Bodilyinteg_ind_allvars_w3_fin.dta", clear
    keep pidlink_clean folio
    duplicates drop
}

*------------VR2: Link the person id
frlink m:1 pidlink_clean, frame(wave1) gen(link_w1)
frlink m:1 pidlink_clean, frame(wave2) gen(link_w2)
frlink m:1 pidlink_clean, frame(wave3) gen(link_w3)


*------------VR3: Create person level validation variable
gen person_w1 = (link_w1 < .)
gen person_w2 = (link_w2 < .)
gen person_w3 = (link_w3 < .)
label define yesno 0 "No" 1 "Yes", replace
label values person_w1 yesno
label values person_w2 yesno
label values person_w3 yesno
label var person_w1 "Person exists in Wave 1 dataset"
label var person_w2 "Person exists in Wave 2 dataset"
label var person_w3 "Person exists in Wave 3 dataset"

save "${paneldata}\MMCI_D5.Bodilyinteg_ind_allvars_panel.dta", replace
