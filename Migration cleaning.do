/*==============================================================================
                      Cleaning individual datasets                          
==============================================================================*/
/*

Project:               (Im)mobility in Mexico
Database:              Mexico Life Survey - Wave 2 and 3
Level:                 Individual databases
Book:                  IIIA - Characteristics of adult household members
Subsection(s):         MG - Permanent Migration
                       MT - Temporary Migration
Dofile author:         Gabriela Judith López Gutiérrez
Creation date:         May 2026 /26
Modification date:    
Product 1:             Produce permanent migration variable for post-waves
Product 2:             Produce temporary migration variable for post-waves

*/

/*==============================================================================
                    Wave 2 or period t (permanent migration)
==============================================================================*/

/*==============================================================================
 0.General setup / Work environment (Wave 2)                                  
==============================================================================*/

set more off , perm
clear all
global rawdata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.1 Raw data\Wave II\Individual\hh05dta_b3a - Wave 2"

/*==============================================================================
 1.Import (Wave 2)                                                            
==============================================================================*/

use "${rawdata}/iiia_mg.dta"
numlabel, add

/*==============================================================================
 2.Generate labels (Wave 2)                                                            
==============================================================================*/
label define migration 1"Yes, migrated (wave 2)" 3"Did not migrate (wave 2)"
label values mg08a_1 migration

global intdata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.2 Intermediate data"
save "${intdata}/perm_mig_w2_int.dta", replace

/*==============================================================================
 3.Generate variables (Wave 2)                                                            
==============================================================================*/

