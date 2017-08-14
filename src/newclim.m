function CLim = newclim(BeginSlot,EndSlot,CDmin,CDmax,CmLength)

    report_this_filefun(mfilename('fullpath'));

    PBeginSlot = (BeginSlot - 1) / (CmLength - 1);
    PEndSlot = (EndSlot - 1) / (CmLength - 1);
    PCmRange = PEndSlot - PBeginSlot;
    DataRange = CDmax - CDmin;
    ClimRange = DataRange / PCmRange;
    NewCmin = CDmin - (PBeginSlot * ClimRange);
    NewCmax = CDmax + (1 - PEndSlot) * ClimRange;
    CLim = [NewCmin,NewCmax];

