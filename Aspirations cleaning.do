/*==============================================================================
                      Cleaning individual datasets                          
==============================================================================*/
/*

Project:               (Im)mobility in Mexico
Database:              Mexico Life Survey - Wave 1, 2 and 3
Level:                 Individual databases
Book:                  IIIA - Characteristics of adult household members
Subsection:            MG - Permanent migration
Dofile author:         Gabriela Judith López Gutiérrez
Creation date:         May 2026
Modification date:     
Product 1:             Aspiration to migrate variable created

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
 1.Import (Wave 1 or t-1 period)                                                            
==============================================================================*/

use "${rawdata}/iiia_mg.dta"
numlabel, add

/*==============================================================================
 2.Add label variables - aspirations (wave 1 or t-1 period)
==============================================================================*/

*------------2.1: State of birth label
label define state 1 "Aguascalientes" 2 "Baja California" ///
3 "Baja California Norte" 4 "Campeche" ///
5 "Coahuila" 6 "Colima" 7 "Chiapas" 8 "Chihuahua" 9 "Distrito Federal"  ///
10 "Durango" 11 "Guanajuato" 12 "Guerrero" 13 "Hidalgo" 14 "Jalisco"  ///
15 "Mexico" 16 "Michoacan" 17 "Morelos" 18 "Nayarit" 19 "Nuevo Leon" ///
20 "Oaxaca" 21 "Puebla" 22 "Queretaro" 23 "Quintana Roo" 24 "San Luis Potosi" ///
25 "Sinaloa" 26 "Sonora" 27 "Tabasco" 28 "Tamaulipas" 29 "Tlaxcala" ///
30 "Veracruz" 31 "Yucatan" 32 "Zacatecas" 33 "State in another country"

label values mg01e_2 state
tab mg01e_2

*------------2.2: Migration thought
label define thoughtmig 1 "Yes" 3 "No"
label values mg34 thoughtmig

*------------2.3: Type of locality move
label define type_loc 1"Specify" 3"Same" 8"DK"
foreach var in mg01e_1 mg35e_1 mg01l_1 mg35l_1 mg01m_1 mg35m_1 mg01p_1 mg35p_1 {
    label values `var' type_loc

global intdata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.2 Intermediate data"
save "${intdata}/aspirations_w1_int.dta"

/*==============================================================================
 3.Generate variables - aspirations (wave 1 or t-1 period)
==============================================================================*/

global intdata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.2 Intermediate data"
clear all
use "${intdata}/aspirations_w1_int.dta"

keep folio ls mg34 mg36_*
gen asp_wave1 = mg34
label define aspiration 1"Desires to migrate" 3"Does not desire to migrate"
label values asp_wave1 aspiration

label var asp_wave1 "Aspiration to migrate in Wave 1 (t-1)"

global finaldata= "C:\Users\hp\Desktop\Thesis\Stata procedure\01. Data\01.3 Final data"
save "${finaldata}/aspirations_w1_fin.dta"
