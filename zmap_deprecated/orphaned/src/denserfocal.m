%function to determine a density field in a stereonet type plot
%input in polar coordinates
%rho: the distance of the points
%theta: angle of the points
%radius: radius of the countercircle, kind of grid size
%output is a matrix cartesian coordinates (x,y,density)

function [densfield] = denserfocal(rho,theta,radius)

    %get the number of events
    totalev=length(rho);

    %first do the middle circle (densR=0)

    %find the values lower than radius and count
    counting=length(find(rho(:,1)<=radius));

    if counting>0
        densfield(1,1)=0;
        densfield(1,2)=0;
        densfield(1,3)=counting/totalev;
    else
        densfield(1,3) = NaN;
        densfield(1,1) = 0;
        densfield(1,2) = 0;
    end


    %set densR to start value radius
    densR=radius;

    %set the counters for the result matrix
    j=2;

    %loop for the distance
    while densR<=1+radius

        %calculate stepwidth for the angle
        dalpha=2*asin(radius/(2*densR));

        %set angle to 0
        densalpha=0;

        %second loop for the angle
        while densalpha<=2*pi
            %calculate the distance between the middle of the circle and
            %the points
            distery=(rho.^2+densR^2-2.*rho.*densR.*cos(abs(densalpha-theta))).^0.5;

            %find the values lower than radius and count
            counting=length(find(distery(:,1)<=radius));

            %write values if counting>0
            if counting>0
                densfield(j,3) = counting/totalev;
                densfield(j,1) = densR * cos(densalpha);
                densfield(j,2) = densR * sin(densalpha);
            else
                densfield(j,3) = NaN;
                densfield(j,1) = densR * cos(densalpha);
                densfield(j,2) = densR * sin(densalpha);

            end

            %increase j
            j=j+1;
            %increase densalpha
            densalpha=densalpha+dalpha;

        end

        %increase densR
        densR=densR+radius;
    end

end
