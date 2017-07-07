%
% This algorithm constructs a Sierpinski Gasket using the chaos game method.
% Francesco Pacchiani 8/2000.
%
%
sierfd = [];
sierfd = zeros(50,1);

for g = 1:50

    p1 = [0 0 0];
    p2 = [1 0 0];
    p3 = [0.5 0.866 0];
    p4 = [0.5 0.433 0.75];
    z = [rand(1,1) rand(1,1) rand(1,1)];
    Sier = [];
    Sier = zeros(5000,3);
    Sier(1,:) = z;

    for k = 2:5000

        n = ceil(rand(1,1)*4);

        if n == 1
            p = p1;
        elseif n == 2
            p = p2;
        elseif n == 3
            p = p3;
        elseif n == 4
            p = p4;
        end %if n

        z = [z(1,1)*0.5 + p(1,1)*0.5, z(1,2)*0.5 + p(1,2)*0.5, z(1,3)*0.5 + p(1,3)*0.5];
        Sier(k,[1 2 3]) = z;

    end %for k


    Sier = Sier(16:5000,:);
    Sier = [Sier(:,1)*0.18 Sier(:,2)*0.18 Sier(:,3)*20];
    Sier = [Sier(:,1) Sier(:,2) zeros(size(Sier,1),1) zeros(size(Sier,1),1) zeros(size(Sier,1),1) zeros(size(Sier,1),1) Sier(:,3)];
    E = Sier;
    dtokm = [1];
    range = [1];
    radm = [];
    rasm = [];
    pdc3nofig;
    fdallfig;
    sierfd(g) = coef(1,1);

end


%HSier = figure;
%plot3(Sier(:,1), Sier(:,2), Sier(:,7), 'k.', 'Markersize', 4);

%a = Sier;
%update(mainmap());
