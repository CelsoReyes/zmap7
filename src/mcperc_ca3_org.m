%report_this_filefun(mfilename('fullpath'));

% This is a comleteness determination test

[bval,xt2] = hist(newt2(:,6),-2:0.1:6);
l = max(find(bval == max(bval)));
magco0 =  xt2(l);

dat = [];

%for i = magco0-0.6:0.1:magco0+0.2
for i = magco0-0.5:0.1:magco0+0.7
    l = newt2(:,6) >= i - 0.0499; nu = length(newt2(l,6));
    if length(newt2(l,6)) >= 25;
        %[bv magco stan,  av] =  bvalca3(newt2(l,:),2,2);
        [mw bv2 stan2,  av] =  bmemag(newt2(l,:));
        try %in case something goes wrong
            synthb_aut
        catch
            res2=nan
        end
        dat = [dat ; i res2];
    else
        dat = [dat ; i NaN];
    end

end

j =  min(find(dat(:,2) < 10 ));
if isempty(j) == 1; Mc90 = NaN ;
else;
    Mc90 = dat(j,1);
end

j =  min(find(dat(:,2) < 5 ));
if isempty(j) == 1; Mc95 = NaN ;
else;
    Mc95 = dat(j,1);
end

j =  min(find(dat(:,2) < 10 ));
if isempty(j) == 1; j =  min(find(dat(:,2) < 15 )); end
if isempty(j) == 1; j =  min(find(dat(:,2) < 20 )); end
if isempty(j) == 1; j =  min(find(dat(:,2) < 25 )); end
j2 =  min(find(dat(:,2) == min(dat(:,2)) ));
%j = min([j j2]);

Mc = dat(j,1);
magco = Mc;
prf = 100 - dat(j2,2);
if isempty(magco) == 1; magco = NaN; prf = 100 -min(dat(:,2)); end
%disp(['Completeness Mc: ' num2str(Mc) ]);


