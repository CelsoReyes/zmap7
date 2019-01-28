function tf = iscartesian(RefEllipsoid)
    % see if a referenceEllipsoid represents a cartesian system instead of an ellipsoid
    assert(isa(RefEllipsoid,'referenceEllipsoid'));
    tf = isa(RefEllipsoid,'nonEllipsoid');
end