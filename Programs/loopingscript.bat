@echo off
FOR /L %%A in (1,1,48) DO (
  (
  echo /
  echo TP%%A
  echo /
  )>"C:\Users\vagrant\Desktop\vSPD-master\vSPD-master\Programs\vSPDtpsToSolve.inc"
  gams runvSPD.gms --runName=tp%%A
)
