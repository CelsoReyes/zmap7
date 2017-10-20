
function h=myarrow()

    %  [handle]=myarrow
    %
    %  Draws an arrow  by clicking between two points (tail, head)
    %  on the current figure, and returns the arrow's handle.
    %  Uses ARROW.
    %
    %  Richard G. Cobb 3/96

    axis(axis)
    [x,y]=ginput(2);
    start=[x(1),y(1)];
    stop=[x(2),y(2)];

    h=arrow(start,stop);
    %eof
