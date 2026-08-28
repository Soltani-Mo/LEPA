function plotSpectrumFlatLens(design, params)

normalized_ky_Span = 4;
nky = 1000;

for bb = 1:params.Config.nF

    f = params.freq_range(bb);

    k = 2* pi * f / params.physics.c;

    for gg = 1:params.Config.nG

        ky_vec = linspace(-normalized_ky_Span * k/ 2, normalized_ky_Span * k /2, nky);
        
        Exp_mat = zeros(params.geometry.NYvec, nky);
        for kk = 1:nky
        
            Exp_mat(:, kk) = exp( 1i * ky_vec(kk) .* params.geometry.Y_vec );
        
        end
        
        lineF_In = IncidentEpatchArray( params.lens.xv_In1, params.geometry.Y_vec, params.array.xj, params.array.yj, params.Config.phi_s(gg), params.array.phi_i, k, params.array.Ne,...
            params.array.de, design.CEMMN(bb), params.array.patch_er, params.array.patch_h, params.array.patch_a, params.array.patch_b  );
        
        lineF_Out = IncidentEpatchArray( params.lens.xv_Out, params.geometry.Y_vec, params.array.xj, params.array.yj, params.Config.phi_s(gg), params.array.phi_i, k, params.array.Ne,...
            params.array.de, design.CEMMN(bb), params.array.patch_er, params.array.patch_h, params.array.patch_a, params.array.patch_b  );
        
        
        lineF_In = lineF_In + (design.Gv_In1(:, :, bb) * design.JF(:, gg, bb)).';
        lineF_Out = lineF_Out + (design.Gv_Out(:, :, bb) * design.JF(:, gg, bb)).';
        
        lineF_In_ky = lineF_In * Exp_mat;
        lineF_Out_ky = lineF_Out * Exp_mat;
        
        
        if gg == 1
        
            figure('Units', 'centimeters', 'Position', [7, 5, params.analyzer.PlotWidth, 6]);
        
        end
        
        subplot(1, params.Config.nG, params.Config.nG + 1 - gg);
        Max_E_tilde = max(abs(lineF_In_ky));
        plot(ky_vec ./ k, abs(lineF_In_ky) ./ Max_E_tilde, 'Color', [0, 0.4470, 0.7410], 'LineWidth', 1.5);
        grid on
        hold on
        xlabel('k_y / k_0');
        axis tight
        ax = gca;
        ax.XTick = -normalized_ky_Span/2 : 1 : normalized_ky_Span * k/ 2;
        yticks(0:0.5:1);
        plot(ky_vec ./ k, abs(lineF_Out_ky) ./ Max_E_tilde, 'Color', [0.8500, 0.3250, 0.0980], 'LineWidth', 1.5);
        
        % patch('Position', [-2, 0, 1, 1], 'FaceColor', [0.5, 0.5, 0.5], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
        % patch('Position', [ 1, 0, 1, 1], 'FaceColor', [0.5, 0.5, 0.5], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
        % Defined from [x, y, width, height]
xr = [-2, -1, -1, -2];
yr = [ 0,  0,  1,  1];

patch('XData', xr, 'YData', yr, 'FaceColor', [0.5, 0.5, 0.5], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
% X and Y coordinates for [x=1, y=0, width=1, height=1]
xr2 = [1, 2, 2, 1];
yr2 = [0, 0, 1, 1];

patch('XData', xr2, 'YData', yr2, 'FaceColor', [0.5, 0.5, 0.5], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
ylim([0 1]);

        title(sprintf('phi_s = %1.1f°', params.Config.phi_s(gg)));
        lgd= legend('x = F_o + T + \lambda_0/20', 'x = F_o - \lambda_0/20', 'Location', 'northeast', 'FontSize', 10);
        set(lgd.BoxFace, 'ColorType', 'truecoloralpha', 'ColorData', uint8([255; 255; 255; 0.3*255]));
        set(gca, 'Fontsize', params.analyzer.FontSize);

    end

end

%%
% Export for publication

set(gcf,'Renderer','painters');
exportgraphics(gcf,fullfile(params.folderPath, ...
    sprintf('%s_Spectrum_f_%d.pdf', params.mainFilename, params.freq_range(bb)/1e9)),...
    'ContentType','vector', ...
    'BackgroundColor','white');


saveas(gcf, fullfile(params.folderPath, ...
            sprintf('%s_Spectrum_f_%d_phi_s_%1.1f.fig', params.mainFilename, params.freq_range(bb)/1e9, params.Config.phi_s(gg))));


saveas(gcf, fullfile(params.folderPath, ...
    sprintf('%s_Spectrum_f_%d_phi_s_%1.1f.fig', params.mainFilename, params.freq_range(bb)/1e9, params.Config.phi_s(gg))));




end