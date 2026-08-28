function plotFieldsCylindricalLens(design, params)

tic
for bb = 1:params.Config.nF

    f = params.freq_range(bb);

    k = 2* pi * f / params.physics.c;

    for gg = 1:params.Config.nG


        [X_grid,Y_grid] = meshgrid(params.geometry.xP_values, params.geometry.yP_values); % Display Grid

        planeEzF_Inc = IncidentEpatchArray( X_grid, Y_grid, params.array.xj, params.array.yj, params.Config.phi_s(gg), params.array.phi_i, k, params.array.Ne, ...
            params.array.de, design.CEMMN(bb), params.array.patch_er, params.array.patch_h, params.array.patch_a, params.array.patch_b  );

        if gg == 1

            disp('     Initializing Plot Matrix');

            Gp_EzJ = zeros(params.geometry.NpY * params.geometry.NpX, params.lens.NS);


            ii = 0;
            for m = 1:params.geometry.NpX

                xv = params.geometry.xP_values(m);

                for n = 1:params.geometry.NpY

                    yv = params.geometry.yP_values(n);

                    ii = ii + 1;

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

                            arg = k * sqrt(((xv - xvp)^2) + ((yv - yvp)^2));

                            if arg > k_r0_d

                                Gp_EzJ(ii, jj) = design.CEMJN_drS_dphiS(bb) * rvp * besselh(0, 2, arg);

                            else

                                Gp_EzJ(ii, jj) = design.CEMJN_drS_dphiS(bb) * rvp * (1 - (2i/pi)*(log(k_r0_d / 2) + 0.57721566 + 0.5));

                            end
                        end
                    end


                end
            end

        end

        fprintf('     Please wait...Plotting Forward & Adjoint Fields on Plane...for phi_s = %1.1f, f = %1.1f GHz\n', params.Config.phi_s(gg), params.freq_range(bb)/params.units.GHz);

        planeEF_Sca = reshape( Gp_EzJ * design.JF(:, gg, bb), params.geometry.NpY, params.geometry.NpX);

        planeEF = planeEzF_Inc + planeEF_Sca;

        %% Plots

        figure('Units', 'centimeters', 'Position', [7, 7, params.analyzer.PlotWidth, 7.0]);

        ax1 = subplot('Position', [0.1, 0.3, 0.3, 0.52]);

        imagesc( params.geometry.yP_values ./ params.lambda0, params.geometry.xP_values ./ params.lambda0, (real(planeEF).')./30 );

        axis xy
        set(gca, 'FontSize', params.analyzer.FontSize);

        % Red -> White -> Blue colormap
        n = 256;

        n1 = floor(n/2);
        n2 = n - n1;

        % Red to white
        r1 = ones(n1,1);
        g1 = linspace(0,1,n1)';
        b1 = linspace(0,1,n1)';

        % White to blue
        r2 = linspace(1,0,n2)';
        g2 = linspace(1,0,n2)';
        b2 = ones(n2,1);

        % Combine
        cmap_re = [r1 g1 b1;
            r2 g2 b2];

        colormap(ax1, cmap_re);

        axis tight

        cb = colorbar;
        % Get current position
        pos = cb.Position;
        % Adjust the 'left' position to move it closer or further
        pos(1) = pos(1) + 0.06;
        cb.Position = pos;

        ax_pos = gca;
        cb_pos = cb.Position;

        % 3. Set the colorbar height (4th element) to match the plot's height (4th element)
        % and match its vertical position (2nd element)
        cb.Position = [cb_pos(1), ax_pos.Position(2), cb_pos(3), ax_pos.Position(4)];

        clim([-1 1])


        xlen = diff(xlim(ax1));
        ylen = diff(ylim(ax1));
        text(xlen/2, 0.9*ylen, ['(\phi_s, \phi_t) = ', sprintf('(%1.1f°, %1.1f°)', params.Config.phi_s(gg), params.Config.phi_t(gg))], 'Color', [0 0 0], 'FontSize', params.analyzer.FontSize);

        xlabel('y / \lambda_0');
        ylabel('x / \lambda_0');
        title('\Re\{E_{z}(x,y)\} (V/m)', 'FontSize', params.analyzer.FontSize);
        % yticks([0.015 5 10 15 20]);
        % yticklabels({'0', '5', '10', '15', '20'});
        set(ax1, 'TickDir', 'in');

        set(ax1, 'XDir', 'reverse');

        tp1 = linspace(-params.lens.PhiMax+90, params.lens.PhiMax+90, 100);

        xp1 = params.geometry.Fo .* cosd(tp1);
        yp1 = params.geometry.Fo .* sind(tp1);

        xp2 = (params.geometry.Fo + params.lens.thickness) .* cosd(tp1);
        yp2 = (params.geometry.Fo + params.lens.thickness) .* sind(tp1);

        line(xp1 ./ params.lambda0, yp1 ./ params.lambda0, 'LineWidth', 1.3, 'Color', [0 0 0]);
        line(xp2 ./ params.lambda0, yp2 ./ params.lambda0, 'LineWidth', 1.3, 'Color', [0 0 0]);

        line([xp1(1) ./ params.lambda0 xp2(1) ./ params.lambda0], [yp1(1) ./ params.lambda0 yp2(1) ./ params.lambda0], 'LineWidth', 1.3, 'Color', [0 0 0]);
        line([xp1(end) ./ params.lambda0 xp2(end) ./ params.lambda0], [yp1(end) ./ params.lambda0 yp2(end) ./ params.lambda0], 'LineWidth', 1.3, 'Color', [0 0 0]);


        ax2 = subplot('Position', [0.54, 0.3, 0.3, 0.52]);

        imagesc(params.geometry.yP_values ./ params.lambda0, params.geometry.xP_values ./ params.lambda0, (20.*log10(abs(planeEF)./max(max(abs(planeEF))))).');

        axis xy
        set(gca, 'FontSize', params.analyzer.FontSize);
        clim([-20 0]);

        colormap(ax2,"turbo");

        axis tight

        cb = colorbar;
        % Get current position
        pos = cb.Position;
        % Adjust the 'left' position to move it closer or further
        pos(1) = pos(1) + 0.06;
        cb.Position = pos;

        ax_pos = gca;
        cb_pos = cb.Position;

        % 3. Set the colorbar height (4th element) to match the plot's height (4th element)
        % and match its vertical position (2nd element)
        cb.Position = [cb_pos(1), ax_pos.Position(2), cb_pos(3), ax_pos.Position(4)];


        title('|E_{z}(x,y)|² (dB)', 'FontSize', params.analyzer.FontSize);
        set(gca, 'XDir', 'reverse');


        xp1 = params.geometry.Fo .* cosd(tp1);
        yp1 = params.geometry.Fo .* sind(tp1);

        xp2 = (params.geometry.Fo + params.lens.thickness) .* cosd(tp1);
        yp2 = (params.geometry.Fo + params.lens.thickness) .* sind(tp1);


        line(xp1 ./ params.lambda0, yp1 ./ params.lambda0, 'LineWidth', 1.3, 'Color', [1 1 1]);
        line(xp2 ./ params.lambda0, yp2 ./ params.lambda0, 'LineWidth', 1.3, 'Color', [1 1 1]);


        line([xp1(1) ./ params.lambda0 xp2(1) ./ params.lambda0], [yp1(1) ./ params.lambda0 yp2(1) ./ params.lambda0], 'LineWidth', 1.3, 'Color', [1 1 1]);
        line([xp1(end) ./ params.lambda0 xp2(end) ./ params.lambda0], [yp1(end) ./ params.lambda0 yp2(end) ./ params.lambda0], 'LineWidth', 1.3, 'Color', [1 1 1]);


        set(ax2, ...
            'Color', 'none', ...
            'XColor', 'w', ...
            'YColor', 'w', ...
            'ZColor', 'w', ...
            'GridColor', 'w', ...
            'GridAlpha', 1);

        % 2. Override the label colors back to black
        xlabel('y / \lambda_0', 'Color', 'k');
        ylabel('x / \lambda_0', 'Color', 'k');

        % 3. Override the tick mark text labels back to black

        ax2.XAxis.TickLabelColor = [0 0 0]; % Black tick labels (numbers)
        ax2.YAxis.TickLabelColor = [0 0 0]; % Black tick labels (numbers




        %% Export for publication

        set(gcf,'Renderer','painters');
        exportgraphics(gcf,fullfile(params.folderPath, ...
            sprintf('%s_Fields_f_%d_phi_s_%1.1f.pdf', params.mainFilename, params.freq_range(bb)/params.units.GHz, params.Config.phi_s(gg))),...
            'ContentType','vector', ...
            'BackgroundColor','white');

        saveas(gcf, fullfile(params.folderPath, ...
            sprintf('%s_Fields_f_%d_phi_s_%1.1f.fig', params.mainFilename, params.freq_range(bb)/params.units.GHz, params.Config.phi_s(gg))));


        filename = sprintf('%s_planeEF_f_%d_phi_s_%1.1f.mat', params.mainFilename, params.freq_range(bb)/params.units.GHz, params.Config.phi_s(gg));
        save(fullfile(params.folderPath, filename), 'planeEF', '-v7.3');

        filename = sprintf('%s_X_grid.mat', params.mainFilename);
        save(fullfile(params.folderPath, filename), 'X_grid', '-v7.3');

        filename = sprintf('%s_Y_grid.mat', params.mainFilename);
        save(fullfile(params.folderPath, filename), 'Y_grid', '-v7.3');



    end

end
disp(['     Finished Plotting', ' Elapsed time = ', num2str(toc, '%.2f'), ' s']);

end
