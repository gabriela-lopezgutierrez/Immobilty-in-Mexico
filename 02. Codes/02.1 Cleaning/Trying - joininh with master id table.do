/*==============================================================================
                   TRIAL - JOINING TO MASTER ID LIST                 
==============================================================================*/
gen pid_link_str = string(pid_link, "%010.0f")
encode pid_link_str, gen(pid_id)


global paneldata "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.3 Panel data"
global finaldata "C:\Users\hp\Desktop\Dissertation\Dissertation procedure\01. Data\01.2 Final data"

merge 1:m pidlink_clean using "${paneldata}\MMCI_D5.Bodilyinteg_ind_allvars_panel.dta", generate(_merge_master)
merge m:m pidlink_clean using "${paneldata}\MMCI_D2.Bodilyhealth_ind_v1_panel.dta", generate(_merge_master2) force

save "${paneldata}\MxFLS_MMCI_master_panel.dta", replace