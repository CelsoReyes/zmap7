function toggle_mapping_toolbox()
% script toggle mapping toolbox
mappaths={'/Applications/MATLAB_R2017a.app/toolbox/map/map'
'/Applications/MATLAB_R2017a.app/toolbox/map/mapgeodesy'
'/Applications/MATLAB_R2017a.app/toolbox/map/mapdisp'
'/Applications/MATLAB_R2017a.app/toolbox/map/mapformats'
'/Applications/MATLAB_R2017a.app/toolbox/map/mapproj'
'/Applications/MATLAB_R2017a.app/toolbox/map/mapdata'
'/Applications/MATLAB_R2017a.app/toolbox/map/mapdata/sdts'};
if exist(mappaths{1})
    
    for i =1:7;rmpath(mappaths{i});end
else
    for i =1:7;addpath(mappaths{i});end
end
ends