/*==============================================================================
                   MMCI - Cleaning individual level variables                  
==============================================================================*/
/*

Project:               (Im)mobility in Mexico
Database:              Mexico Life Survey - Wave 1, 2 and 3
Level:                 Individual databases
Book:                  Book IIIB - Characteristics of Adult Household Members
                    
Subsection:            SM - Emotional Wellbeing
Dofile author:         Gabriela Judith López Gutiérrez
Creation date:         July 2026 /10
Modification date:     June 2026 /20
Product 1:             Produce individual level dimensions of emotional wellbeing
                       GHQ index of emotional wellbeing as a robustness control
Nussbaum 10:           Various
Dimension (study):
Variable:              Several
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
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave I\Individual\hh02dta_b3b - Wave 1"

*------------1.1: Prepare database VLI to merge (with individual datasets)
use "${rawdata}\iiib_sm"
tostring folio, gen(folio_str) format(%15.0f)
tostring ls, gen(ls_str)
gen individual_id = folio_str + "_" + ls_str
rename ls ls_individual
rename ls_str ls_str_individual
save "${rawdata}\individualemowellbeing_aux", replace

*------------1.2: Merge with cover data at household level (creating bridge)
* Note: Bridge to merge with community data through loc_id
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave I\Household\hh02dta_bc - Book C (Control book) W1"
use "${rawdata}\c_portad"
tostring folio, gen(folio_str) format(%15.0f)
tostring ls, gen(ls_str)
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave I\Individual\hh02dta_b3b - Wave 1"
drop if folio==.
duplicates report folio_str
duplicates list folio_str
drop if folio==8486000 & ls==7
save "${rawdata}\cbportad_aux", replace

merge 1:m folio_str using "${rawdata}\individualemowellbeing_aux.dta", generate(_merge_1)
drop if _merge_1==1

*------------1.3: Keep only relevant data
keep folio folio_str ls ls_str edo mpio loc edad id_loc individual_id _merge_1 ls_str_individual ls_individual sm01 sm02 sm03 sm04 sm05 sm09 sm11 sm13 sm15 sm16 sm17 sm18

/*==============================================================================
 2.Add label / rename variables - Emotional wellbeing (wave 1) 
==============================================================================*/

*------------2.1: Label scared attack
label define lbl_severity 0"No" 1"Yes, sometimes" 2"Yes, a lot of times" ///
3"Yes, all the time"

*------------2.2: Label value replace, rename and value loop
local j = 1 
foreach var in sm01 sm02 sm03 sm04 sm05 sm09 sm11 sm13 sm15 sm16 sm17 sm18 {
	replace `var'=0 if `var'==4
	label values `var' lbl_severity
    rename `var' emotional_wellbeing_`j'
	local ++j
}

/*==============================================================================
 2.GHQ-12 construction for robustness analysis (wave 1) 
==============================================================================*/
*Note: The scoring system simply consists in summing up the answers as it is done 
*in the GHQ-12, which gives scores on a scale from 10 to 40. 

*Note: Robustness analysis (to be performed later): We have experimented 
*alternative aggregation methods including Principal Component Analysis

local GHQ emotional_wellbeing_5 emotional_wellbeing_3 emotional_wellbeing_11 emotional_wellbeing_7 emotional_wellbeing_9 emotional_wellbeing_12 emotional_wellbeing_2 emotional_wellbeing_8 emotional_wellbeing_4 emotional_wellbeing_10 emotional_wellbeing_6 emotional_wellbeing_1

egen GHQ_score=rowtotal(emotional_wellbeing_1- emotional_wellbeing_12)

generate GHQ_cat = .
replace GHQ_cat = 1 if inrange(GHQ_score,0,8)
replace GHQ_cat = 2 if inrange(GHQ_score,9,17)
replace GHQ_cat = 3 if inrange(GHQ_score,18,26)
replace GHQ_cat = 4 if inrange(GHQ_score,27,36)

label define ghq_lbl 1 "0-8" 2 "9-17" 3 "18-26" 4 "27-36"

label values GHQ_cat ghq_lbl

/*==============================================================================
* 3. Save final version - Emotional wellbeing      (wave 1)               *
==============================================================================*/

*------------3.1: Save unmerged dataset at individual level
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
gen panel_wave=1
label var panel_wave "Panel wave from MxFLS"
order panel_wave, b(folio)
gen origin_report="Official book"
label var origin_report "Type of book the data originated from"
label var ls "Individual ID from cover book"
label var ls_str "Individual ID from cover book"
sort folio ls_individual
save "${finaldata}\MMCI_MULTDIM_Emotionalwellbeing_w1_fin.dta", replace




