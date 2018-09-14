% display current status for the zmap program
% parentdir=ZmapGlobal.Data.hodi; % zmap root
d=dir('**/*');

% exclude deprecated files
idx=contains({d.folder},'zmap_deprecated');
d(idx)=[];

fprintf('%d <strong>deprecated</strong> items (including directories)\n',sum(idx));

allextensions = arrayfun(@(x)x.name(find(x.name=='.',1,'last'):end),d,'UniformOutput',false);
c=categorical(string(allextensions));

disp('File types contained in ZMAP');
summary(c)

% examine .m files
mfiles = d(c=='.m');
torm='/Users/reyesc/Git/zmap/';

ffm=fullfile({mfiles.folder},{mfiles.name});
ffs=string(ffm);
ffs = erase(ffs,torm);
fl = strjoin(ffs, ' ');

%% 
catcommand = ['cat ', char(fl) ];

fprintf(['\n* * * * * * * * * * * * * * * *\n',...
    '<strong>SUMMARY OF ZMAP/strong> AS OF <strong>%s</strong>'],...
    char(datetime));
% stats on the m-files. can be fooled by block comments
[~,aa] = system([catcommand, '|wc -l']); 
total_lines = str2double(aa);

[~,aa] = system([catcommand, '| grep "^ *function" |wc -l']);
total_functions = str2double(aa);

[~,aa] = system([catcommand, '| grep "^ *classdef" |wc -l']);
total_classes = str2double(aa);

[~,aa] = system([catcommand, '| grep "^ *%" |wc -l']);
total_commentlines = str2double(aa);

[~,aa] = system([catcommand, '| grep "^ *$" |wc -l']);
total_whitespacelines = str2double(aa);

fprintf(['\nTotal number of <strong>functions</strong>: %d\n'...
    'Total number of <strong>classes</strong>: %d\n'],...
    total_functions, total_classes);
 

% branching
[~,aa] = system([catcommand, '| grep "^ *if " |wc -l']);
total_ifs = str2double(aa);

[~,aa] = system([catcommand, '| grep "^ *elseif " |wc -l']);
total_elseifs = str2double(aa);

[~,aa] = system([catcommand, '| grep "^ *else " |wc -l']);
total_elses = str2double(aa);

[~,aa] = system([catcommand, '| grep "^ *switch " |wc -l']);
total_switches = str2double(aa);

[~,aa] = system([catcommand, '| grep "^ *case " |wc -l']);
total_cases = str2double(aa);

fprintf(['\n<strong>Branching</strong>\n',...
    '  <strong>IF</strong> statements : %d\n',...
    '    <strong>ELSEIF</strong> statements : %d\n',...
    '    <strong>ELSE</strong>   statements : %d\n\n',...
    '  <strong>SWITCH</strong> statements : %d\n',...
    '    <strong>CASE</strong> statements : %d\n'],...
    total_ifs, total_elseifs, total_elses, total_switches, total_cases);

% looping
[~,aa] = system([catcommand, '| grep "^ *while " |wc -l']);
total_whileloops = str2double(aa);

[~,aa] = system([catcommand, '| grep "^ *for " |wc -l']);
total_forloops = str2double(aa);
fprintf(['\n<strong>Looping</strong>\n',...
    '  <strong>FOR</strong> loops : %d\n',...
    '  <strong>WHILE</strong> loops %d\n'],...
    total_forloops,total_whileloops);


% report on globals
% [~,aa] = system([catcommand, '| grep "^ *global "'])
% aa2 = strip(strsplit(aa,newline))
% for i=1:numel(aa2)
%     s=strsplit(aa2{i},'%');
%     aa2(i)=s(1);
% end
% aa2=erase(aa2,'global ');
% allglobals = categorical(split(strjoin(aa2,' ')));
% disp('<strong>GLOBALS<\strong> still lurking in the code')
% summary(allglobals)
% disp('Note: Those that are used only once can [likely] be removed already');

fprintf(['\n<strong>Total lines</strong> in ZMAP : %d\n'...
    '<strong> Total comment</strong> lines (excluding block comments) : %d \n'...
    '<strong> Total whitespace</strong> lines : %d\n'],...
    total_lines, total_commentlines, total_whitespacelines);

fprintf('\n<strong>Lines of code that are NOT comments</strong> : %d\n',...
    total_lines - (total_commentlines + total_whitespacelines));

disp('')
disp('Block comments are not reflected in the grand total');