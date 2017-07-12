function [cline] = contour_dense(bpoints, solpoint, quan, acc)
    %contour_dense gives a contour line calculated from a group of points and
    %a given mid/solution point.
    %cline: output contour line
    %bpoints: input points (bootstrap solution() , in retangular coord. (:,1)=x
    %(:,2)=y
    %solpoint: solution or center point to which the distance is calculated to
    %also in ret. coord
    %quan: how many points are include
    %acc: accuracy of the contour line.



    %first get the distance of all points
    distan(:,1) = bpoints(:,1);
    distan(:,2) = bpoints(:,2);
    normdist=((solpoint(1,1)-bpoints(:,1)).^2 + ...
        (solpoint(1,2)-bpoints(:,2)).^2).^0.5;
    %invdist=((2+(solpoint(1,1)-bpoints(:,1))).^2 + ...
    %            (2+(solpoint(1,2)-bpoints(:,2))).^2).^0.5;

    distan(:,3) = normdist;
    %the x and y distance (needed for the angles)
    distan(:,4) = bpoints(:,1) - solpoint(1,1);
    distan(:,5) = bpoints(:,2) - solpoint(1,2);

    %changes distances if the distance is bigger than  one to d=2-dold
    dchan=normdist>1;
    distan(dchan,3)=2-distan(dchan,3);
    distan(dchan,4)=-distan(dchan,4);
    distan(dchan,5)=-distan(dchan,5)

    %get angles of the points around the result point
    n=length(distan);
    distan(:,6)=zeros(n,1);
    for i=1:1:n
        if (distan(i,4)>0 && distan(i,5)>=0)
            distan(i,6)=atan(distan(i,5)/distan(i,4));

        elseif (distan(i,4)>0 && distan(i,5)<0)
            distan(i,6)=atan(distan(i,5)/distan(i,4))+2*pi;

        elseif (distan(i,4)<0)
            distan(i,6)=atan(distan(i,5)/distan(i,4))+pi;

        elseif (distan(i,4)==0 && distan(i,5)>0)
            distan(i,6)=pi/2;

        elseif (distan(i,4)==0 && distan(i,5)<0)
            distan(i,6)=(3*pi)/2;
        end

    end



    %sort the matrix
    distan=sortrows(distan,3);

    %shorten the matirx with quan of the points
    selpoint=(distan(1:round(n*quan),:));

    %now selected acc points with the angle

    incer=2*pi/acc;

    cline=zeros(acc+1,6);
    for j=1:1:acc

        selected = selpoint(find(selpoint(:,6)>=(j-1)*incer & ...
            selpoint(:,6)<j*incer),:);

        if isempty(selected)
            %        cline(j,:)=zeros(1,6)
            cline(j,:)=NaN;
        else
            [valu, ind] = max(selected(:,3));

            cline(j,:) = selected(ind,:);
        end
    end


    %to close the line
    cline(acc+1,:)=cline(1,:);


end
