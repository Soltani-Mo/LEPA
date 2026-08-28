function SaveData(design, params)

eps_r_vec = design.eps_r_vec;
filename = sprintf('%s_eps_r_vec.mat', params.mainFilename);
save(fullfile(params.folderPath, filename), 'eps_r_vec', '-v7.3');

filename = sprintf('%s_params.mat', params.mainFilename);
save(fullfile(params.folderPath, filename), 'params', '-v7.3');

end