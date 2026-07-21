/*==============================================================================
                   MMCI - Cleaning individual level variables                  
==============================================================================*/
/*

Project:               (Im)mobility in Mexico
Database:              Mexico Life Survey - Wave 1, 2 and 3
Level:                 Individual databases
Book:                  Book IIIB - Characteristics of Adult Household Members
Subsection:            ES - Health condition
Dofile author:         Gabriela Judith López Gutiérrez
Creation date:         July 2026 /10
Modification date:     June 2026 /20
Product 1:             Produce MMCI Dimension 2. Variable 1
Nussbaum 10:           Bodily health
Dimension (study):
Variable:              Health status self-perception
Flow:                  1. Merge database with cover data
                       2. Keep only relevant variables
					   3. Value labels and generate variables
					   4. Repeat per wave
					   5. Create panel
Changes per wave:      
Note:                  Only HH members 15 years old or older answer
Keys community:        communitary id joins cover data with community data
Keys hh level:         HH id joins cover data with hh level data
Keys two levels:       Locality id joins community with hh-level data
Note:                  IDs are a combination of (folio + ls)
Note:                  Folio needs to be turn into string first
				
*/

/*==============================================================================
                           WAVE 1 (PERIOD T-1)
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


*------------1.1: Merge with cover data at household level (creating bridge)
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