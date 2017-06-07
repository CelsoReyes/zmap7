report_this_filefun(mfilename('fullpath'));

save_aspar2;
do = [ ' ! '  hodi '/aspar/myaspar' ];
eval(do)


try
    load aspar3.out
catch ME
    error_handler(ME,@do_nothing);
end

re = aspar3;

bv = re(2,2);
p =  re(1,2);
c =  re(4,2);
A =  re(3,2);







