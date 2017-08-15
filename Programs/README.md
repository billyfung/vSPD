# Refactor
To Do:
- [ ] port to Linux, change filepath/name
- [ ] accept arguments as overrides? specific TP and filename

## Porting to Linux
Currently everything is written for Windows, so that means all the filepaths are Windows format.
Will need to change all that.

Files that deal with filenames:
- vSPDsettings.inc
- vSPDreportSetup.gms
- runvSPD.gms
- vSPDperiod.gms
- vSPDreport.gms

Will need to change all the msdos commands to unix commands if applicable
- copy
- erase
- move
