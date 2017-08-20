*=====================================================================================
* Name:                 runvSPD.gms
* Function:             This file is invoked to control the entire operation of vSPD.
* Developed by:         Electricity Authority, New Zealand
* Source:               https://github.com/ElectricityAuthority/vSPD
*                       http://www.emi.ea.govt.nz/Tools/vSPD
* Contact:              Forum: http://www.emi.ea.govt.nz/forum/
*                       Email: emi@ea.govt.nz
* Last modified on:     23 Sept 2016
*=====================================================================================


$call clear
$onecho > con
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*+++++++++++++++++++++ EXECUTING vSPD v3.0.0 +++++++++++++++++++++
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
$offecho


*=====================================================================================
*Include paths and settings files
*=====================================================================================
$include vSPDsettings.inc


*=====================================================================================
* Create a progress report file
*=====================================================================================
File rep "Write a progess report" /"ProgressReport.txt"/ ;  rep.lw = 0 ;
putclose rep "Run: '%runName%'" //
             "runvSPD started at: " system.date " " system.time;


*=====================================================================================
* Define external files
*=====================================================================================
Files
temp       "A temporary, recyclable batch file"
vSPDcase   "The current input case file"      / "vSPDcase.inc" /;
vSPDcase.lw = 0 ;   vSPDcase.sw = 0 ;


*=====================================================================================
* Install the set of input GDX file names over which the solve and reporting loops will operate
*=====================================================================================
$Onempty
Set i_fileName(*) 'Input GDX file names'
$include vSPDfileList.inc
;
$Offempty

*=====================================================================================
* Compiling vSPDModel if required
* Establish the output folders for the current job
* Copy program codes for repeatability and reproducibility
*=====================================================================================
rep.ap = 1 ;
putclose rep "vSPDsetup started at: " system.date " " system.time ;

* Invoke vSPDmodel if license type is developer (licenseMode=1)
$if %licenseMode%==1 $call gams vSPDmodel.gms s=vSPDmodel
$if errorlevel 1     $abort +++ Check vSPDmodel.lst for errors +++

execute 'rm -rf "%outputPath%%runName%" '
execute 'rm -rf "%programPath%lst"';
execute 'mkdir "%programPath%lst"';
execute 'mkdir "%outputPath%%runName%/Programs"';
execute 'cp vSPD*.inc "%outputPath%%runName%/Programs"'
execute 'cp *.gms "%outputPath%%runName%/Programs"'

$ifthen exist "%ovrdPath%%vSPDinputOvrdData%.gdx"
  execute 'mkdir "%outputPath%%runName%/Override"'
  execute 'cp "%ovrdPath%%vSPDinputOvrdData%.gdx" "%outputPath%%runName%/Override"'
$endif

$iftheni %opMode%=='PVT'
  execute 'mkdir "%outputPath%%runName%/Programs/Pivot"'
  execute 'cp "Pivot/*.*" "%outputPath%%runName%/Programs/Pivot"'
$elseifi %opMode%=='DPS' execute 'gams Demand/DPSreportSetup.gms'
  execute 'mkdir "%outputPath%%runName%/Programs/Demand"'
  execute 'cp "Demand/*.*" "%outputPath%%runName%/Programs/Demand"'
$elseifi %opMode%=='FTR' execute 'gams FTRental/FTRreportSetup.gms'
  execute 'cp FTR*.inc "%outputPath%%runName%/Programs"'
  execute 'mkdir "%outputPath%%runName%/Programs/FTRental"'
  execute 'copy /y "FTRental/*.*" "%outputPath%%runName%/Programs/FTRental"'
$elseifi %opMode%=='DWH' execute 'gams DWmode/DWHreportSetup.gms'
  execute 'mkdir "%outputPath%%runName%/Programs/DWMode"'
  execute 'cp "DWmode/*.*" "%outputPath%%runName%/Programs/DWMode"'
$else
$endif


*=====================================================================================
* Initialize reports
*=====================================================================================
* Call vSPDreportSetup to establish the report files ready to write results into
$iftheni %opMode%=='PVT' execute 'gams Pivot/PivotReportSetup.gms'
$elseifi %opMode%=='DPS' execute 'gams Demand/DPSreportSetup.gms'
$elseifi %opMode%=='FTR' execute 'gams FTRental/FTRreportSetup.gms'
$elseifi %opMode%=='DWH' execute 'gams DWmode/DWHreportSetup.gms'
$else                    execute 'gams vSPDreportSetup.gms'
$endif


*=====================================================================================
* Solve vSPD and report - loop over the designated input GDX files and solve each one in turn.
*=====================================================================================
loop(i_fileName,

*  Create the file that has the name of the input file for the current case being solved
   putclose vSPDcase "$setglobal  vSPDinputData  " i_fileName.tl:0 ;

*  Create a gdx file contains periods to be solved
   put_utility temp 'exec' / 'gams vSPDperiod' ;

*  Solve the model for the current input file
   put_utility temp 'exec' / 'gams vSPDsolve.gms r=vSPDmodel lo=3 ide=1 Errmsg = 1' ;

*  Copy the vSPDsolve.lst file to i_fileName.lst in ../Programs/lst/
   put_utility temp 'shell' / 'cp vSPDsolve.lst "%programPath%"/lst/', i_fileName.tl:0, '.lst' ;

) ;
rep.ap = 1 ;
putclose rep / "Total execute time: " timeExec "(secs)" /;


*=====================================================================================
* Clean up
*=====================================================================================
$label cleanUp
execute 'rm "vSPDcase.inc"' ;
execute 'rm "riskGroup.inc"' ;
$ifthen %opMode%=='DWH'
execute 'mv ProgressReport.txt "%outputPath%%runName%/%runName%_RunLog.txt"';
$else
execute 'mv ProgressReport.txt "%outputPath%%runName%"';
$endif
*$ontext
execute 'rm *.lst '
execute 'rm *.~gm '
execute 'rm *.lxi '
execute 'rm *.log '
execute 'rm *.put '
execute 'rm *.txt '
execute 'rm *.gdx '
execute 'rm temp.*'
*$offtext
