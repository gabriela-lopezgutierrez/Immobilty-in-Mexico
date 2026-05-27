/*==============================================================================
                      Cleaning individual datasets                          
==============================================================================*/
/*

Project:               (Im)mobility in Mexico
Database:              Mexico Life Survey - Wave 1, 2 and 3
Level:                 Household databases
Books:                 Book C - Control Book
Subsection:            LS - Household Roster
Dofile author:         Gabriela Judith López Gutiérrez
Creation date:         May 2026 /25
Modification date:     
Product 1:             Clean demographic data for cross-tabulations
Product 2:             Clean demographic data for control variables

*/
/*==============================================================================
                            Wave 1 or period t-1
==============================================================================*/

/*==============================================================================
 0.General setup / Work environment (Wave 1)                                  
==============================================================================*/
clear all
global rawdata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.1 Raw data\Wave I\Household\hh02dta_bc - Book C (Control book) W1"
set more off , perm

/*==============================================================================
 1.Import (Wave 1)                                                            
==============================================================================*/
use "${rawdata}/c_ls.dta"
numlabel, add

/*==============================================================================
 2.Add label variables - demographics (wave 1)
==============================================================================*/

*------------2.1: Label gender
label define gender 1"Male" 3"Female"
label values ls04 gender

*------------2.2: Label relationship with household head
label define rel_hh 1"Household head" 2"Spouse/couple" 3"Son/faughter" ///
4"Stepson/daughter" 5"Son/faughter in law" 6"Father/mother" ///
7"Father/mother in law" 8"Brother/sister" 9"Brother/sister in law" ///
10"Grandson/granddaughter" 11"Grandfather/grandmother" 12"Uncle/aunt" ///
13"Nephew/niece" 14"Cousin" 15"Worker" 16"Other"
label values ls05_1 rel_hh

*------------2.3: Label yes no variables
label define yesno 1"Yes" 3"No"
foreach var in ls09 ls12 ls13_1 ls16 {
    label values `var' yesno
}

*------------2.4: Label marital status
label define marital 1"Concubinage" 2"Separated" 3"Divorced" 4"Widow" ///
5"Married" 6"Single"
label values ls10 marital

*------------2.5: Label education level
label define last_education 1"Without instruction" 2"Preeschool or kinder" ///
3"Elementary" 4"Secondary" 5"Open secondary" 6"High school" ///
7"Open High school" 8"Normal basic" 9"College" 10"Graduate" 98"Does not know"
label values ls14 last_education

global interdata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.2 Intermediate data"
save "${interdata}/demographics_w1_int.dta", replace

/*==============================================================================
 3.Generate variables - demographics (wave 1)
==============================================================================*/

clear all
global interdata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.2 Intermediate data"
use "${interdata}/demographics_w1_int.dta"
numlabel, add

*------------3.1: Generate age categories
recode ls02_2 (0/12=1 "Child") (13/17=2 "Teenager") (18/29=3 "Young adult") ///
(30/44=4 "Adult") (45/64=5 "Middle age") (65/max=6 "Older adult"), ///
gen(age_cat)

*------------3.2: Generate college education
gen college = (ls14>=9 & ls14!=98 & ls14!=.)
label define college 1"Has college education" 0"Doesn't have college education"
label values college college

*------------3.3: Generate highschool education
gen highschool_edu=1 if ls14>=6 & ls14!=98 & ls14!=.
replace highschool_edu=0 if ls14<6
label define highschool 1"Has highschool education" ///
0"Doesn't have highschool education"
label values highschool_edu highschool

*------------3.4: Generate education
gen educated=1 if ls14>1 & ls14!=98 & ls14!=.
replace educated=0 if ls14==1
label define educated 1"Has education" 0"Does not have education"
label values educated educated

global finaldata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.3 Final data"
save "${finaldata}/demographics_w1_fin.dta", replace