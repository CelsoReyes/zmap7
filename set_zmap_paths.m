function set_zmap_paths()
    % add relevant paths
    hodi = fileparts(which('zmap'));
    path_list = [
        {hodi};
        fullfile(hodi, {'src';
                        'help';
                        'dem';
                        'zmapwww';
                        'importfilters';
                        'm_map';
                        'resources';
                        });
        fullfile(hodi, 'resources', {'features';'sample'});
        fullfile(hodi, 'src',{'afterrate';
                              'cgr_utils';
                              'declus';
                              'fractal';
                              'pvals';
                              'synthetic';
                              'utils'});
       {fullfile(hodi, 'src', 'danijel')};
       fullfile(hodi, 'src', 'danijel', {'calc';
                                         'ex';
                                         'focal';
                                         'gui';
                                         'plot';
                                         'probfore'});
       {fullfile(hodi, 'src', 'jochen')};
       fullfile(hodi, 'src', 'jochen', {'auxfun';
                                        'ex';
                                        'plot';
                                        'seisvar';
                                        'stressinv'});
       fullfile(hodi, 'src', 'jochen', 'seisvar', 'calc');
       {fullfile(hodi, 'src', 'thomas')};
       fullfile(hodi, 'src', 'thomas', {'decluster';
                                        'etas';
                                        'montereason';
                                        'slabanalysis';
                                        'seismicrates';
                                        });
       fullfile(hodi, 'src', 'thomas', 'decluster', 'reasen');
        ];
    addpath(path_list{:});
    ZG=ZmapGlobal.Data;
    % set some of the paths
    ZG.out_dir = fullfile(hodi,'out');
    ZG.data_dir = fullfile(hodi, 'eq_data');
end