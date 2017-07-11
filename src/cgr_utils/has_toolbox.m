function tf = has_toolbox(toolboxname)
% has_toolbox check for existance of a matlab toolbox
% 
% ex.  tf=has_toolbox('Mapping Toolbox') will return true if mapping toolbox is installed
    s=ver;
    tf = ismember(toolboxname,{s.Name});
end