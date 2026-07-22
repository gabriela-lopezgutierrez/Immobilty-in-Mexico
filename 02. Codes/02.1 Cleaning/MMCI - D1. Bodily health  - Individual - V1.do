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
Note:                  In wave 2 and 3 you keep pid_link (id 2002)
Note:                  Now for every merge do a post validation check with frames
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
rename ls ls_individual
rename ls_str ls_str_individual
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
keep folio folio_str ls ls_str edo mpio loc edad id_loc es01 es05 es15 es16 individual_id _merge_1 ls_str_individual ls_individual

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
label var D2_V1_I4_comphealth "D2_V1_I4. Health compared to similar peers self-assessment"

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
label var ls "Individual ID from cover book"
label var ls_str "Individual ID from cover book"
sort folio ls_individual
save "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w1_finofficial.dta", replace



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
rename ls ls_individual
rename ls_str ls_str_individual
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
keep folio folio_str ls ls_str edo mpio loc edad id_loc es01 es05 es15 es16 individual_id _merge_1 ls_str_individual ls_individual

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
"D2_V1_I4. Proxy = Health compared to similar peers self-assessment"

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
label var ls "Individual ID from cover book"
label var ls_str "Individual ID from cover book"
save "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w1_finproxy.dta", replace


/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

               Merging official with proxy book (Wave 1 ES)
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

*------------5.1: append databases
append using "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w1_finofficial.dta"

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
order panel_wave folio folio_str ls ls_str ls_individual ls_str_individual individual_id loc origin_report_cat,before(edad)
sort folio ls_individual
save "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w1_fin.dta", replace



/*==============================================================================
                     WAVE 2 (PERIOD T-1) - REGULAR BOOK
==============================================================================*/

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                     Variable 1: HS self-perception (ES)
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

/*==============================================================================
 0.General setup / Work environment (Wave 2) and merging                               
==============================================================================*/

set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave II\Individual\hh05dta_b3b - Wave 2"

*------------1.1: Prepare database ES to merge (with individual datasets)
use "${rawdata}\iiib_es"
destring folio, replace force
destring ls, replace force
tostring folio, gen(folio_str) format(%15.0f)
tostring ls, gen(ls_str)
gen individual_id = folio_str + "_" + ls_str
rename ls ls_individual
rename ls_str ls_str_individual
save "${rawdata}\selfperchealth_aux", replace

*------------1.2: Merge with cover data at household level (creating bridge)
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave II\Household\hh05dta_bc - Book C (Control book) W2"
use "${rawdata}\c_portad"
destring folio, replace force
destring ls, replace force
tostring folio, gen(folio_str) format(%15.0f)
tostring ls, gen(ls_str)
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave II\Individual\hh05dta_b3b - Wave 2"
drop if folio==.
duplicates report folio_str
duplicates list folio_str
save "${rawdata}\cbportad_aux", replace

merge 1:m folio_str using "${rawdata}\selfperchealth_aux", generate(_merge_1)
*note: 265 not matched from master

*------------1.3: Keep only relevant data
keep folio folio_str ls ls_str ent mpio loc edad id_loc es01 es05 es15 es16 individual_id _merge_1 pid_link ls_individual ls_str_individual
rename ent edo

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
label var D2_V1_I4_comphealth "D2_V1_I4. Health compared to similar peers self-assessment"


/*==============================================================================
* 4. Save final version - HS Self perception (wave 1)               *
==============================================================================*/

*------------4.1: Seva unmerged dataset at individual level
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
gen panel_wave=2
label var panel_wave "Panel wave from MxFLS"
order panel_wave, b(folio)
gen origin_report="Official book"
label var origin_report "Type of book the data originated from"
label var ls "Individual ID from cover book"
label var ls_str "Individual ID from cover book"
sort folio ls_individual
save "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w2_finofficial.dta", replace



/*==============================================================================
                     WAVE 2 (PERIOD T) - PROXY BOOK
==============================================================================*/

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                     Variable 1: HS self-perception (ES)
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

/*==============================================================================
 0.General setup / Work environment (Wave 2) and merging                               
==============================================================================*/

set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave II\Individual\Book Proxy - Wave 2"

*------------1.1: Prepare database ES to merge (with individual datasets)
use "${rawdata}\p_es"
destring folio, replace force
destring ls, replace force
tostring folio, gen(folio_str) format(%15.0f)
tostring ls, gen(ls_str)
gen individual_id = folio_str + "_" + ls_str
rename ls ls_individual
rename ls_str ls_str_individual
save "${rawdata}\selfperchealth_aux_proxy", replace

*------------1.2: Merge with cover data at household level (creating bridge)
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave II\Household\hh05dta_bc - Book C (Control book) W2"
use "${rawdata}\c_portad"
destring folio, replace force
destring ls, replace force
tostring folio, gen(folio_str) format(%15.0f)
tostring ls, gen(ls_str)
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave II\Individual\Book Proxy - Wave 2"
drop if folio==.
duplicates report folio_str
duplicates list folio_str
save "${rawdata}\cbportad_aux", replace

merge 1:m folio_str using "${rawdata}\selfperchealth_aux_proxy", generate(_merge_1)
*Note: confirms that all from using are matched
drop if _merge_1==1
drop if _merge_1==2

*------------1.3: Keep only relevant data
keep folio folio_str ls ls_str ent mpio loc edad id_loc es01 es05 es16 individual_id _merge_1 pid_link ls_str_individual ls_individual
rename ent edo

/*==============================================================================
 2.Add label variables - HS self perception (wave 2) 
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

/*-----------2.3: Label Likert Scale ES15
label values es15 proxy_phealth_past
tab es15, miss*/
*Note: this variable was deleted for Wave 2

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
/*
rename es15 D2_V1_I3_exphealth_proxy
label var D2_V1_I3_exphealth_proxy ///
"D2_V1_I3. Proxy = Health next week self-assessment"
*/
rename es16 D2_V1_I4_comphealth_proxy
label var D2_V1_I4_comphealth_proxy ///
"D2_V1_I4. Proxy = Health compared to similar peers self-assessment"

/*==============================================================================
* 4. Save final version - HS Self perception (wave 2)               *
==============================================================================*/

*------------4.1: Seva unmerged dataset at individual level
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
gen panel_wave=2
label var panel_wave "Panel wave from MxFLS"
order panel_wave, b(folio)
gen origin_report="Proxy book"
label var origin_report "Type of book the data originated from"
label var ls "Individual ID from cover book"
label var ls_str "Individual ID from cover book"
sort folio ls_individual
save "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w2_finproxy.dta", replace


/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

               Merging official with proxy book (Wave 2 ES)
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

*------------5.1: append databases
append using "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w2_finofficial.dta"

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
*Note: all duplicates deleted
drop _merge_1

*------------5.3: Turn to binary variable report type
gen origin_report_cat=1 if origin_report=="Official book"
replace origin_report_cat =2 if origin_report=="Proxy book"
label var origin_report_cat "Type of book the data originated from"
drop origin_report
label define report_type 1"Official book" 2"Proxy book"
label values origin_report_cat report_type
sort folio ls_individual
order panel_wave folio folio_str ls ls_str ls_individual ls_str_individual pid_link individual_id loc origin_report_cat , before(edad)
save "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w2_fin.dta", replace







/*==============================================================================
                     WAVE 3 (PERIOD T+1) - REGULAR BOOK
==============================================================================*/

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                     Variable 1: HS self-perception (ES)
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

/*==============================================================================
 0.General setup / Work environment (Wave 3) and merging                               
==============================================================================*/

set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave III\Individual\hh09dta_b3b - Wave 3"


*------------1.1: Prepare database ES to merge (with individual datasets)
use "${rawdata}\iiib_es"
gen folio_str="placeholder"
destring ls, replace force
tostring ls, gen(ls_str)
gen individual_id = folio + "_" + ls_str
rename ls ls_individual
rename ls_str ls_str_individual
save "${rawdata}\selfperchealth_aux", replace

*------------1.2: Merge with cover data at household level (creating bridge)
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave III\Household\hh09dta_bc - Book C (Control book) W3"
use "${rawdata}\c_portad"
gen folio_str="placeholder"
destring ls, replace force
tostring ls, gen(ls_str)
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave III\Individual\hh09dta_b3b - Wave 3"
drop if folio==""
duplicates report folio
duplicates list folio
save "${rawdata}\cbportad_aux", replace

merge 1:m folio using "${rawdata}\selfperchealth_aux", generate(_merge_1)
*note: 989 not matched from master
*note: 35 not matched from using

*------------1.3: Keep only relevant data
keep folio folio_str ls ls_str ent mpio loc edad id_loc es01 es05 es15 es16 individual_id _merge_1 pid_link ls_str_individual ls_individual
rename ent edo

/*==============================================================================
 2.Add label variables - HS self perception (wave 3) 
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

*-----------2.2: Label Likert Scale ES16
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
label var D2_V1_I4_comphealth "D2_V1_I4. Health compared to similar peers self-assessment"

/*==============================================================================
* 4. Save final version - HS Self perception (wave 1)               *
==============================================================================*/

*------------4.1: Seva unmerged dataset at individual level
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
gen panel_wave=3
label var panel_wave "Panel wave from MxFLS"
order panel_wave, b(folio)
gen origin_report="Official book"
label var origin_report "Type of book the data originated from"
label var ls "Individual ID from cover book"
label var ls_str "Individual ID from cover book"
sort folio ls_individual
save "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w3_finofficial.dta", replace



/*==============================================================================
                     WAVE 3 (PERIOD T-1) - PROXY BOOK
==============================================================================*/

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                     Variable 1: HS self-perception (ES)
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

/*==============================================================================
 0.General setup / Work environment (Wave 3) and merging                               
==============================================================================*/

set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave III\Individual\Book Proxy - Wave 3"

*------------1.1: Prepare database ES to merge (with individual datasets)
use "${rawdata}\p_es"
gen folio_str="placeholder"
destring ls, replace force
tostring ls, gen(ls_str)
gen individual_id = folio + "_" + ls_str
rename ls ls_individual
rename ls_str ls_str_individual
save "${rawdata}\selfperchealth_aux_proxy", replace

*------------1.2: Merge with cover data at household level (creating bridge)
clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave III\Household\hh09dta_bc - Book C (Control book) W3"
use "${rawdata}\c_portad"
gen folio_str="placeholder"
destring ls, replace force
tostring ls, gen(ls_str)
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.1 Raw data\Wave III\Individual\Book Proxy - Wave 3"
drop if folio==""
duplicates report folio
duplicates list folio
save "${rawdata}\cbportad_aux", replace

merge 1:m folio using "${rawdata}\selfperchealth_aux_proxy", generate(_merge_1)
*Note: confirms that all from using are matched
drop if _merge_1==1
drop if _merge_1==2

*------------1.3: Keep only relevant data
keep folio folio_str ls ls_str ent mpio loc edad id_loc es01 es05 es16 individual_id _merge_1 pid_link ls_str_individual ls_individual
rename ent edo

/*==============================================================================
 2.Add label variables - HS self perception (wave 2) 
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

/*-----------2.3: Label Likert Scale ES15
label values es15 proxy_phealth_past
tab es15, miss*/
*Note: this variable was deleted for Wave 2

*-----------2.2: Label Likert Scale ES16
label define proxy_csca_phealth_compared 1"Much better than the others" ///
2"Better than the others" 3"The same as the others" ///
4"Worse than the others" 5"Much worse than the others" 8"Don't know"
label values es16 proxy_csca_phealth_compared
tab es16, miss

rename es01 D2_V1_I1_acthealth_proxy
label var D2_V1_I1_acthealth_proxy ///
"D2_V1_I1. Proxy = Current health status self-assessment"
rename es05 D2_V1_I2_pasthealth_proxy
label var D2_V1_I2_pasthealth_proxy ///
"D2_V1_I2. Proxy = Comparing of health one year ago self-assesment"
/*
rename es15 D2_V1_I3_exphealth_proxy
label var D2_V1_I3_exphealth_proxy ///
"D2_V1_I3. Proxy = Health next week self-assessment"
*/
rename es16 D2_V1_I4_comphealth_proxy_csca
label var D2_V1_I4_comphealth_proxy_csca ///
"D2_V1_I4. Proxy = Complete scale - Health compared to similar peers self-assessment"

/*==============================================================================
* 4. Save final version - HS Self perception (wave 3)                          *
==============================================================================*/

*------------4.1: Save unmerged dataset at individual level
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
gen panel_wave=3
label var panel_wave "Panel wave from MxFLS"
order panel_wave, b(folio)
gen origin_report="Proxy book"
label var origin_report "Type of book the data originated from"
label var ls "Individual ID from cover book"
label var ls_str "Individual ID from cover book"
sort folio ls_individual
save "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w3_finproxy.dta", replace


/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

               Merging official with proxy book (Wave 3 ES)
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

*------------5.1: append databases
append using "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w3_finofficial.dta"

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
*Note: people who were on official book but without health data there, but
* they appeared on proxy book at the same time, with health data
br if individual_id=="102630AP00_6"
br if individual_id=="056810AP00_3"
drop if _merge==3 & origin_report=="Official book" & D2_V1_I1_acthealth==. ///
& D2_V1_I2_pasthealth==. & D2_V1_I3_exphealth==. & D2_V1_I4_comphealth==.
duplicates report individual_id
duplicates list individual_id
*Note remaining duplicates are people with data on both books (242/121)
*Decision:Keep official data only, delete proxy
br if individual_id=="098630CP02_2"
duplicates tag individual_id , gen(individual_id_dup)
preserve
drop if individual_id_dup==1 & origin_report=="Proxy book"
duplicates report individual_id
duplicates list individual_id
*Note: all duplicates deleted
drop _merge_1

*------------5.3: Turn to binary variable report type
gen origin_report_cat=1 if origin_report=="Official book"
replace origin_report_cat =2 if origin_report=="Proxy book"
label var origin_report_cat "Type of book the data originated from"
drop origin_report
label define report_type 1"Official book" 2"Proxy book"
label values origin_report_cat report_type
drop individual_id_dup
order panel_wave folio folio_str ls ls_str ls_individual ls_str_individual pid_link individual_id loc origin_report_cat , before(edad)
sort folio ls_individual
save "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w3_fin.dta", replace




/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                     Panel merge (MxFLS 1 / MxFLS 2 / MxFLS 3)
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

/*==============================================================================
* PHASE 1: Harmonize variable names and number                                 *
==============================================================================*/

*------------P.1.1: Harmonize variable names & delete incomplete info (Wave 1)
clear all
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
use "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w1_fin.dta"
label var D2_V1_I4_comphealth_proxy ///
"D2_V1_I4. Proxy = Health compared to similar peers self-assessment"
label var D2_V1_I4_comphealth ///
"D2_V1_I4. Health compared to similar peers self-assessment"
save "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w1_fin.dta", replace

*------------P.1.2: Harmonize variable names & delete incomplete info (Wave 2)
clear all
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
use "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w2_fin.dta"
label var D2_V1_I4_comphealth ///
"D2_V1_I4. Health compared to similar peers self-assessment"
save "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w2_fin.dta", replace

/*------------P.1.3: Harmonize variable names & delete incomplete info (Wave 3)
clear all
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
use "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w3_fin.dta"
save "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w3_fin.dta", replace*/

/*==============================================================================
* PHASE 2: Harmonize folio id variable ()                                      *
==============================================================================*/

*------------P.2.1: Harmonize folio variable (Wave 3)
*Do: extract only numerics 
clear all
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
use "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w3_fin.dta"
gen folio_left = substr(folio, 1, 6)
gen folio_right = substr(folio, 9, 10)
gen folio_clean = folio_left + "" + folio_right
drop folio_str
replace folio=folio_clean
drop folio_left folio_right folio_clean
save "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w3_fin.dta", replace

*------------P.2.1: Harmonize folio variable (Wave 2)
*Do: generate trailing zeroes for folio
clear all
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
use "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w2_fin.dta"
gen folio_str_aux = string(folio, "%08.0f")
drop folio
rename folio_str_aux folio
order folio , a( panel_wave)
label var folio "HOUSEHOLD ID 2005"
drop folio_str
save "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w2_fin.dta", replace

*------------P.2.1: Harmonize folio variable (Wave 1)
*Do: generate trailing zeroes for folio
clear all
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
use "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w1_fin.dta"
gen folio_str_aux = string(folio, "%08.0f")
drop folio
rename folio_str_aux folio
order folio , a( panel_wave)
label var folio "Household ID"
drop folio_str
save "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w1_fin.dta", replace


/*==============================================================================
* PHASE 2: Harmonize pidlink                                                   *
==============================================================================*/

*------------P.2.1: Harmonize pid_link variable (Wave 3)
*Do: extract only numerics 
clear all
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
use "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w3_fin.dta"
gen pidlink_left = substr(pid_link, 1, 6)
gen pidlink_right = substr(pid_link, 9, 10)
gen pidlink_clean = pidlink_left + "" + pidlink_right
drop pidlink_right pidlink_left
order pidlink_clean, a(pid_link)
save "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w3_fin.dta", replace


*------------P.2.2: Harmonize pid_link variable (Wave 2)
*Do: extract only numerics 
clear all
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
use "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w2_fin.dta"
*Note: It looks like everything is harmonized
gen pidlink_clean=pid_link
order pidlink_clean, a( pid_link)
save "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w2_fin.dta", replace

*------------P.2.3: Harmonize pid_link variable (Wave 1) 
clear all
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
use "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w1_fin.dta
*I need to create an equal pidlink_clean
*first I need to put leading zeroes on the individual ls as these are the last
*2 digits of a pid_link, 6 first are folio
gen ls_ind_aux = string(ls_individual, "%02.0f")
gen pidlink_clean=folio + "" + ls_ind_aux
drop ls_ind_aux
drop individual_id_dup
order pidlink_clean, after( ls_str_individual)
tostring id_loc, replace
order ls_individual- individual_id, af( ls_str)
save "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w1_fin.dta", replace

/*==============================================================================
* PHASE 3: First append                                                 *
==============================================================================*/

*------------P.3.1: Append waves
clear all
global finaldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
use "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w3_fin.dta"
append using "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w2_fin.dta"
sort pidlink_clean panel
append using "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w1_fin.dta"
sort pidlink_clean panel
global paneldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.3 Panel data"
save "${paneldata}\MMCI_D2.Bodilyhealth_ind_v1_panel.dta", replace


gen origin_report_cat2=1 if origin_report=="Official book"
replace origin_report_cat2 =2 if origin_report=="Proxy book"
label var origin_report_cat2 "Type of book the data originated from"
drop origin_report
label values origin_report_cat2 report_type
replace origin_report_cat=origin_report_cat2 if origin_report_cat==.
drop origin_report_cat2
drop _merge_1
encode pidlink_clean, gen(pid_id)
label var pid_id "Individual constant ID prepared for panel analysis"
duplicates report pid_id panel_wave
duplicates tag pid_id panel_wave, gen(dup)
list pid_link pidlink_clean pid_id folio panel_wave individual_id if dup
duplicates drop pidlink_clean panel_wave, force
*Note: 9 people appear twice on the same wave
order pid_id, after(panel_wave)
drop dup
sort pid_id panel_wave
save "${paneldata}\MMCI_D2.Bodilyhealth_ind_v1_panel.dta", replace

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                 Post-append: Check panel characteristics
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

global paneldata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.3 Panel data"
use "${paneldata}\MMCI_D2.Bodilyhealth_ind_v1_panel.dta"

*------------PC.1: Verify panel characteristics

xtset pid_id panel_wave
xtdescribe
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

save "${paneldata}\MMCI_D2.Bodilyhealth_ind_v1_panel.dta", replace

/*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                  Post-append: Last validation rules for panel merging
						   
<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*/

clear all
global paneldata "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.3 Panel data"
global finaldata "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"
use "${paneldata}\MMCI_D2.Bodilyhealth_ind_v1_panel.dta", clear

*------------VR1: Create frames to do operations on multiple datasets
frame create wave1
frame create wave2
frame create wave3

frame wave1: {
    use "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w1_fin.dta", clear
    keep pidlink_clean folio
    duplicates drop
}

frame wave2: {
    use "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w2_fin.dta", clear
    keep pidlink_clean folio
    duplicates drop
}

frame wave3: {
    use "${finaldata}\MMCI_D2.Bodilyhealth_ind_v1_w3_fin.dta", clear
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

save "${paneldata}\MMCI_D2.Bodilyhealth_ind_v1_panel.dta", replace
