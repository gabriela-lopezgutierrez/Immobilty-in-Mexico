/*==============================================================================
                      Cleaning individual datasets                          
==============================================================================*/
/*

Project:               (Im)mobility in Mexico
Database:              Mexico Life Survey - Wave 1, 2 and 3
Level:                 Community databases
Book:                  Community characteristics
Subsection:            AS - Social assistance
                       AC - Community activities
Dofile author:         Gabriela Judith López Gutiérrez
Creation date:         July 2026 /10
Modification date:     June 2026 /20
Product 1:             Produce community-level variables for the MMCI
Nussbaum 10:           Affiliation
Dimension:
Determinant:           Social conversion factors
Flow:                  1. Merge database with cover data
                          1.1. Prepare cover for merging
						  1.2. Prepare your data for merging
						  1.3. Merge them
                       2. Keep only relevant variables
					   3. Value labels and generate variables
					   Note: Repeat for each wave, as needed

*/

/*==============================================================================
                           WAVE 1 (PERIOD T-1)
==============================================================================*/

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                     Variable 1: Community meetings (AC)
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/


/*==============================================================================
 0.General setup / Work environment (Wave 1)                                  
==============================================================================*/

set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave I\Community\Community - loc02dta_bcc"

/*==============================================================================
 1.Import (Wave 1)                                                            
==============================================================================*/

use "${rawdata}/loc_ac"
numlabel, add

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
label variable D1_V1_I1_meetings "D1_V1_I1. Number of meetings organized by the community"

*------------3.2: Indicator 2 - Var 2: Percentage: population in meetings
gen D1_V1_I2_percpart=.
replace D1_V1_I2_percpart=1 if ac03_3>50 & ac03_3!=.
replace D1_V1_I2_percpart=0 if ac03_3<50
label define part_perc 1"Participation above 50%" 0"Participation below 50%"
label values D1_V1_I2_percpart part_perc
label variable D1_V1_I2_percpar "D1_V1_I1. Number of meetings organized by the community"

*Note: this variable is incomplete

/*==============================================================================
* 4. Save final version - Affiliation - community level (wave 1)               *
==============================================================================*/
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.3 Final data"

keep folio ac_mismo ac01 ac02_2 ac03_1 ac03_2 ac03_3 D1_V1_I1_meetings D1_V1_I2_percpart

tostring folio, gen(folio_str) format(%15.0f)

save "${finaldata}/MMCI_D1.Affiliation_comm_w1_fin.dta", replace

/*==============================================================================
* 5. Merge with cover information - Affiliation - community level (wave 1)     *
==============================================================================*/

set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave I\Community\Community - loc02dta_bcc"
use "${rawdata}/loc_portad"

tostring folio, gen(folio_str) format(%15.0f)
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.3 Final data"
save "${finaldata}/portad_commchar_w1_fin.dta", replace

cd "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.3 Final data"

merge 1:1 folio_str using MMCI_D1.Affiliation_comm_w1_fin.dta, generate(_merge_1)


