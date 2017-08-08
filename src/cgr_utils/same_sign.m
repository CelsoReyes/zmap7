function tf = same_sign(v1, v2)
    % returns true if both values have same sign: both +, both -, or both 0
    tf = sign(v1) == sign(v2);
end