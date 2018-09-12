function dbfprintf(varargin)
    if ~ZmapGlobal.Data.debug
        return
    end
    if isstring(varargin{1}) 
        fmtstr = char(varargin{1});
    else
        fmtstr = varargin{1};
    end
        
    if nargin>1
        fprintf(['\n---<strong> ZMAP DB: </strong>' fmtstr], varargin{2:end});
    else
        fprintf(['\n---<strong> ZMAP DB: </strong>' fmtstr]);
    end
end