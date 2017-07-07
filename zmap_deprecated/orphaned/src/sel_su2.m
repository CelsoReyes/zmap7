report_this_filefun(mfilename('fullpath'));

l = org(:,6) >= minma  & org(:,6) <= maxma  &  org(:,3) >= minti & org(:,3) <= maxti & org(:,7) >= mindep & org(:,7) <= maxdep;

a = org(l,:);
set(inp1B,'String',num2str(length(a)));


