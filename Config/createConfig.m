function params = createConfig(params)

params.units.cm = 1e-2;
params.units.mm = 1e-3;

params.physics.mu0 = 4 * pi * 1e-7;
params.physics.eta0 = 120*pi;
params.physics.ep0 = 8.85e-12;


switch params.Config.function

    case "Angular_Compression"

        Nin = (2 * params.array.Win / params.lambda0);
        delta = (1 - ((-1)^floor(Nin)))/4;
        Np = ceil(floor(Nin)/2);
        half_Nin_mat = 1:0.5:Np;
        % half_Nin_mat = Np;
        params.Config.phi_s = asind(((half_Nin_mat - delta) .* (params.lambda0/params.array.Win)) - 1);
        params.Config.phi_t = asind(((half_Nin_mat - delta) .* (params.lambda0/params.lens.Wout)) - (params.array.Win/params.lens.Wout));

    case "Coherent_Expansion"

        Nin = (2 * params.array.Win / params.lambda0);
        Np = ceil(floor(Nin)/2);
        half_Nin_mat = 1:Np;
        % half_Nin_mat = Np;
        delta = (1 - ((-1)^floor(Nin)))/4;

        params.Config.phi_s = asind(((half_Nin_mat - delta) .* (params.lambda0/params.array.Win)) - 1);
        params.Config.phi_t = params.Config.phi_s;


    otherwise
        error("Unknown lens functionality.");

end

params.Config.nF = numel(params.freq_range);
params.Config.nG = numel(params.Config.phi_s);

params.Config.Nphi = 1080;
params.Config.dphi = 2*pi/params.Config.Nphi;
params.Config.Phi = ( - pi : params.Config.dphi : + pi ).';

params.Config.range = cell(1, params.Config.nG);

[~, params.Config.bb0] = min(abs(params.freq_range - params.f0));

Ang_Res = 0.886 * params.lambda0 / params.lens.Wout;
ds     = 2;                        % downsampling factor (>=1)

for gg = 1:params.Config.nG

    halfWidth = floor(5 * Ang_Res / params.Config.dphi);
    [~, centerIdx] = min(abs(params.Config.Phi - (params.Config.phi_t(gg) * pi / 180)));
    idx_range = (centerIdx - halfWidth):(centerIdx + halfWidth);
    % idx_range = centerIdx;

    % Apply downsampling
    idx_range = idx_range(1:ds:end);

    % store
    params.Config.range{gg} = idx_range;

    params.Config.nP = numel(params.Config.range{gg});

end

if params.Config.nG == 1
    half_phi_step = 5;
else
    half_phi_step = (params.Config.phi_s(2) - params.Config.phi_s(1))/2;
end
params.Config.phi_range_span = [params.Config.phi_s - half_phi_step, half_phi_step];

if params.Config.nF == 1
    half_freq_step = 0.5e9;
else
    half_freq_step = (params.freq_range(2) - params.freq_range(1))/2;
end

params.Config.freq_range_span = [params.freq_range - half_freq_step, params.freq_range(end) + half_freq_step];

timestamp = string(datetime('now', 'Format', 'yyyyMMdd_HHmmss'));
params.mainFilename = strcat(params.Config.function, '_', ...
    params.lens.shape, sprintf('_%s', timestamp));

Main_Folder_Name = ['SaveResults', params.mainFilename];
params.folderPath = fullfile(Main_Folder_Name{:});

mkdir(fullfile('SaveResults',params.mainFilename));

if params.Config.nG >= params.solver.IterBatchSize
    error('nG >= IterBatchSize');
end

end