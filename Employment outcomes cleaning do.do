/*==============================================================================

                      Cleaning individual datasets                          
==============================================================================*/
/*

Project:               (Im)mobility in Mexico
Database:              Mexico Life Survey - Wave 1, 2 and 3
Level:                 Individual databases
Book:                  IIIA - Characteristics of adult household members
Subsection:            TB - Employment
Dofile author:         Gabriela Judith López Gutiérrez
Creation date:         May 2026 /20
Modification date:     
Product 1:             Produce unidimensional proxies for capability 
                       (unemployment - having a job)
Product 2:             Produce contrasting labour outcomes 
                       (unpaid / paid / informality)

*/

/*==============================================================================
                            Wave 1 or period t-1
==============================================================================*/

/*==============================================================================
 0.General setup / Work environment (Wave 1)                                  
==============================================================================*/

global rawdata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.1 Raw data\Wave I\Individual\hh02dta_b3a - Wave 1"
set more off , perm
clear all

/*==============================================================================
 1.Import (Wave 1)                                                            
==============================================================================*/

use "${rawdata}/iiia_tb.dta"
numlabel, add

/*==============================================================================
 2.Add label variables - employment status and job type (wave 1)      
==============================================================================*/

*------------2.1: Label main activity last week
label define main_lw 1"Worked or carried out an activity that helped hh expenditure" ///
2"Looked for a job" 3"Attended school" ///
4"Housemaster / Housewife" 5"Were sick (didnt work)" ///
6"Retired" 7"Didn't work / Nothing" 8"Vacations" 9"Other"

label values tb02_1 main_lw

*------------2.2: Label yesno employment related variables

label define yesno 1"Yes" 3"No"
label values tb03 yesno
label values tb04 yesno
label values tb05 yesno

*------------2.3: Label for job type

label define job_type 1"Peasant on your plot" ///
2"Family worker in a household owned business, without remuneration" ///
3"Non-agricultural worker or employee" ///
4"Rural laborer, or land peon (agricultural worker)" ///
5"Boss, employer, or business proprietor" ///
6"Self-employed worker (with or without non-remunerated worker)" ///
7"Worker without remuneration from a business or company that is not his own"

label values tb32p job_type
label values tb32s job_type

*------------2.4: Label contract type for informality
label define contract 1"Written contract" 0"Verbal contract"

*------------2.5: Label social security for informality
label define social_sec 1"Has social security" 0"Does not have social security"

*------------2.6: Label income reporting format
label define inc_report 1"Reported detailed income" 3"Reported total income" ///
8"Did not know"
label values tb35a_1 inc_report
label values tb35b_1 inc_report
label values tb36a_1 inc_report
label values tb36b_1 inc_report

*------------2.7: Label income gross and net format
label define inc_balance 1"Income/gross profits" 2"Income/net profits" ///
8"Did not know"
label values 


*------------2.6: Save intermediate dataset
global intdata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.2 Intermediate data"
save "${intdata}/employment_w1.dta", replace

*------------------------------------------------------------------------------*
* 3. Generate variables - labour outcomes (t-1 period)                         *
* ---------------------------------------------------------------------------- *

clear all
use "${intdata}/employment_w1.dta"
numlabel, add

*------------3.1: Recent job or activity
gen recent_anyjob= (tb02_1==1 | tb03==1 | tb04==1 | tb05==1)
label define anyjob 1"Has had a paid/unpaid job recently" ///
0"Has not had a paid/unpaid job recently"
label values recent_anyjob anyjob

*------------3.2: Number of jobs
gen total_jobs=!missing(tb32p)+!missing(tb32s)
label define total_jobs 1"Has primary job only" 2"Has secondary job" ///
0"Does not have a job"
label values total_jobs total_jobs

** br total_jobs tb32s tb32p if tb32s!=. & tb32p==.
** Note: two persons automatically reclasified as primary job

*------------3.3: Monthly monetary compensation (main job) - workers 
gen month_monetarycomp = (tb35a_2 > 0 & tb35a_2!=.) | ///
(tb35aa_2 > 0 & tb35aa_2!=.) | (tb35ab_2 > 0 & tb35ab_2!=.) | ///
(tb35ac_2 > 0 & tb35ac_2!=.) | (tb35ad_2 > 0 & tb35ad_2!=.)
**Note: I don't know what to assume other as
**Note: Confirm that variable mostly has values for workers not self-employed
**tab tb32p month_monetarycomp
**Note: Aggregate income reports are assumed to reflect monetary compensation

*------------3.4: Monthly non-monetary compensation (main job) - workers 
gen month_nonmonetarycomp = (tb35ae_2 > 0 & tb35ae_2!=.) | ///
(tb35af_2 > 0 & tb35af_2!=.) | (tb35ag_2 > 0 & tb35ag_2!=.) | ///
(tb35ah_2 > 0 & tb35ah_2!=.) 
**Note: I don't know what to assume other as
**Note: Confirm that variable mostly has values for workers not self-employed
**tab tb32p month_nonmonetarycomp

*-----------3.4b: Verify that all wage workers and rural peons are included
tab month_monetarycomp month_nonmonetarycomp if tb32p==3 | tb32p==4
** Note n=1,651 did not report monthly income detailed or total amounts
** Note: a quick browse suggests that they reported at annual level instead
** Note: even though they were recorded as reporting at monthly levels
** br tb32p tb35a_1 tb35a_2 tb35aa_2 tb35ab_2 tb35ac_2 tb35ad_2 tb35ae_2 tb35af_2 tb36a_2 tb36aa_2 tb36ab_2 tb36ac_2 tb36ad_2 tb36ae_2 tb36af_2 tb36ag_2 tb36ah_2 tb36ai_2 tb36aj_2 tb36ak_2 tb36al_2 tb36am_21 tb35ag_2 tb35ah_2 tb35ai_21 if month_monetarycomp==0 & month_nonmonetarycomp==0 & (tb32p==3 | tb32p==4)
*

*-----------3.5: Aggregate monthly compensation type - workers
gen month_comptype=.
replace month_comptype=2 if month_monetarycomp==1 & month_nonmonetarycomp==1
replace month_comptype=1 if month_monetarycomp==1 & month_nonmonetarycomp==0
replace month_comptype=0 if month_monetarycomp==0 & month_nonmonetarycomp==1

*------------3.6: Yearly monetary compensation (main job) - workers 
gen yearly_monetarycomp = (tb36a_2 > 0 & tb36a_2!=.) | ///
(tb36aa_2 > 0 & tb36aa_2!=.) | (tb36ab_2 > 0 & tb36ab_2!=.) | ///
(tb36ac_2 > 0 & tb36ac_2!=.) | (tb36ad_2 > 0 & tb36ad_2!=.) | ///
(tb36ae_2 > 0 & tb36ae_2!=.) | (tb36af_2 > 0 & tb36af_2!=.) | ///
(tb36ag_2 > 0 & tb36ag_2!=.) | (tb36ah_2 > 0 & tb36ah_2!=.)
**Note: I don't know what to assume other as
**Note: Confirm that variable mostly has values for workers not self-employed
**tab tb32p yearly_monetarycomp
**Note: Aggregate income reports are assumed to reflect monetary compensation

*------------3.7: Yearly non-monetary compensation (main job) - workers 
gen yearly_nonmonetarycomp = (tb36ai_2 > 0 & tb36ai_2!=.) | ///
(tb36aj_2 > 0 & tb36aj_2!=.) | (tb36ak_2 > 0 & tb36ak_2!=.) | ///
(tb36al_2 > 0 & tb36al_2!=.) 
**Note: I don't know what to assume other as
**Note: Confirm that variable mostly has values for workers not self-employed
**tab tb32p yearly_nonmonetarycomp

tab yearly_monetarycomp yearly_nonmonetarycomp if tb32p==3 | tb32p==4

*-----------3.8: Aggregate yearly compensation type - workers
gen yearly_comptype=.
replace yearly_comptype=2 if yearly_monetarycomp==1 & yearly_nonmonetarycomp==1
replace yearly_comptype=1 if yearly_monetarycomp==1 & yearly_nonmonetarycomp==0
replace yearly_comptype=0 if yearly_monetarycomp==0 & yearly_nonmonetarycomp==1

*------------3.7: Receives monetary income variable - workers 
*Note:(add those that did not know?)
gen worker_withinc = (month_comptype==2 | month_comptype==1 | yearly_comptype==2 | yearly_comptype==1)
replace worker_withinc=1 if (tb36b_2>0  & tb36b_2!=.) | (tb35b_2>0  & tb35b_2!=.) 
*Add those with income from secondary job
tab worker_withinc if tb32p==3 | tb32p==4
label define paycat 1"Paid work/business" 0"Unpaid work/business"
label values worker_withinc paycat


* Informality: legal definition (social security)
gen formal_worker = tb32p==3 & (tb33p_a==1 | tb33p_b==1 | tb33s_d==1 | ///
     tb33s_e==1 | tb33s_f==1 | tb33s_g==1)
	 
	 
label define formality 0"Informal" 1"Formal"
label values formal_total formality
replace formal_total=. if tb02_1==3
replace formal_total=. if tb02_1==4
replace formal_total=. if tb02_1==6

preserve
tostring folio ls, replace
gen hh_person_id= folio + "_" + ls

keep tb02_1 tb03 tb04 tb05 tb06 tb32p tb33p_a tb33p_b tb33p_c tb33p_d ///
tb33p_e tb33p_f tb33p_g tb33p_h formal_total hh_person_id folio ls

global finaldata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.3 Final data"
save "${finaldata}/employment_w1_fin.dta", replace

*------------------------------------------------------------------------------*
* 3. Merge with demographic data (t-1 period)                                  *
* ---------------------------------------------------------------------------- *

clear all

global rawdata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.1 Raw data\Wave I\Household\hh02dta_bc - Book C (Control book) W1"
use "${rawdata}/c_ls.dta"
numlabel, add

preserve
tostring folio ls, replace
gen hh_person_id= folio + "_" + ls

save "${intdata}/household_char.dta"


cd "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.3 Final data"


merge 1:1 hh_person_id using employment_w1_fin.dta
global finaldata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.3 Final data"
save "${finaldata}/employment_w1_merg.dta"
