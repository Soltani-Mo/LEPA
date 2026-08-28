function [design, params] = Solver(design, params)


    %% Initialize vectors and matrices
    
    design.cost_mat = zeros(params.solver.maxIter, params.Config.nG, params.Config.nF);
    design.Total_cost_mat = zeros(params.solver.maxIter, 1);
    design.ggbb_recorder = zeros(params.solver.maxIter, 2);
    design.dp_norm_recorder = zeros(params.solver.maxIter, 1);
    
    %% Initialize eps_r_vec
    
    design.eps_r_vec = zeros(1, params.lens.NS);  
    design.p = zeros(params.lens.NS/2, 1) + params.lens.p0;
           
    
    %% Start Iterating
    for  iter = 1:params.solver.maxIter

        params.solver.iter = iter;
        disp(['Iteration: ',num2str(params.solver.iter)]);
    
    
        %% Form eps_r_vec
    
        if iter >= params.solver.BinarizationIter
            params.lens.beta1 = 1000;
            params.lens.beta2 = -params.lens.beta1/2;
            params.lens.beta3 = -params.lens.beta2 * ((params.lens.NBase_P-1)/2);
        end
    
    
        [design.eps_r_vec] = MappingFunction(design.p, params.lens.NSh, params.lens.NSt, params.lens.NBase_P, params.lens.bt, ...
            params.lens.nLayers, ...
            params.lens.beta1, params.lens.beta2, params.lens.beta3, params.material.epsMax, params.material.epsMin);
    
    
        %% Call the Solver
    
        [design, params] = ForwardBackwardSolver(design, params);
        
        design.cost_mat(iter, :, :) = design.cost;
        design.Total_cost_mat(iter, 1) = design.cost(design.new_gg, design.new_bb);
    
        %% Calculate Gradient and Initialize some matrices
    
        design.ggbb_recorder(iter, 1) = design.new_gg;
        design.ggbb_recorder(iter, 2) = design.new_bb;
    
        design.dp = zeros(params.lens.NS/2, 1);
        design.dp_grid = zeros(params.lens.NSt/2, params.lens.NSh);
        design.p_grid = zeros(params.lens.NSt/2, params.lens.NSh);
        design.er_grid = zeros(params.lens.NSt/2, params.lens.NSh);
        design.JF_grid = reshape(design.JF(1:params.lens.NS/2, design.new_gg, design.new_bb), [params.lens.NSh, (params.lens.NSt/2)]).';
        
        
        JF_half = design.JF(1:params.lens.NS/2, design.new_gg, design.new_bb);
        JA_half = design.JA(1:params.lens.NS/2, :, design.new_gg, design.new_bb);
        Delta_U_hat = design.Sgncost(:, design.new_gg, design.new_bb).';
        C0 = (-1 / (1i * design.omega_vec(1, design.new_bb) * params.physics.ep0));
        for n = 1:params.lens.bt:params.lens.NSt/2
        
            for m = 1:params.lens.NBase_P:params.lens.NSh
        
                % --------------------------------------------------
                % 1) Compute block-averaged mean_p  (IDENTICAL to first code)
                % --------------------------------------------------
                mean_p_vec = zeros(1, params.lens.bt);
        
                for q = 1:params.lens.bt
        
                    s1 = m + (n - 1 + q - 1) * params.lens.nLayers * params.lens.NBase_P;
                    s2 = m - 1 + params.lens.NBase_P + (n - 1 + q - 1) * params.lens.nLayers * params.lens.NBase_P;
        
                    mean_p_vec(q) = mean(design.p(s1:s2));
        
                end
        
                mean_p = mean(mean_p_vec);
        
                % --------------------------------------------------
                % 2) Compute er_local exactly as first code
                % --------------------------------------------------
                % x_vec = (0:params.NBase_P-1);
                % 
                % er_local = tanh(params.beta1 * mean_p ...
                %                 + params.beta2 * x_vec ...
                %                 + params.beta3) ...
                %                 * params.half_diff_er2_er1 ...
                %                 + params.mean_er2_er1;
        
                % --------------------------------------------------
                % 3) Assign values to entire block
                % --------------------------------------------------
                for q = 1:params.lens.bt
                    for k = 0:params.lens.NBase_P-1
        
                        ii = (n+q-2)*params.lens.NSh + (m+k);
        
                        % store permittivity
                        design.er_grid(n+q-1, m+k) = design.eps_r_vec(ii);
    
                        arg = params.lens.beta1 * mean_p ...
                                        + params.lens.beta2 * k ...
                                        + params.lens.beta3;
        
                        % compute dL using SAME tanh argument
                        dL =  C0 ...
                            .* (1 ./ ((design.eps_r_vec(ii) - 1).^2)) ...
                            .* (params.lens.beta1 * design.half_diff_er2_er1) ...
                            .* (1 - tanh(arg).^2);
    
    
                        dEff = JA_half(ii, :).' .* (dL .* JF_half(ii));   % nP x NS/2
                        
                        dU = real( conj(design.Eff(:, design.new_gg, design.new_bb)) .* dEff);  % nP x NS/2
                        
                        
                        design.dp(ii) = (-1/params.physics.eta0) * Delta_U_hat * dU;
    
                        design.dp_grid(n+q-1, m+k) = design.dp(ii);
                                    
                        design.p_grid(n+q-1, m+k) = design.p(ii);
        
                    end
                end
        
            end
        end
    

        %% Upadte design parameters
    
        design.p = design.p - ( params.solver.stepSize .* design.dp );
    
        design.dp_norm_recorder(iter) = norm(design.dp);
           
    
        %%  Plot Gradient Fields
    
        if params.analyzer.Gradient_Display_Flag || params.analyzer.Gradient_Iter_Save_Flag
    
           params = GradientPlot(design, params);
    
        end
    
        if params.analyzer.Cost_per_Iter_Save_Flag
    
            params = CostPlot(design, params);  
    
        end    

    end % End of the iteration loop

    %% Save Data
    SaveData(design, params);

end


