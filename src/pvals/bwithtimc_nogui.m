%%
% Calculates b based on time using Mc and plots it - called from
% cumulative window
%%


report_this_filefun(mfilename('fullpath'));


inter = 50;
incr = 10;


%%
% set step_cat as a dummy variable so that newt2 can be reassigned
% for use in mcperc_ca3.  newt2 is reset at end.
%%

step_cat = newt2;
bv2 = [];
bv3 = [] ;
me = [];
bvm = [];
ctr = 0;
i=1;
Nmin=50;
%% b=newt2;  %% initialization for bvalca3.m
day_start=0;
day_end=0;

inpr1 = 5;

nibt = 200;
win_step = 200;
for ind = 1:win_step:length(step_cat)-win_step
    newt2 = step_cat(ind:ind+nibt,:);


    %%
    % calculation based on best combination of 90% and 95% probability -- default
    %%

    %         elseif inpr1 == 5
    mcperc_ca3;
    if isnan(Mc95) == 0 
        magco = Mc95;
    elseif isnan(Mc90) == 0 
        magco = Mc90;
    else
        [bv magco stan av me mer me2,  pr] =  bvalca3(newt2,1,1);
    end
    l = newt2(:,6) >= magco-0.05;
    if length(newt2(l,6)) <= Nmin
        %                disp(['%%Warning --bwithtimc--%%  less than 50 events in step ']);
    end
    [ntl,ntw] = size(newt2(l,:));
    if ntl <= 1
        disp('%%ERROR --bwithtimc--%%  Not enough data to plot');
        newt2 = step_cat;
        return
    end
    [mea bv stand,  av] = bmemag(newt2(l,:));




    days = (max(newt2(:,3))-min(newt2(:,3)))*365.0;

    bvm = [bvm; bv step_cat(ind,3) step_cat(ind+nibt,3) magco days ind ind+nibt av];
end  %% end of for loop!!
%end


[bvml,bvmw] = size(bvm);
if bvml <= 1
    disp('%%ERROR --bwithtimc--%%  Not enough data to calculate Mc');
    newt2 = step_cat;
    return
end
if ind + win_step < length(step_cat)
    newt2 = step_cat(ind+win_step+1:length(step_cat),:);
    %%
    % calculation based on best combination of 90% and 95% probability -- default
    %%

    if inpr1 == 5
        mcperc_ca3;
        if isnan(Mc95) == 0 
            magco = Mc95;
        elseif isnan(Mc90) == 0 
            magco = Mc90;
        else
            [bv magco stan av me mer me2,  pr] =  bvalca3(newt2,1,1);
        end
        l = newt2(:,6) >= magco-0.05;
        if length(newt2(l,6)) <= Nmin
            %                disp(['%%Warning --bwithtimc--%%  less than 50 events in step ']);
        end
        [ntl,ntw] = size(newt2(l,:));
        if ntl <= 1
            disp('%%ERROR --bwithtimc--%%  Not enough data to plot');
            newt2 = step_cat;
            return
        end
        [mea bv stand,  av] = bmemag(newt2(l,:));

    end
end
bvm = [bvm; bv step_cat(ind+win_step,3) step_cat(length(step_cat),3) magco days ind ind+nibt av];

%bvm(length(bvm)+1,:) = bvm(ind,:)
newt2 = step_cat;

