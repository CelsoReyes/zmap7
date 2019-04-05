function set_rotation_pointer(h)
    %set rotation pointer rotate
    zz=load('rotate.mat');
    val = sum(zz.cdata,3)+1;
    h.Pointer='custom';
    h.PointerShapeCData=[nan(1,16);val];
end