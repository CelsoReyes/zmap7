function A = toggleOnOff(A)
    %TOGGLEONOFF toggles a state between 'on' and 'off'
    %
    % A = TOGGLEONOFF(B) if B is 'on', then A is 'off' and vice-versa.
    curState=matlab.lang.OnOffSwitchState(A);
    if curState
        A='off';
    else
        A='on';
    end
end