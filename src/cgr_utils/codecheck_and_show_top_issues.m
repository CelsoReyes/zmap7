fn=dir('*.m');
fn={fn.name};
A=checkcode(fn);
z=struct('message',''); 
for n=1:numel(A)
    for m=1:numel(A{n})
        z(end+1).message=A{n}(m).message;
    end
end
zc={z.message};
zc=sort(zc);
cnt = 0; issue={''}; 
for c=1:numel(zc)
    issueidx=numel(issue);
    if strcmp(issue(end), zc{c})
        cnt(issueidx)=cnt(issueidx)+1; 
    else
        issue{end+1}=zc{c}; 
        cnt(end+1)=0;
    end
end
[B, I] = sort(cnt,'descend');
sortedcnt = cnt(I); sortedissues=issue(I);
for i=1:40
    fprintf('%d : %s\n', sortedcnt(i), sortedissues{i});
end
if ~exist('last_issue_count','var')
    last_issue_count=0;
end
fprintf('total issues: %d  [prev: %d]',sum(sortedcnt), last_issue_count)
last_issue_count = sum(sortedcnt);