/*==============================================================================
                      Bulding background figures                          
==============================================================================*/
/*

Project:               (Im)mobility in Mexico
Database:              IDRC Data and EM-DATA
Level:                 Not applicable (macro data)
Books:                 Not applicable (macro data)
Subsection:            Not applicable (macro data)
Dofile author:         Gabriela Judith López Gutiérrez
Creation date:         July 2026 /08
Modification date:     
Product 1:             Obtain figure 4 CID versus affected by climate shocks
Note 1:                For this figure I used manually merged and prepared data in excel using
                       the exported excel files created with stata previously

*/
/*==============================================================================
 0.General setup / Work environment (Wave 1)                                  
==============================================================================*/

clear all
global rawdata= "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.4 Merged data"
set more off , perm

/*==============================================================================
 1.Import (global data) and keep only relevant data                                                          
==============================================================================*/
import excel "${rawdata}\Table 1BS. Affected disaster and displacement comparison Mexico.xlsx", firstrow clear

gen Percentage2=Percentage*100

* Create shifted x-axis positions
gen Year_left  = Year - 0.18
gen Year_right = Year + 0.18

/*==============================================================================
 3. Create and save graph                                                       
==============================================================================*/
cd "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\03. Output\03.2 Figures"

twoway ///
(bar Totalaffected Year_left, ///
    barw(0.40) ///
    color(gs10) ///
    lcolor(none) ///
    lwidth(vthin)) ///
(bar Totaldisplaced Year_right, ///
    barw(0.40) ///
    color(navy) ///
    lcolor(none) ///
    lwidth(vthin)) ///
, ///
legend(order(1 "People affected" ///
             2 "Internally displaced") ///
       rows(1) ///
       position(6) ///
       size(vsmall) ///
       region(lcolor(none) fcolor(none))) ///
xtitle("Year", size(small)) ///
ytitle("People", size(small) margin(small)) ///
xlabel(2008(1)2025, angle(90) labsize(small) nogrid) ///
ylabel(0(500000)4000000, format(%12.0fc) angle(horizontal) labsize(small) ///
nogrid) ///
graphregion(color(white) margin(l-9 r+2)) ///
plotregion(color(white)) ///
title("") ///
note("")

graph export fig5_affected_vs_displaced.svg, replace
