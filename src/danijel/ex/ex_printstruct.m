function print_struct(struct, level)
%
% print_struct(struct)
%
% Prints out the field names of a struct.
% If you have nested structs, the complete
% structure is printed out as a tree.
%
% Rev.1.0, 24.11.98 (Armin Guenter, Matlab 5.2)

if nargin < 1  ||  nargin > 2
   error('Wrong number of input arguments.')
end
if ~exist('level', 'var')
   level = 1;
end

names = fieldnames(struct);
for i = 1:length(names)
   disp([repmat('  ', 1, level-1) '+ ' names{i}])
   field = getfield(struct, names{i});
   if isstruct(field)
      level = level + 1;
      ex_printstruct(field, level)
      level = level - 1;
   end
end
