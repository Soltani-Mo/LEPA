function [design, params] = ForwardBackwardSolver(design, params)



vals = 1 ./ (1i .* (design.eps_r_vec - 1) .* params.physics.ep0 );
if params.solver.useGPU
    vals = gpuArray(complex(vals));
end

%% Solve The Problem

design.JF = zeros(params.lens.NS, params.Config.nG, params.Config.nF);
design.JA = zeros(params.lens.NS, params.Config.nP * params.Config.nG, params.Config.nF);
EiA = zeros(params.lens.NS, params.Config.nP * params.Config.nG);
design.Dir_mag = zeros(params.Config.Nphi + 1, params.Config.nG, params.Config.nF);
design.Sgncost = zeros(params.Config.nP, params.Config.nG, params.Config.nF);
design.cost = zeros(params.Config.nG, params.Config.nF);
design.Eff = zeros(params.Config.nP, params.Config.nG, params.Config.nF);

for bb = 1:params.Config.nF

    design.X = sparse( diag(vals ./ design.omega_vec(bb) ) );

    L = design.X - design.Gvv(:, :, bb);

    design.JF = L \ design.EiF(:, :, bb);

    if params.solver.useGPU

        design.JF(:, :, bb) = gather(design.JF);

    end

    % E_Apertures_F = params.Gv_F(:, :, bb) * JF(:, :, bb); % NS x nG = NS x nG x nF
    % 
    % E_Aperture_F = E_Aperturei_F(:, :, bb) + E_Apertures_F;
    % 
    % 
    % E_Apertures_F_Out1 = params.Gv_Out1(:, :, bb) * JF(:, :, bb); % NS x nG = NS x nG x nF
    % 
    % E_Aperture_Out1 = params.E_Aperturei_F_Out1(:, :, bb) + E_Apertures_F_Out1;
    % 
    % E_Apertures_F_Out2 = params.Gv_Out2(:, :, bb) * JF(:, :, bb); % NS x nG = NS x nG x nF
    % 
    % E_Aperture_Out2 = params.E_Aperturei_F_Out2(:, :, bb) + E_Apertures_F_Out2;


    %% %%%%%%%%%%%%%%%%%%%%%%%%%%  Calculate Directivity %%%%%%%%%%%%%%%%%%%%%%%%%%%


    EffFs = design.Gff(:, :, bb) * design.JF(:, :, bb);  % nF x nG <-- (nF x NS) * (NS * nG)

    design.EffF = design.EffFi(:, :, bb) + EffFs;

    U = (abs(design.EffF).^2);

    Uave = sum(U .* params.Config.dphi)/(2 * pi);

    design.Dir_mag(:, :, bb) = U./Uave; % nE x (Nphi + 1) x nG x nF

    pg = 0;
    for gg = 1:params.Config.nG


        design.cost(gg, bb) =  sum( abs(design.Dir_goal(params.Config.range{gg}, gg, bb)...
            -  design.Dir_mag(params.Config.range{gg}, gg, bb)), 1);

        design.Sgncost(:, gg, bb) = sign(design.Dir_goal(params.Config.range{gg}, gg, bb)...
            -  design.Dir_mag(params.Config.range{gg}, gg, bb));

         %% aperture efficiency calculation

            design.AprEffrecorder(params.solver.iter, gg, bb) = 2 * max(design.Dir_mag(:, gg, bb)) * params.lambda0 / (2 * pi * params.lens.Wout);


        %% 


        EffFi_Slice = design.EffFi(params.Config.range{gg}, gg, bb);

        R_Slice = design.R(:, :, gg, bb);

        Effs = R_Slice * design.JF(:, gg, bb);

        design.Eff(:, gg, bb) = EffFi_Slice + Effs;

        for pp = 1:params.Config.nP

            pg = pg + 1;

            EiA(:, pg) = -design.R(pp, :, gg, bb).';

        end

    end


    if params.solver.useGPU

        EiA = gpuArray(complex(EiA));

        JA_gpu = L \ EiA;

        design.JA(:, :, bb) = gather(JA_gpu);

    else

        design.JA(:, :, bb) = L \ EiA;  % NS x nP x nG x nF

    end
    

end

design.JA = reshape(design.JA, params.lens.NS, params.Config.nP, params.Config.nG, params.Config.nF);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Decision Making %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if params.solver.Apply_IterBatching

    idx = mod(params.solver.iter - 1, params.solver.IterBatchSize) + 1;

    if idx <= params.Config.nG
        % Sequentially initialize each group
        design.new_gg = idx;
        design.new_bb = 1;
    else
        % Select the best candidate after all groups have been visited
        % cost1 = design.cost(:, :);
        [~, linIndex] = max(design.cost(:, :));
        [design.new_gg, design.new_bb] = ind2sub(size(design.cost(:, :)), linIndex);
    end

else
    % cost1 = cost(:, :, 1);
    [~, linIndex] = max( design.cost(:, :) );
    [design.new_gg, design.new_bb] = ind2sub(size(design.cost(:, :)), linIndex);

end



% if params.analyzer.Spatial_Transfer_Matrix_Flag
%      if params.Use_GPU
%         if params.Use_GG_GPU
%             params.L_gpu = P - params.GG_gpu(:, :, params.bb0);
%         else
%             params.L_gpu = P - gpuArray(complex(params.GG(:, :, params.bb0)));
%         end
%      else
%         params.L = P - params.GG(:, :, params.bb0);
%      end
% end



end
