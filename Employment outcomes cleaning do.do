********************************************************************************
*                        Cleaning individual datasets                          *
********************************************************************************

/*

Project:               (Im)mobility in Mexico
Database:              Mexico Life Survey - Wave 1, 2 and 3
Level:                 Individual databases
Book:                  IIIA - Characteristics of adult household members
Subsection:            TB - Employment
Dofile author:         Gabriela Judith López Gutiérrez
Creation date:         May 2026 /20
Modification date:     
Product 1:             Produce unidimensional proxies for capability (unemployment - having a job)
Product 2:             Produce contrasting labour outcomes (unpaid / paid / informality)

*/

////////////////////////////////////////////////////////////////////////////////
* WAVE 1                                                                       *
////////////////////////////////////////////////////////////////////////////////

*------------------------------------------------------------------------------*
* 0.General setup / Work environment (Wave 1)                                  *
* ---------------------------------------------------------------------------- *

global rawdata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.1 Raw data\Wave I\Individual\hh02dta_b3a - Wave 1"
set more off , perm
clear all

*------------------------------------------------------------------------------*
* 1.Import (Wave 1)                                                            *
* ---------------------------------------------------------------------------- *

use "${rawdata}/iiia_tb.dta"
numlabel, add

*------------------------------------------------------------------------------*
* 2.Add label variables - employment status and job type                       *
* ---------------------------------------------------------------------------- *

* Main activity last week
label define main_lw 1"Worked or carried out an activity that helped household expenditure" ///
2"Looked for a job" 3"Attended school" 4"Housemaster / Housewife" 5"Were sick (didnt work)" ///
6"Retired" 7"Didn't work / Nothing" 8"Vacations" 9"Other"

label values tb02_1 main_lw

label define yesno 1"Yes" 3"No"
label values tb03 yesno
label values tb04 yesno
label values tb05 yesno

* Type of job

label define job_type 1"Peasant on your plot" 2"Family worker in a household owned business, without remuneration" 3"Non-agricultural worker or employee" 4"Rural laborer, or land peon (agricultural worker)" ///
5"Boss, employer, or business proprietor" 6"Self-employed worker (with or without non-remunerated worker)" ///
7"Worker without remuneration from a business or company that is not his own"

label values tb32p job_type
label values tb32s job_type

* Contract type
label define contract 1"Written contract" 0"Verbal contract"

* Social security
label define social_sec 1"Has social security" 0"Does not have social security"

global intdata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.2 Intermediate data"
save "${intdata}/employment_w1.dta"

*------------------------------------------------------------------------------*
* 3. Generate variables - labour outcomes (t-1 period)                         *
* ---------------------------------------------------------------------------- *

clear all
use "${intdata}/employment_w1.dta"

* Note: for the description of labour outcomes I'm following Wang (2016) -
* Male Migration and Female Labor
* Market Attachment: New Evidence
* From the Mexican Family Life Survey1

*This variable captures a person who had an income generating job recently
gen recent_anyjob= (tb02_1==1 | tb03==1 | tb05==1)

* This variable subdivides job status into formal / informal

* Concept: Formal workers are those who are non-agricultural wage employees and have ///
* either written contracts or social security coverage *
gen formal_worker_a= (tb32p==3 & tb33p_a==1)
gen formal_worker_b= (tb32p==3 & tb33p_b==1)
gen formal_worker_c= (tb32p==3 & tb33s_d==1)
gen formal_worker_d= (tb32p==3 & tb33s_e==1)
gen formal_worker_e= (tb32p==3 & tb33s_f==1)
gen formal_worker_f= (tb32p==3 & tb33s_g==1)

egen formal_total=rowtotal(formal_worker_*)

label define formality 0"Informal" 1"Formal"
label values formal_total formality
replace formal_total=. if tb02_1==3
replace formal_total=. if tb02_1==4
replace formal_total=. if tb02_1==6

preserve
tostring folio ls, replace
gen hh_person_id= folio + "_" + ls

keep tb02_1 tb03 tb04 tb05 tb06 tb32p tb33p_a tb33p_b tb33p_c tb33p_d tb33p_e tb33p_f tb33p_g tb33p_h formal_total hh_person_id folio ls

global finaldata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.3 Final data"
save "${finaldata}/employment_w1_fin.dta"

*------------------------------------------------------------------------------*
* 3. Merge with demographic data (t-1 period)                                  *
* ---------------------------------------------------------------------------- *

clear all
global rawdata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.1 Raw data\Wave I\Household\hh02dta_bc - Book C (Control book) W1"
use "${rawdata}/c_ls.dta"

preserve
tostring folio ls, replace
gen hh_person_id= folio + "_" + ls

save "${intdata}/household_char.dta"


cd "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.3 Final data"


merge 1:1 hh_person_id using employment_w1_fin.dta
global finaldata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.3 Final data"
save "${finaldata}/employment_w1_merg.dta"
