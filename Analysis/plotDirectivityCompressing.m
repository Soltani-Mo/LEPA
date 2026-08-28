function plotDirectivityCompressing(design, params)

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

    for gg = 1:params.Config.nG

        if bb == 1 && gg == 1
            figure('Units', 'centimeters', 'Position', [7, 2, params.analyzer.PlotWidth, 8]);
        end

        Dir_Offset_dB = 3;

        Colo = turbo(params.Config.nG);

        plot(Phi_deg, Dir_mag_dB(:, gg, bb) + Dir_Offset_dB,'Color', Colo(gg, :), 'LineWidth', 1.5);
        hold on
        plot(Phi_deg, Dir_inc_dB(:, gg, bb) + Dir_Offset_dB, 'Color', Colo(gg, :), 'LineWidth', 1.5, 'LineStyle', '-.');
        hold on

        grid on
        xlim([-90 90]);
        ylim([-10 20]);
        % yticks( -10: 10 : 20 );
        xlabel('\phi (deg.)');
        ylabel('(dB)');
        title('Directivity', 'FontSize', params.analyzer.FontSize);
        set(gca, 'FontSize', params.analyzer.FontSize);

        [lgd, obj] = legend('PA + Metalens (MoM)', 'PA (Theory)', 'Location', 'southwest', 'FontSize', params.analyzer.FontSize);
        set(lgd.BoxFace, 'ColorType', 'truecoloralpha', 'ColorData', uint8([255; 255; 255; 0.7*255]));

        % Target and change only the legend line colors
        lgdLines = findobj(obj, 'Type', 'line');
        set(lgdLines, 'Color', [0 0 0]);


    end


    %% Export for publication
    set(gcf,'Renderer','painters');
    exportgraphics(gcf,fullfile(params.folderPath, ...
        sprintf('%s_Directivity_Same_Plot_f_%d.pdf', params.mainFilename, params.freq_range(bb)/params.units.GHz)),...
        'ContentType','vector', ...
        'BackgroundColor','white');
    
    saveas(gcf, fullfile(params.folderPath, ...
                sprintf('%s_Directivity_SamePlot_f_%d.fig', params.mainFilename, params.freq_range(bb)/params.units.GHz)));

end



end