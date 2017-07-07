%function [outmat] = selmaval(a,lowb,highb,rowindex,type)
%function create a matrix out of an existing one with certain suitable
%values of a row
%a: input matrix
%lowb: lowest values to include
%highb: highest values to include
%rowindex: to row to compare the values to
%type: 0=> lowb<=x<=highb
%      1=> lowb>=x or x>=highb

function [outmat] = selmaval(a,lowb,highb,rowindex,type)

    %length of the catalog
    endma=length(a);

    %counter for output
    j=1;
    if type==0

        outmat=a(a(:,rowindex)>=lowb,:);
        outmat=outmat(outmat(:,rowindex)<=highb,:);
        %     for i=1:1:endma
        %        if ((a(i,rowindex)>=lowb)  && (a(i,rowindex)<=highb))
        %             outmat(j,:)=a.subset(i);
        %             j=j+1;
        %         end
        %     end

    elseif type==1
        parta=a(a(:,rowindex)<=lowb,:);
        partb=a(a(:,rowindex)>=highb,:);
        outmat=[parta;partb];
        %         for i=1:1:endma
        %         if ((a(i,rowindex)>=lowb) | (a(i,rowindex)<=highb))
        %             outmat(j,:)=a.subset(i);
        %             j=j+1;
        %         end
        %     end
    end


end
