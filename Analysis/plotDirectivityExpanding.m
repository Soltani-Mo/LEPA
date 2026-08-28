function plotDirectivityExpanding(design, params)

Dir_mag_dB = 10 .* log10(design.Dir_mag);
Dir_goal_dB = 10 .* log10(design.Dir_goal);
Dir_inc_dB = 10 .* log10(design.Dir_inc);
Phi_deg = params.Config.Phi .* 180/pi;

filename = sprintf('%s_Dir_inc_dB.mat', params.mainFilename);
save(fullfile(params.folderPath, filename), 'Dir_inc_dB', '-v7.3');

filename = sprintf('%s_Dir_mag_dB.mat', params.mainFilename);
save(fullfile(params.folderPath, filename), 'Dir_mag_dB', '-v7.3');

filename = sprintf('%s_Dir_goal_dB.mat', params.mainFilename);
save(fullfile(params.folderPath, filename), 'Dir_goal_dB', '-v7.3');

filename = sprintf('%s_Phi_deg.mat', params.mainFilename);
save(fullfile(params.folderPath, filename), 'Phi_deg', '-v7.3');


for bb = 1:params.Config.nF

    f = params.freq_range(bb);

    k = 2* pi * f / params.physics.c;

    for gg = 1:params.Config.nG

        if bb == 1 && gg == 1
            figure('Units', 'centimeters', 'Position', [7, 2, params.analyzer.PlotWidth, 8]);
        end

        subplot(1, params.Config.nG, params.Config.nG + 1 - gg);
        Dir_Offset_dB = 3;
        LineWidth = 1.5;

        % Color1 = [0, 0.4470, 0.7410];
        % Color2 = [0.8500, 0.3250, 0.0980];
        Color3 = [0.9290, 0.6940, 0.1250];
        Color4 = [0.4940, 0.1840, 0.5560];
        % Color5 = [0.4660, 0.6740, 0.1880];
        % Color6 = [0.3010, 0.7450, 0.9330];

        Color_mag_sim = Color3;
        % Color_mag_meas = Color5;
        % Color_inc_meas = Color1;
        Color_inc_sim = Color4;


        plot(Phi_deg, Dir_mag_dB(:, gg, bb) + Dir_Offset_dB,'Color', Color_mag_sim,'LineWidth', LineWidth, 'LineStyle', '-');
        hold on


        plot(Phi_deg, Dir_inc_dB(:, gg, bb) + Dir_Offset_dB, 'Color', Color_inc_sim, 'LineWidth', LineWidth);
        hold on

        ylabel('(dB)');
        xlabel('\phi (deg.)');
        title(['\phi_s = ', sprintf('%1.1f°', params.Config.phi_s(gg))]);
        grid on
        set(gca, 'FontSize', params.analyzer.FontSize);


        xlim([-90 90]);
        ylim([-10 20]);
        % yticks( -10: 10 : 20 );

        xticks([-90, -45, 0 , 45, 90]); % Ticks at specific points
        if bb == 1 && gg == params.Config.nG
            lgd = legend('PA + Metalens (MoM)', 'PA (Theory.)', 'Location', 'southwest', 'FontSize', 10);
            set(lgd.BoxFace, 'ColorType', 'truecoloralpha', 'ColorData', uint8([255; 255; 255; 0.55*255]));
        end

        

    end
end

%%
        % Export for publication
        set(gcf,'Renderer','painters');
        exportgraphics(gcf,fullfile(params.folderPath, ...
            sprintf('%s_Directivity.pdf', params.mainFilename)),...
            'ContentType','vector', ...
            'BackgroundColor','white');


        saveas(gcf, fullfile(params.folderPath, ...
            sprintf('%s_Directivity.fig', params.mainFilename)));


end