% This subroutine assigns creates a grid with
% spacing dx,dy (in degreees). The size will
% be selected interactively. The b-value and p-value in each
% volume around a grid point containing between Nmin and ni earthquakes
% will be calculated as well as the magnitude of completness.
%   Stefan Wiemer 1/95
%
%For the execution of this program, the "Cumulative Window" should have been opened before.
%Otherwise the matrix "maepi", used by this program, does not exist.


global no1 bo1 inb1 inb2 valeg valeg2 CO

onewt2 = newt2;
inb1 = 5;

valeg = 1;

[file_in,pathname] = uigetfile('*.mat', 'Enter the name of the origial gridfile');

pathname = '/eq_data/hector/'
file_in = 'test.mat'
load([pathname file_in]);

welcome(' ','Running... ');think
%  make grid, calculate start- endtime etc.  ...
%
t0b = a(1,3)  ;
n = length(a(:,1));
teb = a(n,3) ;
tdiff = round((teb - t0b)*365/par1);
loc = zeros(3,length(gx)*length(gy));

wai = waitbar(0,' Please Wait ...  ');
set(wai,'NumberTitle','off','Name','bp-value grid - percent done');;

rng('shuffle');
origa = a;
%disp(['size of a ',num2str(length(a))]);
valeg = 1;

%%
% call pvalcat to get overall values
%%
newt2 = a;
rand_pvcat;
allpv(1:4) = [rja rjb cv pv];
valeg = 1;

%%
% overall b-value
%%
[bv magco stan av me mer me2,  pr] =  bvalca3(a,inb1,inb2);
bo1 = bv; no1 = length(a(:,1));

num_events = length(newt2);
itotal = length(newgri);
allcount = 0.;
rpvg = [];

%%
% loop for RANDOM catalog!!
%%

for rand_loop = 1:100

    i2 = 0.;
    i1 = 0.;
    drawnow


    %%
    % loop over all grid nodes
    %%
    for iloop= 1:length(newgri(:,1))
        x = newgri(iloop,1);y = newgri(iloop,2);
        xx = x; yy = y;
        allcount = allcount + 1.;
        i2 = i2+1;

        %%
        % this is the number of events in the real data, before Mc cut, at this node
        %%
        num_atnode = bpvg(i,19);

        %%
        % rand_cat is the new random catalog, randomly samply the correct
        % num_atnode, events from the overall catalog
        %%
        rand_ind = round(rand(num_atnode,1)*num_events);
        ri0 = rand_ind == 0;
        rand_ind(ri0) = 1;
        rand_cat = a(rand_ind,:);

        %%
        % now estimate the completeness and a,p,c and b-value
        %%
        newt2 = rand_cat;
        b = newt2;
        if length(b) >= Nmin  % enough events?

            if inb1 == 3
                mcperc_ca3;  l = b(:,6) >= Mc90-0.05; magco = Mc90;
                if length(b(l,:)) >= Nmin
                    [bv magco0 stan av me mer me2,  pr] =  bvalca3(b(l,:),2,2);
                    [magnm bv2 stan2,  av2] =  bmemag(b(l,:));
                    maxcat = b(l,:);
                    maxmg = max(maxcat(:,6));
                    [pv pstd cv cstd kv kstd mmav,  mbv] = mypval2m(b(l,:));
                else
                    bv = nan; bv2 = nan; magco = nan; av = nan; av2 = nan; stan2 = nan; stan = nan; pv = nan; pstd = nan; maxmg = nan; prf = nan; pr = nan;
                    cv = nan; cstd = nan; kv = nan; kstd = nan;
                    mmav = nan; mbv = nan;
                end

            elseif inb1 == 4
                mcperc_ca3;  l = b(:,6) >= Mc95-0.05; magco = Mc95;
                if length(b(l,:)) >= Nmin
                    [bv magco0 stan av me mer me2,  pr] =  bvalca3(b(l,:),2,2);
                    [magnm bv2 stan2,  av2] =  bmemag(b(l,:));
                    maxcat = b(l,:);
                    maxmg = max(maxcat(:,6));
                    [pv pstd cv cstd kv kstd mmav,  mbv] = mypval2m(b(l,:));
                else
                    bv = nan; bv2 = nan; magco = nan; av = nan; av2 = nan; stan2 = nan; stan = nan; pv = nan; pstd = nan; maxmg = nan; prf = nan; pr = nan;
                    cv = nan; cstd = nan; kv = nan; kstd = nan;
                    mmav = nan; mbv = nan;
                end
            elseif inb1 == 5
                mcperc_ca3;
                if isnan(Mc95) == 0 
                    magco = Mc95;
                elseif isnan(Mc90) == 0 
                    magco = Mc90;
                else
                    [bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);
                end
                l = b(:,6) >= magco-0.05;
                if length(b(l,:)) >= Nmin
                    [bv magco0 stan av me mer me2,  pr] =  bvalca3(b(l,:),2,2);
                    maxcat = b(l,:);
                    maxmg = max(maxcat(:,6));
                    [magnm bv2 stan2,  av2] =  bmemag(b(l,:));
                    [pv pstd cv cstd kv kstd mmav,  mbv] = mypval2m(b(l,:));
                else
                    bv = nan; bv2 = nan; magco = nan; av = nan; av2 = nan; stan2 = nan; stan = nan; pv = nan; pstd = nan; maxmg = nan; prf = nan; pr = nan;
                    cv = nan;
                    cstd = nan;
                    mmav = nan;
                    mbv = nan; kv = nan; kstd = nan;
                end

            elseif inb1 == 1
                [bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);
                l = b(:,6) >= magco-0.05;
                if length(b(l,:)) >= Nmin
                    [magnm bv2 stan2,  av2] =  bmemag(b(l,:));
                    maxcat = b(l,:);
                    maxmg = max(maxcat(:,6));
                    [pv pstd cv cstd kv kstd mmav,  mbv] = mypval2m(b(l,:));
                else
                    bv = nan; bv2 = nan; magco = nan; av = nan; av2 = nan; stan2 = nan; stan = nan; pv = nan; pstd = nan; maxmg = nan; prf = nan; pr = nan;
                    cv = nan; cstd = nan;
                    mmav = nan; mbv = nan; kv = nan; kstd = nan;
                end

            elseif inb1 == 2
                [bv magco stan av me mer me2,  pr] =  bvalca3(b,2,2);
                [magnm bv2 stan2,  av2] =  bmemag(b);
                maxcat = b(l,:);
                maxmg = max(maxcat(:,6));
                [pv pstd cv cstd kv kstd mmav,  mbv] = mypval2m(b(l,:));
            end

        else
            bv = nan; bv2 = nan; magco = nan; av = nan; av2 = nan; stan2 = nan; stan = nan; pv = nan; pstd = nan; maxmg = nan; prf = nan; pr = nan;
            cv = nan; cstd = nan; kv =  nan;
            mmav = nan; mbv = nan; kstd = nan;
        end


        rpvg(iloop,1,rand_loop) = mmav;
        rpvg(iloop,2,rand_loop) = mbv;
        rpvg(iloop,3,rand_loop) = pv;
        rpvg(iloop,4,rand_loop) = cv;
        rpvg(iloop,5,rand_loop) = xx;
        rpvg(iloop,6,rand_loop) = yy;


        waitbar(allcount/(itotal*100))
    end  % for newgr

    %%
    % END OF RANDOM LOOP
    %%
end

%%
% save it
%%
catSave3 =...
    [ 'welcome(''Save Grid'',''  '');think;',...
    '[file1,path1] = uiputfile(fullfile(hodi, ''eq_data'', ''*.mat''), ''Grid Datafile Name?'') ;',...
    ' sapa2 = [''save '' path1 file1 '' rpvg gx gy yvect xvect tmpgri allpv''];',...
    ' if length(file1) > 1, eval(sapa2),end , done']; eval(catSave3)

close(wai)
watchoff

