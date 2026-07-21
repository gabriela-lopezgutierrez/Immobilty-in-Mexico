/*==============================================================================
                   MMCI - Cleaning individual level variables                  
==============================================================================*/
/*

Project:               (Im)mobility in Mexico
Database:              Mexico Life Survey - Wave 1, 2 and 3
Level:                 Individual databases
Book:                  Book IIIB - Characteristics of Adult Household Members
                       Proxy book - Members not present at interview
Subsection:            ES - Health condition
Dofile author:         Gabriela Judith López Gutiérrez
Creation date:         July 2026 /10
Modification date:     June 2026 /20
Product 1:             Produce MMCI Dimension 2. Variable 1
Nussbaum 10:           Bodily health
Dimension (study):
Variable:              Health status self-perception
Flow:                  1. Merge database with cover data (from hh control book)
                       2. Keep only relevant variables
					   3. Value labels and generate variables
					   4. Repeat for proxy book 
					   5. Join proxy book and official book (handle duplicates)
					   6. Repeat for each wave
					   5. Create panel
Changes per wave:      
Note:                  Only HH members 15 years old or older answer
Keys community:        Communitary id joins cover data with community data
Keys hh level:         HH id joins cover data with hh level data
Keys two levels:       Locality id joins community with hh-level data
Note:                  IDs are a combination of (folio + ls)
Note:                  Folio needs to be turn into string first
Note:                  Missing value problem in self-perceived health, 
                       across the same people
Note:                  (line 123) Keep track of type of book the data comes from
Note:                  Duplicate report and handling section varies by wave
				
*/

/*==============================================================================
                     WAVE 1 (PERIOD T-1) - REGULAR BOOK
==============================================================================*/

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                     Variable 1: HS self-perception (ES)
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

/*==============================================================================
 0.General setup / Work environment (Wave 1) and merging                               
==============================================================================*/

set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave I\Individual\hh02dta_b3b - Wave 1"

*------------1.1: Prepare database ES to merge (with individual datasets)
use "${rawdata}\iiib_es"
tostring folio, gen(folio_str) format(%15.0f)
tostring ls, gen(ls_str)
gen individual_id = folio_str + "_" + ls_str
save "${rawdata}\selfperchealth_aux", replace


*------------1.2: Merge with cover data at household level (creating bridge)
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

merge 1:m folio_str using "${rawdata}\selfperchealth_aux", generate(_merge_1)

*------------1.3: Keep only relevant data
keep folio folio_str ls ls_str edo mpio loc edad id_loc es01 es05 es15 es16 individual_id _merge_1

/*==============================================================================
 2.Add label variables - HS self perception (wave 1) 
==============================================================================*/

*-----------2.1: Label Likert Scale ES01
label define phealth_current 1"Very good" 2"Good" 3"Regular" 4"Bad" 5"Very bad"
label values es01 phealth_current
tab es01, miss

*-----------2.2: Label Likert Scale ES05
label define phealth_past 1"Much better" 2"Better" 3"The same" 4"Worse" ///
5"Much worse"
label values es05 phealth_past
tab es05, miss

*-----------2.3: Label Likert Scale ES15
label values es15 phealth_past
tab es15, miss

*-----------2.2: Label Likert Scale ES05
label define phealth_compared 1"Much better than the others" ///
2"Better than the others" 3"The same as the others" ///
4"Worse than the others" 5"Much worse than the others"
label values es16 phealth_compared
tab es16, miss

rename es01 D2_V1_I1_acthealth
label var D2_V1_I1_acthealth "D2_V1_I1. Current health status self-assessment"
rename es05 D2_V1_I2_pasthealth
label var D2_V1_I2_pasthealth "D2_V1_I2. Comparing of health one year ago self-assesment"
rename es15 D2_V1_I3_exphealth
label var D2_V1_I3_exphealth "D2_V1_I3. Health next week self-assessment"
rename es16 D2_V1_I4_comphealth
label var D2_V1_I4_comphealth "D2_V1_I3. Health compared to similar peers self-assessment"

/*==============================================================================
* 4. Save final version - HS Self perception (wave 1)               *
==============================================================================*/

*------------4.1: Seva unmerged dataset at individual level
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
gen panel_wave=1
label var panel_wave "Panel wave from MxFLS"
order panel_wave, b(folio)
gen origin_report="Official book"
label var origin_report "Type of book the data originated from"
save "${finaldata}\MMCI_D1.Bodilyhealth_ind_v1_w1_finofficial.dta", replace



/*==============================================================================
                     WAVE 1 (PERIOD T-1) - PROXY BOOK
==============================================================================*/

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                     Variable 1: HS self-perception (ES)
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

/*==============================================================================
 0.General setup / Work environment (Wave 1) and merging                               
==============================================================================*/

set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave I\Individual\Book Proxy - Wave 1"

*------------1.1: Prepare database ES to merge (with individual datasets)
use "${rawdata}\p_es"
tostring folio, gen(folio_str) format(%15.0f)
tostring ls, gen(ls_str)
gen individual_id = folio_str + "_" + ls_str
save "${rawdata}\selfperchealth_aux_proxy", replace


*------------1.2: Merge with cover data at household level (creating bridge)
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave I\Household\hh02dta_bc - Book C (Control book) W1"
use "${rawdata}\c_portad"
tostring folio, gen(folio_str) format(%15.0f)
tostring ls, gen(ls_str)
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave I\Individual\Book Proxy - Wave 1"
drop if folio==.
duplicates report folio_str
duplicates list folio_str
drop if folio==8486000 & ls==7
save "${rawdata}\cbportad_aux", replace

merge 1:m folio_str using "${rawdata}\selfperchealth_aux_proxy", generate(_merge_1)
drop if _merge_1==1
drop if _merge_1==2

*------------1.3: Keep only relevant data
keep folio folio_str ls ls_str edo mpio loc edad id_loc es01 es05 es15 es16 individual_id _merge_1

/*==============================================================================
 2.Add label variables - HS self perception (wave 1) 
==============================================================================*/

*-----------2.1: Label Likert Scale ES01
label define proxy_phealth_current 1"Very good" 2"Good" 3"Regular" 4"Bad" ///
5"Very bad" 8"Don't know"
label values es01 proxy_phealth_current
tab es01, miss

*-----------2.2: Label Likert Scale ES05
label define proxy_phealth_past 1"Much better" 2"Better" 3"The same" ///
4"Worse" 5"Much worse" 8 "Don't know"
label values es05 proxy_phealth_past
tab es05, miss

*-----------2.3: Label Likert Scale ES15
label values es15 proxy_phealth_past
tab es15, miss

*-----------2.2: Label Likert Scale ES05
label define proxy_phealth_compared 1"Better than the others" ///
2"The same as the others" 3"Worse than the others"  ///
8"Don't know"
label values es16 proxy_phealth_compared
tab es16, miss

rename es01 D2_V1_I1_acthealth_proxy
label var D2_V1_I1_acthealth_proxy ///
"D2_V1_I1. Proxy = Current health status self-assessment"
rename es05 D2_V1_I2_pasthealth_proxy
label var D2_V1_I2_pasthealth_proxy ///
"D2_V1_I2. Proxy = Comparing of health one year ago self-assesment"
rename es15 D2_V1_I3_exphealth_proxy
label var D2_V1_I3_exphealth_proxy ///
"D2_V1_I3. Proxy = Health next week self-assessment"
rename es16 D2_V1_I4_comphealth_proxy
label var D2_V1_I4_comphealth_proxy ///
"D2_V1_I3. Proxy = Health compared to similar peers self-assessment"

/*==============================================================================
* 4. Save final version - HS Self perception (wave 1)               *
==============================================================================*/

*------------4.1: Seva unmerged dataset at individual level
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
gen panel_wave=1
label var panel_wave "Panel wave from MxFLS"
order panel_wave, b(folio)
gen origin_report="Proxy book"
label var origin_report "Type of book the data originated from"
save "${finaldata}\MMCI_D1.Bodilyhealth_ind_v1_w1_finproxy.dta", replace


/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

               Merging official with proxy book (Wave 1 ES)
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

*------------5.1: append databases
append using "${finaldata}\MMCI_D1.Bodilyhealth_ind_v1_w1_finofficial.dta"

*------------5.1: check no duplicates in individual id
duplicates report individual_id
duplicates list individual_id
*Note: some people without individual ids
*They are probable not matched from cover data control book hh level
br if individual_id==""
*Note: I confirmed the previous, so we can drop them
drop if _merge_1==1
duplicates report individual_id
duplicates list individual_id
*The rest of duplicates are prob people who were in proxy book and in hh cover
*from control book but not in official health report database
br if individual_id=="2167000_3" | individual_id=="2603000_3" ///
| individual_id=="3312000_5" | individual_id=="5072000_5" | ///
 individual_id=="6703000_3" | individual_id=="7921000_1"  | ///
 individual_id=="8350000_2" | individual_id=="9232000_1"
*Note: Actually these people appeared in both tables
*Decision:Keep official data only, delete proxy
duplicates tag individual_id , gen(individual_id_dup)
preserve
drop if individual_id_dup==1 & origin_report=="Proxy book"
duplicates report individual_id
duplicates list individual_id
*Note: all duplicates deleted
drop _merge_1 individual_id_dup

*------------5.3: Turn to binary variable report type
gen origin_report_cat=1 if origin_report=="Official book"
replace origin_report_cat =2 if origin_report=="Proxy book"
label var origin_report_cat "Type of book the data originated from"
drop origin_report
label define report_type 1"Official book" 2"Proxy book"
label values origin_report_cat report_type

save "${finaldata}\MMCI_D1.Bodilyhealth_ind_v1_w1_fin.dta", replace

