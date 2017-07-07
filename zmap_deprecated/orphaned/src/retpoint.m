report_this_filefun(mfilename('fullpath'));

%
bvg = [];
x = px;y = py;
allcount = allcount + 1.;
i2 = i2+1;

% calculate distance from center point and sort wrt distance
l = sqrt(((xsecx' - x)).^2 + ((xsecy + y)).^2) ;
%      [s,is] = sort(l);
%b = newa(is(:,1),:) ;       % re-orders matrix to agree row-wise

%take first ni points
%b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
l = l <= ra;
b = newa.subset(l);

% call the b-value function
if isempty(b) == 1; b = newa.subset(1); end
if length(b(:,1)) >= 40;

    [ me, bv, si, av2] = bmemag(b)  ;
    [bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);
    l = sort(l);
    bvg = [bvg ; bv magco x y l2(ni) length(b(:,1)) pr av si  max(b(:,6))];
else
    bvg = [bvg ; NaN NaN x y length(b(:,1)) NaN NaN  NaN NaN NaN];
end

ret =(teb - t0b)./(10.^(bvg(:,8)-6*bvg(:,1)));


