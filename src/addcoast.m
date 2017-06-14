% This files adds a coastline from an existing data set
global coastline faults mainfault main
report_this_filefun(mfilename('fullpath'));

%aa = a;
[file1,path1] = uigetfile( '*.mat',' Earthquake Datafile'); %disabled window position
loadpath = [path1 file1];
try
    set(action_button,'String','Loading Data...');
catch
    welcome
end

new_data = load(loadpath);

loaded=false;
if isfield(new_data,'coastline')
    if ~isempty(new_data.coastline)
        loaded=true;
        coastline=new_data.coastline;
    end
end

if isfield(new_data,'faults')
    if ~isempty(new_data.faults)
        loaded=true;
        faults=new_data.faults;
    end
end

if isfield(new_data,'mainfault')
    if ~isempty(new_data.mainfault)
        loaded=true;
        mainfault=new_data.mainfault;
    end
end


if isfield(new_data,'main')
    if ~isempty(new_data.main)
        loaded=true;
        main=new_data.main;
    end
end


if ~loaded
    disp('Error lodaing data! Are they in the right *.mat format??')
end
whos
%a = aa;
%clear aa
mainmap_overview()

