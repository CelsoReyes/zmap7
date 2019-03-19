function[out] = bootrsp(indata,B)
    %   BOOTRSP Bootstrap  resampling  procedure
    %
    %   out=bootrsp(indata,B)
    %
    %     Inputs:
    %        indata - input data
    %         B - number of bootstrap resamples (default B=1)
    %     Outputs:
    %       out - B bootstrap resamples of the input data
    %
    %   For a vector input data of size [N,1], the  resampling
    %   procedure produces a matrix of size [N,B] with columns
    %   being resamples of the input vector.
    %
    %   For a matrix input data of size  [N,M], the resampling
    %   procedure produces a 3D matrix of  size  [N,M,B]  with
    %   out(:,:,i), i = 1,...,B, being a resample of the input
    %   matrix.
    %
    %   Example:
    %
    %   out=bootrsp(randn(10,1),10);
    
    %  Created by A. M. Zoubir and D. R. Iskander -  May 1998
    %  Modified by C Reyes 2018, to leverage randi
    %
    %  References:
    %
    %  Efron, B.and Tibshirani, R.  An Introduction to the Bootstrap.
    %               Chapman and Hall, 1993.
    %
    %  Zoubir, A.M. Bootstrap: Theory and Applications. Proceedings
    %               of the SPIE 1993 Conference on Advanced  Signal
    %               Processing Algorithms, Architectures and Imple-
    %               mentations. pp. 216-235, San Diego, July  1993.
    %
    %  Zoubir, A.M. and Boashash, B. The Bootstrap and Its Application
    %               indata Signal Processing. IEEE Signal Processing Magazine,
    %               Vol. 15, No. 1, pp. 55-76, 1998.
    
    if ~exist('B','var')
        B=1;  
    end
    if ~exist('indata','var')
        error('Provide input data'); 
    end
    
    s = size(indata);
    if length(s)>2
        error('Input data can be a vector or a 2D matrix only');
    end
    if min(s)==1
        out = indata(randi(max(s) , max(s),B));
    else
        out = indata(randi(s(1)*s(2) , s(1),s(2),B));
    end
end





