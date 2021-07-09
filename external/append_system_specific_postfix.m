function specific_filename = append_system_specific_postfix(base)
    % append ending to filename, depending on system
    % convention for the external programs seems to be:
    % if mac --> _maci64
    % if pcwin --> .exe
    % if linux --> _linux
    
    switch computer
        case 'GLNXA64'
            postfix = '_linux';
        case 'MACI64'
            postfix = '_maci64';
        case 'PCWIN64'
            postfix = '.exe';
        otherwise
            error('unknown computer type')
    end
    specific_filename = [base, postfix];
end