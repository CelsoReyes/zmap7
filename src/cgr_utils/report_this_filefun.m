function report_this_filefun(funct_name)
% this script replaced all the individual "disp('This is ...') messages
% it can be used to track which files are used, or do some function/file specific
% setup

%called by script or function?
% modified from: http://blogs.mathworks.com/loren/2013/08/26/what-kind-of-matlab-file-is-this/

fn_id_tag = '????????';
try
    maxInputs = nargin(funct_name); % errors if not a function
    fn_id_tag = 'function';
catch exception
    if strcmp(exception.identifier, 'MATLAB:nargin:isScript')
        fn_id_tag = 'script  ';
    else
        % We are only looking for scripts and functions so anything else
        % will be reported as an error.
        disp(exception.message)
    fn_id_tag = 'unknown ';
    end
end

disp(['in: ', fn_id_tag, ' ', funct_name]);
%{
cgr_dbs = dbstack('-completenames');
if numel(cgr_dbs)>1
disp(cgr_dbs(end-1));
else
    disp('report_this_filefun called from base (no stack)');
end
clear cgr_dbs
%}