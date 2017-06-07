%
% This code calculates Taken's estimator  which ia a maximum likelihood
% estimate for the correlation dimension. Called from dofdim.m.
% Francesco Pacchiani 8/2000
%
%
%numran = 1000;
takes = [];
taker = [];
takes = zeros(100,1); %matrix containing the estimators as a function of distance.

%for t = 1:10;

%siergas2d;
%pdc3nofig;
%taker = [];
taker = (logspace(lrmin, lrmax + 0.5, 100))'; % distance vector.

Ho_Wb = waitbar(0,'Calculating the Taken Estimator');
Hf_Cfig = gcf;
Hf_child = get(groot,'children');
set(Hf_child,'pointer','watch','papertype','A4');


for v = 1:size(taker,1)

    j1 = [];
    j2 = [];
    ralpha = [];
    alpha = [];
    j1 = find(pairdist < taker(v));
    j2 = pairdist < taker(v);
    ralpha = log(pairdist(j1)./taker(v));
    alpha = sum(ralpha)/sum(j2);
    takes(v,t) =  -1./alpha;

    waitbar((1/size(taker,1))*v, Ho_Wb);

end


clear v t j1 j2 k ralpha
close(Ho_Wb);
Hf_child = get(groot,'children');
set(Hf_child,'pointer','arrow');
%end
%
% Calculates the standard deviation the estimators.
%
%takerr = (1/sqrt(N))*(1/alpha);
%
% Plots the Taken estimator as a function of the logarithmic distance.
%
[existFlag,figNumber]=figure_exists('Taken Estimator (log2)',1);

if existFlag == 1

    fig = 'addfig';

elseif existFlag == 0

    fig = 'orifig';
end

switch(fig)

    case 'orifig'

        Htakes2 = figure_w_normalized_uicontrolunits('Numbertitle','off','Name','Taken Estimator (log2)');
        plot(log2(taker(:,1)), takes(:,t));
        axis([-8 6 0 6]);
        xlabel('log2(dist)');
        ylabel('Takens Estimator');
        box on;

    case 'addfig'

        fig(Htakes2);
        hold on;
        plot(log2(taker(:,1)), takes(:,t));
        axis([-8 6 0 6]);

end % switch

%[existFlag,figNumber]=figure_exists('Taken Estimator (log10)',1);


%if existFlag == 1

%   fig = 'addfig';

%elseif existFlag == 0

%   fig = 'orifig';
%end

%switch(fig)

%case 'orifig'

%Htakes10 = figure_w_normalized_uicontrolunits('Numbertitle','off','Name','Taken Estimator (log10)');
%plot(log10(taker(:,1)), takes(:,1));
%axis([-2.5 10.5 0 3.5]);
%xlabel('log10(dist)');
%ylabel('Takens Estimator');
%box on
%axes('pos',[0 0 1 1]);
%axis off

%case 'addfig'

%      figure_w_normalized_uicontrolunits(Htakes10);
%   hold on;
%   plot(log10(taker(:,1)), takes(:,t));
%   axis([-12.5 1.5 0 3.5]);

%end % switch

%end %for t
