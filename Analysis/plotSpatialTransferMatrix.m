function plotSpatialTransferMatrix(design, params)

L = design.X - design.Gvv(:, :, params.Config.bb0);

T_scatt = design.Gao_l * (L \ design.Gl_ai);

T0 = design.Gao_ai;

T = T0 + T_scatt;

T0_max = max(max(abs(T0)));
T_max = max(max(abs(T)));


T0 = T0 ./ T0_max;
T = T ./ T_max;

%% =========================================================================
% Spatial transfer matrices + IPR distribution
% =========================================================================

figS = figure('Units', 'centimeters', ...
    'Position', [7, 7, params.analyzer.PlotWidth, 10]);

% Common subplot dimensions
% subplot_w = 0.29;
% subplot_h = 0.48;
% subplot_y = 0.25;

% ========================================================================
% (a) Bare array: |T0|
% =========================================================================

% ax21 = subplot(1,3,1, 'Position', [0.025, subplot_y, subplot_w, subplot_h]);
ax21 = subplot(1,3,1);

imagesc(params.geometry.Y_vec ./ params.lambda0, ...
    params.geometry.Y_vec ./ params.lambda0, ...
    abs(T0).');

hold on

axis equal
axis xy
axis tight

xlim([-params.lens.width/(2*params.lambda0), ...
    params.lens.width/(2*params.lambda0)]);
ylim([-params.lens.width/(2*params.lambda0), ...
    params.lens.width/(2*params.lambda0)]);

clim([0 1]);

title('Normalized |t_0|');

% text(-30, 26, '$\overline{W}_{\mathbf{eff}} = 10.2 \lambda_0$', ...
%     'FontSize', 16, ...
%     'Color', [1 1 1], ...
%     'Interpreter', 'latex');
% 
% text(-30, 17, '$W_{\mathbf{eff}}^{\mathbf{max}} = 10.5 \lambda_0$', ...
%     'FontSize', 16, ...
%     'Color', [1 1 1], ...
%     'Interpreter', 'latex');

set(ax21, 'FontSize', params.analyzer.FontSize);

set(ax21, ...
    'Color', 'none', ...
    'XColor', 'w', ...
    'YColor', 'w', ...
    'ZColor', 'w', ...
    'GridColor', 'w', ...
    'GridAlpha', 1);

xlabel({'y^{\prime} / \lambda_0', 'Input channel'}, 'Color', 'k');
ylabel({'Output channel', 'y / \lambda_0'}, 'Color', 'k');

ax21.YAxis.Label.Units = 'normalized';
ax21.YAxis.Label.Position(1) = -0.12;

ax21.XAxis.TickLabelColor = [0 0 0];
ax21.YAxis.TickLabelColor = [0 0 0];

% Colorbar
cb1 = colorbar(ax21);
cb1.Ticks = [0, 0.5, 1];

drawnow;

% axPos1 = ax21.Position;
% 
% cb1.Position = [axPos1(1) + axPos1(3) - 0.005, ...
%     axPos1(2), ...
%     cb1.Position(3), ...
%     axPos1(4)];

hold off


% ========================================================================
% (b) Metalens: |T|
% =========================================================================

% ax22 = subplot(1,3,2, 'Position', [0.323, subplot_y, subplot_w, subplot_h]);
ax22 = subplot(1,3,2);

imagesc(params.geometry.Y_vec ./ params.lambda0, ...
    params.geometry.Y_vec ./ params.lambda0, ...
    abs(T).');

hold on

axis equal
axis xy
axis tight

xlim([-params.lens.width/(2*params.lambda0), ...
    params.lens.width/(2*params.lambda0)]);
ylim([-params.lens.width/(2*params.lambda0), ...
    params.lens.width/(2*params.lambda0)]);

clim([0 1]);

title('Normalized |t|');

% text(-30, 26, '$\overline{W}_{\mathbf{eff}} = 9.5 \lambda_0$', ...
%     'FontSize', 16, ...
%     'Color', [1 1 1], ...
%     'Interpreter', 'latex');
% 
% text(-30, 17, '$W_{\mathbf{eff}}^{\mathbf{max}} = 14.0 \lambda_0$', ...
%     'FontSize', 16, ...
%     'Color', [1 1 1], ...
%     'Interpreter', 'latex');

set(ax22, 'FontSize', params.analyzer.FontSize);

set(ax22, ...
    'Color', 'none', ...
    'XColor', 'w', ...
    'YColor', 'w', ...
    'ZColor', 'w', ...
    'GridColor', 'w', ...
    'GridAlpha', 1);

xlabel({'y^{\prime} / \lambda_0', 'Input channel'}, 'Color', 'k');
ylabel({'Output channel', 'y / \lambda_0'}, 'Color', 'k');

ax22.YAxis.Label.Units = 'normalized';
ax22.YAxis.Label.Position(1) = -0.12;

ax22.XAxis.TickLabelColor = [0 0 0];
ax22.YAxis.TickLabelColor = [0 0 0];

% Colorbar
cb2 = colorbar(ax22);
cb2.Ticks = [0, 0.5, 1];

drawnow;

% axPos2 = ax22.Position;
% 
% cb2.Position = [axPos2(1) + axPos2(3) - 0.005, ...
%     axPos2(2), ...
%     cb2.Position(3), ...
%     axPos2(4)];

hold off


% ========================================================================
% IPR calculation
% =========================================================================

dy = mean(diff(params.geometry.Y_vec));

[W_ipr, W_avg, W_max, ~] = calcIPR(T, dy);

fprintf('Average IPR width (t) = %.2f lambda0\n', W_avg / params.lambda0);
fprintf('Maximum IPR width (t) = %.2f lambda0\n', W_max / params.lambda0);

[W_ipr0, W_avg0, W_max0, ~] = calcIPR(T0, dy);

fprintf('Average IPR width (t0) = %.2f lambda0\n', W_avg0 / params.lambda0);
fprintf('Maximum IPR width (t0) = %.2f lambda0\n', W_max0 / params.lambda0);

W_ipr0 = W_ipr0 / params.lambda0;
W_ipr  = W_ipr  / params.lambda0;


% ========================================================================
% (c) IPR distribution
% =========================================================================

% ax23 = subplot(1,3,3, 'Position', [0.675, subplot_y, subplot_w-0.10, subplot_h]);
ax23 = subplot(1,3,3);

edges = linspace( ...
    min([W_ipr(:); W_ipr0(:)]), ...
    max([W_ipr(:); W_ipr0(:)]), ...
    25);

histogram(W_ipr0, edges, ...
    'Normalization', 'probability', ...
    'FaceAlpha', 0.5, ...
    'LineWidth', 1.5);

hold on

histogram(W_ipr, edges, ...
    'Normalization', 'probability', ...
    'FaceAlpha', 0.5, ...
    'LineWidth', 1.5);

grid on
box on

legend('\bft_0', '\bft', 'Location', 'northeast');


xlabel({'W_{eff}/\lambda_0', 'Effective width'}, ...
    'FontSize', params.analyzer.FontSize);

ylabel('Number of input positions', ...
    'FontSize', params.analyzer.FontSize);

set(ax23, 'FontSize', params.analyzer.FontSize);

hold off


%% ========================================================================
% Export for publication
% =========================================================================

figure(figS);

set(gcf, 'Renderer', 'painters');

exportgraphics(gcf, ...
    fullfile(params.folderPath, ...
    sprintf('%s_SpatialTransferMatrix.pdf', params.mainFilename)), ...
    'ContentType', 'vector', ...
    'BackgroundColor', 'white');

saveas(gcf, fullfile(params.folderPath, ...
                sprintf('%s_Spatial_Transfer_Matrix.fig', params.mainFilename)));


end