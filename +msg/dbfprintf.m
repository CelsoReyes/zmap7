function dbfprintf(varargin)
    if ~ZmapGlobal.Data.debug
        return
    end
    if nargin>1
        fprintf(['\n---<strong> ZMAP DB: </strong>' varargin{1}], varargin{2:end});
    else
        fprintf(['\n---<strong> ZMAP DB: </strong>' varargin{1}]);
    end
end