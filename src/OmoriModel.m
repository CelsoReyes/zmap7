classdef OmoriModel < int32
    enumeration
        pck   (1) % 3 free parameters: p, c , k      % Modified Omori law (pck)
        pckk  (2) % 4 free parameters: p, c , k1, k2 % MOL with secondary aftershock (pckk)
        ppckk (3) % 5 free parameters: p1,p2,c,k1,k2 % MOL with secondary aftershock
        ppcckk(4) % 6 free parameters: p1,p2,c1, c2,k1,k2 % MOL with secondary aftershock
    end
    
    methods(Static)
        function cm = doForecast(nMod, t, p_1, c_1, k_1, t_break, k_2, p_2, c_2) % notice funky order!
            % log likelyhood
            %   where p = pvalues as n x 1
            %   where c = cvalues as n x 1
            %   where k = kvalues as n x 1
            %   where t = amount of time after the main shock, as m x 1 duration
            %
            %   returns an n x m matrix of values
            %
            % each row represents ONE time.
            % each column represents one itteration of p,c, and k
            %
            %  for scalar p,c,k, this would return a single row of values. one for each time.
            %  for scalar t, this would returna  single column of values.
            %
            %  p1t1   p2t1  p3t1     params ->
            %  p1t2   p2t2  p3t2
            %  p1t3   p2t3  p3t3
            %  p1t4   p2t4  p3t4
            %
            %  time
            %    |
            %    v
            
            
            assert(isrow(p_1) && isrow(c_1) && isrow(k_1) , 'All p,c,k input values should be rows');
            assert(all(numel(p_1) == [ numel(k_1), numel(c_1)]),'p, c, and k values should have same length');
            assert(isvector(t), 'time should be a vector');
            if isduration(t)
                t=days(t);
            end
            if ~iscolumn(t)
                t=t';
            end
            
            cm = nan(numel(t),numel(p_1));
            sz=size(cm);
            switch nMod
                case OmoriModel.pck
                    % deal with non infinite solutions first
                    idx = p_1 ~= 1;
                    c=c_1(idx); 
                    k=k_1(idx);
                    p=p_1(idx);
                    cm(:,idx) = k ./ (p-1) .* (c .^ (1-p)-(t +c).^ (1-p));
                    
                    c=c_1(~idx);
                    k=k_1(~idx);
                    p=[];
                    cm(:,~idx) = k .* log(t ./ c + 1);
                    
                    
                case {OmoriModel.pckk, OmoriModel.ppckk, OmoriModel.ppcckk}
                    
                    assert(isrow(p_2) && isrow(c_2) && isrow(k_2) , 'All p2,c2,k2 input values should be rows');
                    assert(all(numel(p_1) == [ numel(p_2) numel(k_2), numel(c_2)]),'pn, cn, and kn values should have same length');
                    assert(isscalar(t_break));
                    if isduration(t_break)
                        t_break=days(t_break);
                    end
                    
                    isafter = t >= t_break;
                    cm(~isafter,:) =  OmoriModel.doForecast(OmoriModel.pck, t(~isafter), p_1, c_1, k_1);
                    
                    idx = p_1 ~= 1 & p_2 ~= 1;
                    if any(idx)
                        c1 = c_1(idx);
                        c2 = c_2(idx);
                        p1 = p_1(idx);
                        p2 = p_2(idx);
                        k1 = k_1(idx);
                        k2 = k_2(idx);
                        cm(isafter,idx) = k1./(p1-1) .* (c1.^(1-p1)-(t(isafter)+c1).^(1-p1)) + k2./(p2-1).*(c2.^(1-p2)-(t(isafter)-t_break + c2).^(1-p2));
                    end
                    
                    idx = p_1 ~= 1 & p_2 == 1;
                    if any(idx)
                        c1 = c_1(idx);
                        c2 = c_2(idx);
                        p1 = p_1(idx);
                        p2 = [];
                        k1 = k_1(idx);
                        k2 = k_2(idx);
                        cm(isafter,idx) = k1./(p1-1) .* (c1.^(1-p1)-(t(isafter)+c1).^(1-p1)) + k2 .* log((t(isafter)-t_break)./c2+1);
                    end
                    
                    idx = p_1 == 1 & p_2 ~= 1;
                    if any(idx)
                        c1 = c_1(idx);
                        c2 = c_2(idx);
                        p1 = [];
                        p2 = p_2(idx);
                        k1 = k_1(idx);
                        k2 = k_2(idx);
                        cm(isafter,idx) =k1.*log(t(isafter)./c1+1) + k2./(p2-1).*(c2.^(1-p2)-(t(isafter)-t_break+c2).^(1-p2));
                    end
                    
                    idx = p_1 == 1 & p_2 == 1;
                    if any(idx)
                        c1 = c_1(idx);
                        c2 = c_2(idx);
                        p1 = [];
                        p2 = [];
                        k1 = k_1(idx);
                        k2 = k_2(idx);
                        cm(isafter,idx) = k1.*log(t(isafter)./c1+1) + k2.*log((t(isafter)-t_break)./c2+1);
                    end
                    
            end
            assert(isequal(size(cm),sz)); % make sure sizes are as expected
        end
    end
end