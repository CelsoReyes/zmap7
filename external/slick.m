function [varargout] = slick(coords)
    % turned into MATLAB from C by Celso G Reyes
    % accepts input of [DipDir, Dip, Rake]
    % returns different items, based on varargout.
    
    % answer is CLOSE to original, but does not match.  Sig Figs? Technique?
    
    TORADS = 57.29577951;
    
    % COORDINATES ARE EAST,NORTH,UP
    % this version does no statistics
    % and therefore makes no plot
    
    assert(size(coords,2) == 3); % [ ddir, dip, rake ] as ENU
    
    % ddir = zeros(MAXDATA,1);  % dip direction for data
    % dip = zeros(MAXDATA,1);   % dip of data
    % rake = zeros(MAXDATA,1);  % rake of data
    % amat = zeros(MAX3,5);  % coefficient matrix for normal equation
    % stress = zeros(6,1);  % stress tensor in vector form, element order is:
    % xx,xy,xz,yy,yz,zz
    % slick_vec_el_vec  slickenside vector elements vector
    % norm  % storage of n1,n2,n3
    char name(20);      % output file name
    %FILE *fpin;   % input file pointer
    %FILE *fpout;  % output file pointer
    %FILE *fplot;  % plot file pointer
    % sigma = 0;  % for use with leasq subr
    % a2i = zeros(5,5);  % to get covariance mtrix
    line='';  % character line
    t = zeros(3,1);  % shear stress vector
    % iso = 0;  % isotropic stress mag
    %angavg = 0; angstd = 0;  % average and standard deviation of fit angle
    %isoavg = 0; isostd = 0;  % same for isotropic stress size
    magavg = 0; magstd = 0;  % same for tangential stress size
    % tf = zeros(3,1), tnorm;  % full traction vector
    % and normal traction
    
    % get file pointers
    %{
    -- argc;
    ++argv;
    if argc == 0
        printf("usage: slick data_file\n");
        return;
    end
    fpin = fopen(argv,"r");
    if fpin==NULL
        printf("unable to open %s.\n",argv);
        return;
    end
    fprintf(name,"%s.oput",argv);
    %}
    % read and write comment line from data file to output file
    % fgets(line,80,fpin);
    line = 'Inversion data';
    fpout = string(line);
    ddir = coords(:,1);
    dip = coords(:,2);
    rake = coords(:,3);
    % loop to get data and make up equation
    for i=1:size(coords,1)
        %ddir = coords(i,1); dip = coords(i,2); rake = coords(i,3);
        j = 3*i;%?
        
        z = ddir(i)/TORADS;
        z2 = dip(i)/TORADS;
        z3 = rake(i)/TORADS;
        
        %n1 to n3 are normal vector elements
        n1 = sin(z)*sin(z2);  % normal vector to fault plane
        n2 = cos(z)*sin(z2);
        n3 = cos(z2);
        
        norm(i,1:3) = [n1 n2 n3];
        
        % slickenside vector calculation
        slick_vec_el_vec(j,1)= -cos(z3)*cos(z) - sin(z3)*sin(z)*cos(z2);
        slick_vec_el_vec(j+1,1)= cos(z3)*sin(z) - sin(z3)*cos(z)*cos(z2);
        slick_vec_el_vec(j+2,1)= sin(z3)*sin(z2);
        
        % find the matrix elements
        amat(j:j+2, 1:5) = [...
            n1-n1*n1*n1+n1*n3*n3,  n2-2.*n1*n1*n2, n3-2.*n1*n1*n3, -n1*n2*n2+n1*n3*n3,    -2.*n1*n2*n3 ;...
            -n2*n1*n1+n2*n3*n3,    n1-2.*n1*n2*n2, -2.*n1*n2*n3,   n2-n2*n2*n2+n2*n3*n3,  n3-2.*n2*n2*n3;...
            -n3*n1*n1-n3+n3*n3*n3, -2.*n1*n2*n3,   n1-2.*n1*n3*n3, -n3*n2*n2-n3+n3*n3*n3, n2-2.*n2*n3*n3];
        
        % check to see if all possible data has been read
    end  % end of data read loop

	% solve equations via linear least squares
	[stress, sigma]=leasq(amat,slick_vec_el_vec);
	% correct zz element by using trace = 0
	stress(6)= -(stress(1)+stress(4));

	% put stress tensor into tensor form
    strten = [  stress(1),    stress(2),   stress(3) ; 
                stress(2),    stress(4),   stress(5) ; 
                stress(3),    stress(5),   stress(6)];

    %fpout(end+1)=sprintf("\nCOORDINATES ARE EAST,NORTH,UP.");
    %fpout(end+1)=sprintf("stress tensor is:");
    for i=1:3
    %    fpout(end+1)=sprintf("%g  %g  %g  ",strten(i,:));
    end

	% find  eigenvalues and eigenvectors
    [vecs,lam] = eig(strten,"vector"); %LAM is eigenvalues, VECS is eigenvectors
    % eigen(strten,lam,vecs);
    %fpout(end+1)=sprintf("eigenvalue   vector: E,N,UP,direction,plunge");
    for i = 3:-1:1
        [v_direction(i), v_plunge(i)] = dirplg(vecs(1,i),vecs(2,i),vecs(3,i));
        %[z, z2] = dirplg(vecs(1,i),vecs(2,i),vecs(3,i));
        %fpout(end+1)=sprintf("%g  ",lam(i)) +...
        %    sprintf("%g  %g  %g  ",vecs(:,i)) +...
        %    sprintf("%f  %f",z,z2);
    end
    %fpout(end+1)=sprintf("variance= %g",sigma);
    
	% order eigenvalues and compute phi
    %lam=sort(lam,'descend');
    
    if lam(1) ~= lam(3)
        phi = (lam(2)-lam(3)) / (lam(1)-lam(3));
        %fpout(end+1)=sprintf("phi value= %g",phi);
    else
        phi=nan;
    end
	% output data and fit angle

	angavg = 0.;
	angstd = 0.;
	isoavg = 0.;
	isostd = 0.;
	iso = 0.;
	%fpout(end+1)=sprintf("\ndip direction, dip, rake, fit angle, mag tau");
    nobs=size(coords,1);
    for i=1:nobs %from 0
        
        for j= 1 : 3 %from 0  % compute shear traction
            t(j)=0;
            tf(j)=0;
            myt(j) = sum(amat(3*(i-1)+j) * stress(1:5));
            for k=1:5
                t(j) = t(j)+ amat(3*(i-1)+j,k) * stress(k);
            end
            for k=1:3
                tf(j) = tf(j) + strten(j,k) * norm(i,k);
            end
        end
        tnorm = 0;
        for k=1:3
            tnorm = tnorm + tf(k) * norm(i,k);
        end
        % find angle between t and slickenside
        z = 0.;
        for j=1:3
            z = z + t(j)*slick_vec_el_vec(3*(i-1)+j);
        end
        z2 = 0.;
        for j=1:3
            z2 = z2 + t(j)*t(j);
        end
        z2 = sqrt(z2);
        z3 = 0.;
        for j=1:3
            z3 = z3 + slick_vec_el_vec(3*(i-1)+j)*slick_vec_el_vec(3*(i-1)+j);
        end
        z3 = sqrt(z3);
        z = z/(z2*z3);
        z = acos(z)*TORADS;
        angavg = angavg + z;
        angstd = angstd + z*z;
        z3= (z2/(-0.8)) - tnorm;
        iso = iso + abs(tnorm);
        isoavg = isoavg +z3;
        isostd = isostd + z3*z3;
        magavg = magavg +z2;
        magstd = magstd + z2*z2;
        %fpout(end+1)=sprintf("%7.1f  %7.1f  %7.1f  %7.1f %7.2f", ddir(i),dip(i),rake(i),z,z2);
    end
    z3 = nobs-1;
    angstd = angstd-(angavg*angavg/nobs);
    angstd = angstd/z3;
    angstd = sqrt(angstd);
    angavg = angavg/nobs;
    
    isostd = isostd-(isoavg*isoavg/nobs);
    isostd = isostd/z3;
    isostd = sqrt(isostd);
    isoavg = isoavg/nobs;
    iso = iso / nobs;
    isoavg = isoavg / iso;
    isostd = isostd / iso;
    
    magstd = magstd-(magavg*magavg/nobs);
    magstd = magstd/z3;
    magstd = sqrt(magstd);
    magavg = magavg/nobs;
    
    %fpout(end+1)=sprintf("fit angle mean= %f standard deviation= %f",angavg,angstd);
    %fpout(end+1)=sprintf("for f=0.8 I= %f , std. dev.= %f D norm= %f", isoavg,isostd,iso);
    %fpout(end+1)=sprintf("avg tau= %f , std. dev.= %f",magavg,magstd);
    
    if nargout==1
        fpout(end+1)=sprintf("fit angle mean= %f standard deviation= %f",angavg,angstd);
        fpout(end+1)=sprintf("for f=0.8 I= %f , std. dev.= %f D norm= %f", isoavg,isostd,iso);
        fpout(end+1)=sprintf("avg tau= %f , std. dev.= %f",magavg,magstd);
    
    varargout = {strjoin(fpout,newline)};
    elseif nargout == 5
        varargout={angavg, angstd, magstd/magavg, magavg, magstd}; %[fBeta2, fStdBeta2, fTauFit2, fAvgTau2, fStdTau2]
    elseif nargout == 9
        varargout=fastoutput();
    end
    
    function output = fastoutput()
        %%line 1
        % variance
        output = {... line 1 of output file
            sigma,... variance
            stress,...      stress tensor upper triangle
            ... line 2 of output file
            phi,...
            round(v_direction(1),1),...
            round(v_plunge(1),1),...
            round(v_direction(2),1),...
            round(v_plunge(2),1),...
            round(v_direction(3),1),...
            round(v_plunge(3),1)...
            };
    end
        
        
end

function [pdir, pplg]  = dirplg(e,n,u)
    % dirplb to find direction and plunge of a vector
    % double e,n,u; /* the vector in east,north,up coordinates
    % double *pdir,*pplg are pointers to the direction in east of north
    % and the plunge down the direction
    
    TORADS = 57.29577951;
    
    z=e*e+n*n;
    z=sqrt(z);
    pplg=atan2(-u,z) * TORADS;
    if pplg<0
        pplg= -pplg;
        e= -e;
        n= -n;
    end
    pdir=atan2(e,n) * TORADS;
end

function [x, psis] = leasq(a,b)
% /* finds the least squares solution of ax=b */
%{
double a[]; /* the coefficients matrix with n rows and m columns */
double x[]; /* the solution vector of length m */
double b[]; /* the constant vector of length n */
double a2[]; /* a square matrix of size m for internal use */
double c[]; /* vector of length m for internal use */
double *psis; /*pointer to the variance */

/* steps 1 a2= a transpose a */
/*       2 c= a transpose b */
/*       3 solve a2x=c by gaussian elimination */
%}

	% a2=atransa(a,a2); % computes b=a transpose*a 
    a2 = a' * a;
    c = a' * b;
    x = a2 \ c;
	% x = gaus(a2, c); % solves ax=b for x by gaussian elimination
	psis = sigsq(a,x,b);
end
%{
function x = gaus(a,b)
    % /* solves ax=b for x by gaussian elimination */


%double a[];  /* a square matrix of size m */
%double b[];  /* a vector of length m */
%double x[];  /* a vector of length m */
    
    m=length(a);
    %  take care of special cases */
    if m<2
        x=0;
        if m==1
            x=b/a;
        end
        return
    end
        

	for i=1:m % (i=0;i<m;++i)   %  /* loop for each pivot */
		for i2=i+1:m %  /* loop for each row below a pivot */

			% /* see if element below pivot is 0 */
			if(a(i2,i)==0.) 
                continue
            end

			% /* if element below pivot > pivot flop rows  */
			if(abs(a(i2,i))>abs(a(i,i)))
				hold=b[i];
				b[i]=b[i2];
				b[i2]=hold;
				for(i3=i;i3<m;++i3)
					hold=a(i,i3);
					a(i,i3)=a(i2,i3);
					a(i2,i3)=hold;
                end
            end

			% /* do the elimination */ 
			fact=a(i2,i)/a(i,i);
			a(i2,i)=0.;
			for(i3=i+1;i3<m;++i3)
                a(i2,i3)=a(i2,i3)-fact*a(i,i3);
            end
			b[i2]=b[i2]-fact*b[i];


        end
    end

	/* solve the equations */
	x[m-1]=b[m-1]/a[m*m-1];
	for(i=m-2;i> -1;--i){
		d=b[i];
		for(i2=i+1;i2<m;++i2)
            d=d-x[i2]*a(i,i2);
        end
		x[i]=d/a(i,i);
	}
	return;
}

end
%}



function psis = sigsq(a,x,b)
% SIGSQ  computes the variance of a single observation */
% double a[];    /* matrix of n rows and m columns */%
% double b[];    /* data vector length n*/
% double x[];    /* solution vector length m */
% double *psis;  /* where to put answer */
% short m,n;     /* see above */

	% double y,z,z2;     /* sum variables */

    [n,m] = size(a);
    allY = a * x; % nx1
    z=sum(b-allY).^2;

	if n ~= m
		z2 = n - m;
		z = z/z2;
    end
	psis=z;
end

