**NOTE: CHECK FOR SHEEPSKIN EFFECTS IN TWINS

tab cont_name, gen(cont_name)

*THESE FOLLOWING THREE LINES ARE NICE, BUT VERY SIMPLE (Good story)
reg attendance fert age6-age16 yearc1-yearc88 cont_name1-cont_name3 /*
*/ if age>5 & age<17
outreg2 using $Base\Results\Outreg\Attendance\Attendance_cont.xls, excel replace
ivreg2 attendance (fert=twind) age6-age16 yearc1-yearc88 cont_name1-cont_name3/*
*/ if age>5 & age<17
outreg2 using $Base\Results\Outreg\Attendance\Attendance_cont.xls, excel append
ivreg2 attendance (fert=twind) age6-age16 educfyrs height bmi poor1 /*
*/ yearc1-yearc88 cont_name1-cont_name3 if age>5 & age<17 
outreg2 using $Base\Results\Outreg\Attendance\Attendance_cont.xls, excel append
ivreg2 attendance (fert=twind) age6-age16 educmale1- educmale6 educfyrs1- educfyrs28 height bmi poor1 /*
*/ yearc1-yearc88 cont_name1-cont_name3 if age>5 & age<17 
outreg2 using $Base\Results\Outreg\Attendance\Attendance_cont.xls, excel append


foreach x in one two three four five six {
reg attendance fert age6-age16 yearc1-yearc88 cont_name1-cont_name3 /*
*/ borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 if age>5 & age<17 & `x'_plus==1
outreg2 using $Base\Results\Outreg\Attendance\Attendance_cont.xls, excel append
ivreg2 attendance (fert=twin_`x'_fam) age6-age16 yearc1-yearc88 /*
*/cont_name1-cont_name3 borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 if age>5 & age<17 & `x'_plus==1
outreg2 using $Base\Results\Outreg\Attendance\Attendance_cont.xls, excel append
ivreg2 attendance (fert=twin_`x'_fam) age6-age16 educfyrs height /*
*/bmi poor1 yearc1-yearc88 cont_name1-cont_name3 borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 if age>5 & age<17 & `x'_plus==1 
outreg2 using $Base\Results\Outreg\Attendance\Attendance_cont.xls, excel append
ivreg2 attendance (fert=twin_`x'_fam) age6-age16 educmale1- educmale6 educfyrs1- educfyrs28 height /*
*/bmi poor1 yearc1-yearc88 cont_name1-cont_name3 borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 if age>5 & age<17 & `x'_plus==1 
outreg2 using $Base\Results\Outreg\Attendance\Attendance_cont.xls, excel append
}



*______________________________________________________________________________*
*																			   *
*TRY WITH YEARS OF EDUCATION FOR THOSE OLDER THAN 16
reg eduyears fert age17-age38 yearc1-yearc88 cont_name1-cont_name3 /*
*/ if age>16
outreg2 using $Base\Results\Outreg\Attendance\Eduyears_cont.xls, excel replace
ivreg2 eduyears (fert=twind) age17-age38 yearc1-yearc88 cont_name1-cont_name3/*
*/ if age>16
outreg2 using $Base\Results\Outreg\Attendance\Eduyears_cont.xls, excel append
ivreg2 eduyears (fert=twind) age17-age38 educfyrs height bmi poor1 /*
*/ yearc1-yearc88 cont_name1-cont_name3 if age>16
outreg2 using $Base\Results\Outreg\Attendance\Eduyears_cont.xls, excel append
ivreg2 eduyears (fert=twind) age17-age38 educmale1- educmale6 educfyrs1- educfyrs28 height bmi poor1 /*
*/ yearc1-yearc88 cont_name1-cont_name3 if age>16
outreg2 using $Base\Results\Outreg\Attendance\Eduyears_cont.xls, excel append

foreach x in one two three four {
reg eduyears fert age17-age38 yearc1-yearc88 cont_name1-cont_name3 /*
*/ borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 if age>16 & `x'_plus==1
outreg2 using $Base\Results\Outreg\Attendance\Eduyears_cont.xls, excel append
ivreg2 eduyears (fert=twin_`x'_fam) age17-age38 yearc1-yearc88 /*
*/cont_name1-cont_name3 borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 if age>16 & `x'_plus==1
outreg2 using $Base\Results\Outreg\Attendance\Eduyears_cont.xls, excel append
ivreg2 eduyears (fert=twin_`x'_fam) age17-age38 educfyrs height /*
*/bmi poor1 yearc1-yearc88 cont_name1-cont_name3 borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 if age>16 & `x'_plus==1 
outreg2 using $Base\Results\Outreg\Attendance\Eduyears_cont.xls, excel append
ivreg2 eduyears (fert=twin_`x'_fam) age17-age38 educmale1- educmale6 educfyrs1- educfyrs28 height /*
*/bmi poor1 yearc1-yearc88 cont_name1-cont_name3 borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 if age>16 & `x'_plus==1 
outreg2 using $Base\Results\Outreg\Attendance\Eduyears_cont.xls, excel append
}

*______________________________________________________________________________*
*																			   *

*THESE FOLLOWING THREE LINES ARE NICE, BUT VERY SIMPLE (Good story)
reg gap fert age6-age16 yearc1-yearc88 cont_name1-cont_name3 /*
*/ if age>5 & age<17
outreg2 using $Base\Results\Outreg\Attendance\gap_cont.xls, excel replace
ivreg2 gap (fert=twind) age6-age16 yearc1-yearc88 cont_name1-cont_name3/*
*/ if age>5 & age<17
outreg2 using $Base\Results\Outreg\Attendance\gap_cont.xls, excel append
ivreg2 gap (fert=twind) age6-age16 educfyrs height bmi poor1 /*
*/ yearc1-yearc88 cont_name1-cont_name3 if age>5 & age<17 
outreg2 using $Base\Results\Outreg\Attendance\gap_cont.xls, excel append
ivreg2 gap (fert=twind) age6-age16 educmale1- educmale6 educfyrs1- educfyrs28 height bmi poor1 /*
*/ yearc1-yearc88 cont_name1-cont_name3 if age>5 & age<17 
outreg2 using $Base\Results\Outreg\Attendance\gap_cont.xls, excel append

foreach x in one two three four {
reg gap fert age6-age16 yearc1-yearc88 cont_name1-cont_name3 /*
*/ borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 if age>5 & age<17 & `x'_plus==1
outreg2 using $Base\Results\Outreg\Attendance\gap_cont.xls, excel append
ivreg2 gap (fert=twin_`x'_fam) age6-age16 yearc1-yearc88 /*
*/cont_name1-cont_name3 borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 if age>5 & age<17 & `x'_plus==1
outreg2 using $Base\Results\Outreg\Attendance\gap_cont.xls, excel append
ivreg2 gap (fert=twin_`x'_fam) age6-age16 educfyrs height /*
*/bmi poor1 yearc1-yearc88 cont_name1-cont_name3 borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 if age>5 & age<17 & `x'_plus==1 
outreg2 using $Base\Results\Outreg\Attendance\gap_cont.xls, excel append
ivreg2 gap (fert=twin_`x'_fam) age6-age16 educmale1- educmale6 educfyrs1- educfyrs28 height /*
*/bmi poor1 yearc1-yearc88 cont_name1-cont_name3 borddummy2 borddummy3 borddummy4 borddummy5 borddummy6 if age>5 & age<17 & `x'_plus==1 
outreg2 using $Base\Results\Outreg\Attendance\gap_cont.xls, excel append
}

*______________________________________________________________________________*
*																			   *
rename twin_one_fam twin2fam 
rename twin_two_fam twin3fam
rename twin_three_fam twin4fam
rename twin_four_fam twin5fam
