report_this_filefun(mfilename('fullpath'));

global no1 bo1 inb1 inb2

figure

[m,n] = size(re3);
ro = reshape(re3,m*n,1);
l = isnan(ro);

ro(l) = [];
RE0 = re3;
ME0 = mean(ro)
histogram(ro,50)
newa0 = newa;


le0 = length(newa);


TES = [];

for ii = 1:1000
    ii

    rng('shuffle');
    RN = rand(le0,1);
    [RY,I] = sort(RN);
    newa(:,6) = newa(I,6);




    welcome(' ','Running... ');think
    %  make grid, calculate start- endtime etc.  ...
    %
    t0b = newa(1,3)  ;
    n = length(newa(:,1));
    teb = newa(n,3) ;
    tdiff = round((teb - t0b)*365/par1);
    loc = zeros(3,length(gx)*length(gy));

    % loop over  all points
    %
    i2 = 0.;
    i1 = 0.;
    bvg = [];
    allcount = 0.;
    wai = waitbar(0,[' Please Wait ...  ' num2str(ii)  ]);
    set(wai,'NumberTitle','off','Name','b-value grid - percent done');;
    drawnow
    %
    % loop


    % overall b-value
    [bv magco stan av me mer me2,  pr] =  bvalca3(newa,inb1,inb2);
    bo1 = bv; no1 = length(newa(:,1));
    %
    for i= 1:length(newgri(:,1))
        x = newgri(i,1);y = newgri(i,2);
        allcount = allcount + 1.;
        i2 = i2+1;

        % calculate distance from center point and sort wrt distance
        l = sqrt(((xsecx' - x)).^2 + ((xsecy + y)).^2) ;
        [s,is] = sort(l);
        b = newa(is(:,1),:) ;       % re-orders matrix to agree row-wise


        if tgl1 == 0   % take point within r
            l3 = l <= ra;
            b = newa(l3,:);      % new data per grid point (b) is sorted in distanc
            rd = ra;
        else
            % take first ni points
            b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
            l2 = sort(l); rd = l2(ni);

        end

        %estimate the completeness and b-value
        newt2 = b;
        if length(b) >= Nmin  % enough events?

            if inb1 == 3
                mcperc_ca3;  l = b(:,6) >= Mc90-0.05; magco = Mc90;
                if length(b(l,:)) >= Nmin
                    [bv magco0 stan av me mer me2,  pr] =  bvalca3(b(l,:),2,2);
                    [av2 bv2 stan2 ] =  bmemag(b(l,:));
                else
                    bv = NaN; bv2 = NaN, magco = NaN; av = NaN; av2 = NaN;
                end

            elseif inb1 == 4
                mcperc_ca3;  l = b(:,6) >= Mc95-0.05; magco = Mc95;
                if length(b(l,:)) >= Nmin
                    [bv magco0 stan av me mer me2,  pr] =  bvalca3(b(l,:),2,2);
                    [av2 bv2 stan2 ] =  bmemag(b(l,:));
                else
                    bv = NaN; bv2 = NaN, magco = NaN; av = NaN; av2 = NaN;
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
                    [av2 bv2 stan2 ] =  bmemag(b(l,:));
                else
                    bv = NaN; bv2 = NaN, magco = NaN; av = NaN; av2 = NaN;
                end

            elseif inb1 == 1
                [bv magco stan av me mer me2,  pr] =  bvalca3(b,1,1);
                l = b(:,6) >= magco-0.05;
                if length(b(l,:)) >= Nmin
                    [av2 bv2 stan2 ] =  bmemag(b(l,:));
                else
                    bv = NaN; bv2 = NaN, magco = NaN; av = NaN; av2 = NaN;
                end

            elseif inb1 == 2
                [bv magco stan av me mer me2,  pr] =  bvalca3(b,2,2);
                [av2 bv2 stan2 ] =  bmemag(b);
            end
            dP = NaN;
            predi_ca

        else
            bv = NaN; bv2 = NaN,dP = NaN; magco = NaN; av = NaN; av2 = NaN; b = [NaN NaN NaN NaN NaN NaN NaN NaN NaN];
        end
        mab = max(b(:,6)) ; if isempty(mab)  == 1; mab = NaN; end

        bvg = [bvg ; bv magco x y rd bv2 stan2 av stan dP  mab ];
        waitbar(allcount/itotal)
    end  % for  newgri

    % save data
    %
    %  set(txt1,'String', 'Saving data...')
    drawnow
    gx = xvect;gy = yvect;
    close(wai)

    % reshape a few matrices
    %
    normlap2=NaN(length(tmpgri(:,1)),1);
    normlap2(ll)= bvg(:,10);
    PR3 =reshape(normlap2,length(yvect),length(xvect));


    normlap2=NaN(length(tmpgri(:,1)),1);
    normlap2(ll)= bvg(:,1);
    re3=reshape(normlap2,length(yvect),length(xvect));


    [m,n] = size(PR3);
    ro = reshape(PR3,m*n,1);
    l = isnan(ro);
    ro(l) = [];

    TES = [TES ; mean(ro) ];


end % for ii

