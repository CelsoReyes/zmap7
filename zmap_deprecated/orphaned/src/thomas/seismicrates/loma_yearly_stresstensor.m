% Script: run_loma_yearly_stresstensor.m

% Starting ZMAP
sPath = pwd
cd /home/jowoe/zmap
startup
cd(sPath)

% Load the parameter file
load Params_Loma_ConstRad3km_Nmin50_0.01deg_T365d.mat

% Do loop over different radii to select events
for fRadius = 3:1:5
    sString = ['Radius: ', num2str(fRadius) 'km'];
    params.fRadius = fRadius;
    vResults = [];
    disp(sString)
    tstart1= cputime
    !date
    % Perform the calculation
    [vResults] = gui_CalcStressInv(params);
    !date
    tend1=cputime-tstart1
    !rm tmp*
end
