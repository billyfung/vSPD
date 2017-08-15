# vSPD
====

vectorised Scheduling, Pricing and Dispatch - an audited, mathematical replica of SPD, the
pricing and dispatch engine used in the New Zealand electricity market.

Input GDX files are available daily from ..\Datasets\Wholesale\Final_pricing\GDX\ at
ftp://emiftp.ea.govt.nz or from www.emi.ea.govt.nz/Datasets/Wholesale/Final_pricing/GDX.

The Electricity Authority created vSPD using the GAMS software in 2008. Dr Ramu Naidoo was
the original author and, until November 2013, the custodian of vSPD. Dr Phil Bishop and Tuong
Nguyen now take care of vSPD. Others at the Electricity Authority also contribute.

vSPD was most recently audited in September 2014 - see http://www.emi.ea.govt.nz/Tools/vSPD.

Contact: emi@ea.govt.nz


## Info
The original vSPD is written for usage on Windows OS, with GAMS ide. My goal is to port it to Linux and make it useable from the command line instead of having to use the IDE.

Would be nice to have something like:
```
GAMS runvSPD.gms tp=TP1 runName=test
```

Some features I'd like are:
- [ ] trading period argument
- [ ] specifying the labeled name of the run
