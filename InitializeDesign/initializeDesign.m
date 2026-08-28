function [design, params] = initializeDesign(params)

design.Dir_goal = zeros(params.Config.Nphi + 1, params.Config.nG, params.Config.nF);
design.Dir_inc = zeros(params.Config.Nphi + 1, params.Config.nG, params.Config.nF);

design.CESJN = zeros(1, params.Config.nF);
design.CEMJN = zeros(1, params.Config.nF);
design.CESJF = zeros(1, params.Config.nF);
design.CEMJF = zeros(1, params.Config.nF);
design.CEMMN = zeros(1, params.Config.nF);
design.CEMMF = zeros(1, params.Config.nF);
design.CJMJF = zeros(1, params.Config.nF);
design.Precomputed_besselh0_d = zeros(1, params.Config.nF);

if params.lens.shape == "Flat"
    design.k_r0_d = zeros(1, params.Config.nF);
    design.CEMJN_dxS_dyS = zeros(1, params.Config.nF);
    design.CEMJF_dxS_dyS = zeros(1, params.Config.nF);
    design.CJMJF_dxS_dyS = zeros(1, params.Config.nF);
    r0_d = sqrt( params.lens.dxS * params.lens.dyS / pi );
elseif params.lens.shape == "Cylindrical"
    design.CEMJN_drS_dphiS = zeros(1, params.Config.nF);
    design.CEMJF_drS_dphiS = zeros(1, params.Config.nF);
    design.CJMJF_drS_dphiS = zeros(1, params.Config.nF);
end

params.analyzer.LegendTitles = cell(1, params.Config.nF * params.Config.nG);

design.omega_vec = zeros(1, params.Config.nF);
design.k_vec = zeros(1, params.Config.nF);

rho = 1e5;

ii = 0;
for bb = 1:params.Config.nF

    k = 2 * pi / ( params.physics.c/params.freq_range(bb) );
    w = 2* pi * params.freq_range(bb);

    design.omega_vec(1, bb) = w;

    design.k_vec(1, bb) = k;

    design.CESJN(bb) = - k * params.physics.eta0 / 4;    % Constant for electric field of a single current J at near field
    design.CEMJN(bb) = - k * params.physics.eta0 / 4;    % Constant for electric field of a multiple current J at near field
    design.CJMJF(bb) = -1i * w * params.physics.mu0 * exp(-1i * k * rho) / sqrt( 8i * pi * k );
    design.CESJF(bb) = - params.physics.eta0 * k * exp(-1i * k * rho) * sqrt( 1i / ( 8 * pi * k ) ); % Constant for electric field of a single current M at far field
    design.CEMJF(bb) = -1i * w * params.physics.mu0 * exp(-1i * k * rho) / sqrt( 8i * pi * k );      % Constant for electric field of a multiple current J at far field
    design.CEMMN(bb) = k / (4i);
    design.CEMMF(bb) = 1i * k * exp(-1i * k * rho) / sqrt( 8i * pi * k );
    
    if params.lens.shape == "Flat"
        design.k_r0_d(bb) = k * r0_d;
        design.CEMJN_dxS_dyS(bb) = design.CEMJN(bb) * params.lens.dxS * params.lens.dyS;
        design.CJMJF_dxS_dyS(bb) = design.CJMJF(bb) * params.lens.dxS * params.lens.dyS;
        design.CEMJF_dxS_dyS(bb) = design.CEMJF(bb) * params.lens.dxS * params.lens.dyS;
        [~, Sshape] = self_term_H02_rect(k, params.physics.eta0, params.lens.dxS/2, params.lens.dyS/2, 1, 1e-6 * params.lens.dyS);
        design.Precomputed_besselh0_d(bb) = design.CEMJN_dxS_dyS(bb) * (1 - (2i/pi)*(log(design.k_r0_d(bb) / 2) + 0.57721566 + Sshape));
    elseif params.lens.shape == "Cylindrical"
        design.CEMJN_drS_dphiS(bb) = design.CEMJN(bb) * params.lens.drS * params.lens.dphiS;
        design.CJMJF_drS_dphiS(bb) = design.CJMJF(bb) * params.lens.drS * params.lens.dphiS;
        design.CEMJF_drS_dphiS(bb) = design.CEMJF(bb) * params.lens.drS * params.lens.dphiS;
    end

    for gg = 1:params.Config.nG

        ii = ii + 1;

        params.analyzer.LegendTitles(1, ii) = cellstr(['\phi_s = ', sprintf('%1.1f', params.Config.phi_s(gg)), ', f = ', num2str(params.freq_range(bb)/1e9)]);

        % %%%%%%%%%%%%%% Precompute Directivities Plot %%%%%%%%%%%%%%%%

        Eff = zeros(size(params.Config.Phi));

        Precomputed_factor_A = k * params.array.de * sind(params.Config.phi_t(gg));

        for qq = 1:params.geometry.nA

            Im = 1 * exp( -1i * (qq - 1) * Precomputed_factor_A );

            roup = sqrt( (params.geometry.xsA^2) + (params.geometry.ysA(qq)^2) );

            phip = atan2( params.geometry.ysA(qq), params.geometry.xsA );

            Eff = Eff + design.CEMJF(bb) * Im .* exp( 1i * k * roup .* cos(params.Config.Phi - phip) );

        end

        U = (abs(Eff).^2);
        Uave = sum(U .* params.Config.dphi)/(2*pi);
        design.Dir_goal(:, gg, bb) = U./Uave;

    end 

end 

design.ave_er2_er1 = ( ( params.material.epsMax + params.material.epsMin )/2 );
design.half_diff_er2_er1 = ( ( params.material.epsMax - params.material.epsMin ) / 2 );

%% Print Out Parameters

% Print information to terminal
fprintf('\n========================================\n');
fprintf('Main Code Name : %s\n', params.mainFilename);
fprintf('Folder Path    : %s\n', params.folderPath);
fprintf('========================================\n\n');
fprintf('Lens Function: %s\n', params.Config.function);
fprintf('Lens Shape: %s\n', params.lens.shape);
fprintf('Lens Tickness = %1.1f lambda0 \n',params.lens.thickness/params.lambda0);
fprintf('Lens Width = %1.1f lambda0 \n',params.lens.width/params.lambda0);
fprintf('Wout = %1.1f lambda0 \n', params.lens.Wout/params.lambda0);
fprintf('Win = %1.1f lambda0 \n', params.array.Win/params.lambda0);
disp(['Max. Iteration = ', num2str(params.solver.maxIter)]);
disp(['Size of the matrix (NS) = ', num2str(params.lens.NS)]);
disp(['Size of the plot matrix (NpX) = ', num2str(params.geometry.NpX), ' (NpY) = ',num2str(params.geometry.NpY)]);
disp(['Size of the Simulation Grid (NSh) = ', num2str(params.lens.NSh), ' (NSt) = ',num2str(params.lens.NSt)]);
% fprintf('dxS = %1.1f mm, dyS = %1.1f mm \n', params.lens.dxS * 1000, params.lens.dyS * 1000);
disp(['Total number of array elements (Ne) = ', num2str(params.array.Ne)]);
disp(['Total number of angle objectives (nG) = ', num2str(params.Config.nG)]);
disp(['Total number of frequency objectives (nF) = ', num2str(params.Config.nF)]);
disp(' ');
disp('Estimate Memory Requirement:');

bytes_per_complex = 16; % 8 bytes real + 8 bytes imaginary (double precision)
memory_Gp_EzJ = (params.geometry.NpX * params.geometry.NpY) * params.lens.NS * params.Config.nF * bytes_per_complex;
memory_GG = params.lens.NS * params.lens.NS * params.Config.nF * bytes_per_complex;
memory_EiF = params.lens.NS * params.Config.nG * params.Config.nF * bytes_per_complex;

total_memory_bytes = memory_Gp_EzJ + 2*memory_GG;
total_CPU_memory_gb = total_memory_bytes / (1024^3); % Convert to GB
total_GPU_memory_gb = (memory_GG + 4*memory_EiF) / (1024^3); % Convert to GB

fprintf('Total CPU memory: %.2f GB\n', total_CPU_memory_gb);
fprintf('Total GPU memory: %.2f GB\n\n', total_GPU_memory_gb);

if params.solver.useGPU
    if gpuDeviceCount == 0
        error('GPU Execution Error: No compatible GPU core is available on this system.');
    end
    
    my_gpu = gpuDevice();
    reset(my_gpu);
end

fprintf('Initializing design ...\n');
timerVal_G = tic;
%% Initialize matrices and vectors

design.EiF = zeros(params.lens.NS, params.Config.nG, params.Config.nF);
design.Gvv = zeros(params.lens.NS, params.lens.NS, params.Config.nF);

design.R = zeros(params.Config.nP, params.lens.NS, params.Config.nG, params.Config.nF);
design.EffFi = zeros(params.Config.Nphi + 1, params.Config.nG, params.Config.nF);
design.Gff = zeros(params.Config.Nphi + 1, params.lens.NS, params.Config.nF);
design.AprEffrecorder = zeros(params.solver.maxIter, params.Config.nG, params.Config.nF);

if params.lens.shape == "flat"
    design.Gl_ai = zeros(params.lens.NS, params.geometry.NYvec);
    design.Gao_l = zeros(params.geometry.NYvec, params.lens.NS);
    design.Gao_ai = zeros(params.geometry.NYvec, params.geometry.NYvec);

    design.E_Aperturei_F = zeros(params.geometry.NYvec, params.Config.nG, params.Config.nF);
    design.E_Aperturei_F_Out1 = zeros(params.geometry.NYvec, params.Config.nG, params.Config.nF);
    design.E_Aperturei_F_Out2 = zeros(params.geometry.NYvec, params.Config.nG, params.Config.nF);
    design.Gv_F = zeros(params.geometry.NYvec, params.lens.NS, params.Config.nF);
    design.Gv_In1 = zeros(params.geometry.NYvec, params.lens.NS, params.Config.nF);
    design.Gv_Out = zeros(params.geometry.NYvec, params.lens.NS, params.Config.nF);
    % design.Gv_Out2 = zeros(params.geometry.NYvec, params.lens.NS, params.Config.nF);
end


%% Populate Vectors and Matrices

if params.lens.shape == "Flat"
    
    % Field Point: Dielectric
    ii = 0;
    for n = 1:params.lens.NSY
    
        yv = params.lens.yS_values(n);
    
        for m = 1:params.lens.NSX
    
            xv = params.lens.xS_values(m);
    
            ii = ii + 1;
    
            for bb = 1:params.Config.nF
    
                k = design.k_vec(bb);
    
                for gg = 1:params.Config.nG
    
                    %%%%%%%%%%%%%%
                    % Populate Ei Forward
                    %%%%%%%%%%%%%%
    
                    design.EiF(ii, gg, bb) = IncidentEpatchArray( xv, yv, params.array.xj, params.array.yj, params.Config.phi_s(gg), params.array.phi_i, k, params.array.Ne, ...
                        params.array.de, design.CEMMN(bb), params.array.patch_er, params.array.patch_h, params.array.patch_a, params.array.patch_b  );
    
      
                    %% Calculate Radiation matrix
        
                    rp = sqrt((xv^2) + (yv^2));
        
                    phi_p = atan2(yv, xv);
        
                    for pp = 1:params.Config.nP
        
                        phi = params.Config.Phi(params.Config.range{gg}(pp));
        
                        design.R(pp, ii, gg, bb) = design.CJMJF_dxS_dyS(bb) * exp(1i * k * rp * cos(phi - phi_p));
        
                    end
                   
                end
    
                roup = sqrt((yv^2) + (xv^2));
    
                phip = atan2(yv, xv);
    
                design.Gff(:, ii, bb) = design.CEMJF_dxS_dyS(bb) * exp( 1i * k * roup .* cos(params.Config.Phi - phip) );
    
    
                %%%%%%%%%%%%%%%
                % Populate Gvv
                %%%%%%%%%%%%%%%
                % Source Point: Dielectric
                jj = 0;
                for nn = 1:params.lens.NSY
    
                    yvp = params.lens.yS_values(nn);
    
                    for mm = 1:params.lens.NSX
    
                        xvp = params.lens.xS_values(mm);
    
                        jj = jj + 1;
    
                        arg = k * sqrt( ((xv - xvp)^2) + ((yv - yvp)^2) );
    
                        if arg > design.k_r0_d(bb)
    
                            design.Gvv(ii, jj, bb) = design.CEMJN_dxS_dyS(bb) * besselh(0, 2, arg);
    
                        else
    
                            design.Gvv(ii, jj, bb) = design.Precomputed_besselh0_d(bb);
    
                        end
    
                    end
    
                end
    
            end
    
        end
    
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Populate Aperture Fields
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % for bb = 1:params.Config.nF
    % 
    %     k = design.k_vec(bb);
    % 
    %     for gg = 1:params.Config.nG
    % 
    % 
    %         % design.E_Aperturei_F(:, gg, bb) = E_For_Generator( params.geometry.xF, Y_vec, xi, yi(gg), xj, yj, phi_s(gg), params.phi_i, k, nE, dE, params.CEMMN(bb), params.patch_er, params.patch_h, params.patch_a, params.patch_b  );
    %         % 
    %         % design.E_Aperturei_F_Out1(:, gg, bb) = E_For_Generator( xv_Out1, Y_vec, xi, yi(gg), xj, yj, phi_s(gg), params.phi_i, k, nE, dE, params.CEMMN(bb), params.patch_er, params.patch_h, params.patch_a, params.patch_b  );
    %         % 
    %         % design.E_Aperturei_F_Out2(:, gg, bb) = E_For_Generator( xv_Out2, Y_vec, xi, yi(gg), xj, yj, phi_s(gg), params.phi_i, k, nE, dE, params.CEMMN(bb), params.patch_er, params.patch_h, params.patch_a, params.patch_b  );
    % 
    % 
    %     end
    % 
    % end

    %%%%%%%%%%%%%%%
    % Populate Gv_F, Gv_In, Gv_Out
    %%%%%%%%%%%%%%%
    
    for n = 1:params.geometry.NYvec

        yv = params.geometry.Y_vec(n);

        for bb = 1:params.Config.nF

            k = design.k_vec(bb);

            if bb == params.Config.bb0

                xv = params.lens.xv_In1(n);
                for nnn = 1:params.geometry.NYvec

                    xvp = params.lens.xv_Out(nnn);
                    yvp = params.geometry.Y_vec(nnn);

                    arg = sqrt( ((xv - xvp)^2) + ((yv - yvp)^2) );

                    design.Gao_ai(n, nnn) = (k/2i) * ((xv - xvp)/arg) * besselh(1, 2, k*arg) * params.lens.dyS;

                end

            end

            % Source Point: Dielectric

            jj = 0;
            for nn = 1:params.lens.NSY

                yvp = params.lens.yS_values(nn);

                for mm = 1:params.lens.NSX

                    xvp = params.lens.xS_values(mm);

                    jj = jj + 1;

                    % xv = xF(n);
                    % arg = k * sqrt( ((xv - xvp)^2) + ((yv - yvp)^2) );
                    % design.Gv_F(n, jj, bb) = design.CEMJN_dxS_dyS(bb) * besselh(0, 2, arg);

                    xv = params.lens.xv_In1(n);
                    arg = k * sqrt( ((xv - xvp)^2) + ((yv - yvp)^2) );
                    design.Gv_In1(n, jj, bb) = design.CEMJN_dxS_dyS(bb) * besselh(0, 2, arg);

                    xv = params.lens.xv_Out(n);
                    arg = k * sqrt( ((xv - xvp)^2) + ((yv - yvp)^2) );
                    design.Gv_Out(n, jj, bb) = design.CEMJN_dxS_dyS(bb) * besselh(0, 2, arg);

                    % xv = xv_Out2(n);
                    % arg = k * sqrt( ((xv - xvp)^2) + ((yv - yvp)^2) );
                    % design.Gv_Out2(n, jj, bb) = design.CEMJN_dxS_dyS(bb) * besselh(0, 2, arg);


                    if bb == params.Config.bb0

                        xv = params.lens.xv_Out(n);
                        arg = sqrt( ((xv - xvp)^2) + ((yv - yvp)^2) );
                        design.Gl_ai(jj, n) = (k/2i) * ((xvp - xv)/arg) * besselh(1, 2, k*arg) * params.lens.dyS;

                        xv = params.lens.xv_In1(n);
                        arg = sqrt( ((xv - xvp)^2) + ((yv - yvp)^2) );
                        design.Gao_l(n, jj) = design.CEMJN_dxS_dyS(bb) * besselh(0, 2, k * arg);

                    end

                end

            end

        end

    end

elseif params.lens.shape == "Cylindrical"

    ii = 0;
    for n = 1:params.lens.NSphi
    
        phiv = params.lens.phiS_values(n);
    
        for m = 1:params.lens.NSr
    
            rv = params.lens.rS_values(m);
    
            yv = rv * sind(phiv);
    
            xv = rv * cosd(phiv);
    
            ii = ii + 1;
    
            for bb = 1:params.Config.nF
        
                k = 2* pi * params.freq_range(bb) / (3e8);
    
                for gg = 1:params.Config.nG
    
                    %%%%%%%%%%%%%%
                    % Populate Ei Forward
                    %%%%%%%%%%%%%%
    
                    design.EiF(ii, gg, bb) = IncidentEpatchArray( xv, yv, params.array.xj, params.array.yj, params.Config.phi_s(gg), params.array.phi_i, k, params.array.Ne, ...
                        params.array.de, design.CEMMN(bb), params.array.patch_er, params.array.patch_h, params.array.patch_a, params.array.patch_b  );
    
                   
                    %% Calculate the Radiation Matrix
    
                    phi_p = phiv .* pi / 180;
    
                    for pp = 1:params.Config.nP
    
                        phi = params.Config.Phi(params.Config.range{gg}(pp));
    
                        design.R(pp, ii, gg, bb) = design.CJMJF_drS_dphiS(bb) * rv * exp(1i * k * rv * cos(phi - phi_p));
    
                    end
                
                end
    
                roup = sqrt((yv^2) + (xv^2));
    
                phip = atan2(yv, xv);
    
                design.Gff(:, ii, bb) = design.CEMJF_drS_dphiS(bb) * rv * exp( 1i * k * roup .* cos(params.Config.Phi - phip) );
    
                %%%%%%%%%%%%%%%
                % Populate Gvv
                %%%%%%%%%%%%%%%
                % Source Point: Dielectric
                jj = 0;
                for nn = 1:params.lens.NSphi
    
                    phivp = params.lens.phiS_values(nn);
    
                    for mm = 1:params.lens.NSr
    
                        rvp = params.lens.rS_values(mm);
    
                        yvp = rvp * sind(phivp);
    
                        xvp = rvp * cosd(phivp);
    
                        k_r0_d = k * sqrt( params.lens.drS * params.lens.dphiS * rvp / pi);
    
                        jj = jj + 1;
    
                        arg = k * sqrt( ((xv - xvp)^2) + ((yv - yvp)^2) );
    
                        if arg >  k_r0_d
    
                            design.Gvv(ii, jj, bb) = design.CEMJN_drS_dphiS(bb) * rvp * besselh(0, 2, arg);
    
                        else
    
                            design.Gvv(ii, jj, bb) = design.CEMJN_drS_dphiS(bb) * rvp * (1 - (2i/pi)*(log(k_r0_d / 2) + 0.57721566 + 0.5));
    
                        end
    
                    end
    
                end
    
            end
    
        end
    
    end

end



%%%%%%%%%%%%%%%%%%%%%%%%
% Populate FarFields
%%%%%%%%%%%%%%%%%%%%%%%%
for bb = 1:params.Config.nF
    
    k = design.k_vec(bb);

    for gg = 1:params.Config.nG  
    
        for qq = 1:params.array.Ne
    
            roup = sqrt((params.array.yj(qq)^2) + (params.array.xj(qq)^2));
    
            phip = atan2(params.array.yj(qq), params.array.xj(qq));
    
            My = 2 * Exx_Calc(params.array.xj(qq), params.array.yj(qq), params.freq_range(bb), params.array.patch_er, ...
                params.array.patch_h, params.array.patch_a, params.array.patch_b, params.Config.phi_s(gg), params.array.phi_i);
    
            design.EffFi(:, gg, bb) = design.EffFi(:, gg, bb) + params.array.de * design.CEMMF(bb) * My .*  exp( 1i * k * roup .* cos(params.Config.Phi - phip) ) .* cosd(0);
    
    
        end
    
        U = ( abs(design.EffFi(:, gg, bb)) .^2 );
        Uave = sum( U .* params.Config.dphi ) / (2*pi);
        design.Dir_inc(:, gg, bb) = U./Uave;

    end

end


if params.solver.useGPU
    design.EiF = gpuArray(complex(design.EiF));
    design.Gvv = gpuArray(complex(design.Gvv));
    if params.lens.shape == "flat"
        design.Gl_ai = gpuArray(complex(design.Gl_ai));
        design.Gao_l = gpuArray(complex(design.Gao_l));
        design.Gao_ai = gpuArray(complex(design.Gao_ai));
    end
end

disp(['Finished Populating Matrices.',' Elapsed time = ', num2str(toc(timerVal_G), '%.1f'),' s']);


end