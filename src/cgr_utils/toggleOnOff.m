function A = toggleOnOff(A)
    %TOGGLEONOFF toggles a state between 'on' and 'off'
    %
    % A = TOGGLEONOFF(B) if B is 'on', then A is 'off' and vice-versa.
    
    if A == "on"
        A='off';
    else
        A='on';
    end
end