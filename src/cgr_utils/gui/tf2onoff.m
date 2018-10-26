function out = tf2onoff(val, flip)
    % TF2ONOFF returns 'on' if true-ish, 'off' if false-ish.  adding 'flip' to end reverses the answer.
    ooss = matlab.lang.OnOffSwitchState(val);
    if nargin==2 && flip=="flip"
        ooss = matlab.lang.OnOffSwitchState(~ooss);
    end
    out=char(ooss);
end