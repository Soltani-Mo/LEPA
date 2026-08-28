function params = CostPlot(design, params)          

if params.solver.iter == 1
    params.solver.figC = figure( ...
        'Units', 'centimeters', ...
        'Position', [1, 13, 40, 12], ...
        'Color', 'w');
end

figure(params.solver.figC);
clf(params.solver.figC);

%% ============================================================
%  General plotting parameters
% =============================================================
LW      = 1.4;
FS      = 9;
FSlabel = 9;

it_mat = 1:params.solver.iter;

% Number of actual plots
nrow = 1;
ncol = 6;

% Create tiled layout
tl = tiledlayout(params.solver.figC, nrow, ncol, ...
    'TileSpacing', 'compact', ...
    'Padding', 'compact');

tl.Units = 'normalized';
tl.Position = [0.03 0.12 0.94 0.68];

%% ============================================================
% 1. Cost
% =============================================================
ax1 = nexttile;
hold(ax1, 'on');

for bb = 1:params.Config.nF
    for gg = 1:params.Config.nG
        plot(ax1, it_mat, design.cost_mat(it_mat, gg, bb), ...
            'LineWidth', LW);
    end
end

grid(ax1, 'on');
box(ax1, 'on');

xlabel(ax1, 'Iteration', 'FontSize', FSlabel);
ylabel(ax1, 'Cost', 'FontSize', FSlabel);
% title(ax1, '\bf Cost', 'FontSize', FStitle);

set(ax1, 'FontSize', FS);


%% ============================================================
% 2. Aperture efficiency
% =============================================================
ax2 = nexttile;
hold(ax2, 'on');

for bb = 1:params.Config.nF
    for gg = 1:params.Config.nG
        plot(ax2, it_mat, ...
            design.AprEffrecorder(it_mat, gg, bb), ...
            'LineWidth', LW);
    end
end

grid(ax2, 'on');
box(ax2, 'on');

xlabel(ax2, 'Iteration', 'FontSize', FSlabel);
ylabel(ax2, 'Aperture efficiency', 'FontSize', FSlabel);
% title(ax2, '\bf Aperture Efficiency', 'FontSize', FStitle);

set(ax2, 'FontSize', FS);


%% ============================================================
% 3. dp norm
% =============================================================
ax3 = nexttile;

plot(ax3, it_mat, design.dp_norm_recorder(it_mat), ...
    'LineWidth', LW);

grid(ax3, 'on');
box(ax3, 'on');

xlabel(ax3, 'Iteration', 'FontSize', FSlabel);
ylabel(ax3, '||dp||', 'FontSize', FSlabel);

% title(ax3, ...
%     sprintf('\\bf Macrocell_t = %d', ...
%     params.lens.macrocell_t / params.solver.dl), ...
%     'FontSize', FStitle);

set(ax3, 'FontSize', FS);


%% ============================================================
% 4. Total Cost
% =============================================================
ax4 = nexttile;

plot(ax4, it_mat, design.Total_cost_mat(it_mat, 1), ...
    'LineWidth', LW);

grid(ax4, 'on');
box(ax4, 'on');

xlabel(ax4, 'Iteration', 'FontSize', FSlabel);
ylabel(ax4, 'Total Cost', 'FontSize', FSlabel);
% title(ax4, '\bf Total Cost', 'FontSize', FStitle);

set(ax4, 'FontSize', FS);


%% ============================================================
% 5. Scan-angle count
% =============================================================
ax5 = nexttile;

counts = histcounts( ...
    params.Config.phi_s(design.ggbb_recorder(it_mat, 1)), ...
    params.Config.phi_range_span);

bar(ax5, params.Config.phi_s, counts, ...
    'BarWidth', 0.8);

% grid(ax5, 'on');
box(ax5, 'on');

xticks(ax5, params.Config.phi_s);
xticklabels(ax5, arrayfun(@(x) sprintf('%1.0f', x), ...
    params.Config.phi_s, 'UniformOutput', false));

xlabel(ax5, '\phi_s (deg)', 'FontSize', FSlabel);
ylabel(ax5, 'Scan Angle Count', 'FontSize', FSlabel);
% title(ax5, '\bf Scan Angle', 'FontSize', FStitle);

set(ax5, 'FontSize', FS);


%% ============================================================
% 6. Frequency count
% =============================================================
ax6 = nexttile;

counts = histcounts( ...
    params.freq_range(design.ggbb_recorder(it_mat, 2)), ...
    params.Config.freq_range_span);

bp = bar(ax6, params.freq_range/params.units.GHz, counts, ...
    'BarWidth', 0.8);

% grid(ax6, 'on');
box(ax6, 'on');
bp.FaceColor = ax6.ColorOrder(2,:);

xticks(ax6, params.freq_range/params.units.GHz);
xticklabels(ax6, arrayfun(@(x) sprintf('%g', x), ...
    params.freq_range/params.units.GHz, 'UniformOutput', false));

xlabel(ax6, 'f (GHz)', 'FontSize', FSlabel);
ylabel(ax6, 'Frequency Count', 'FontSize', FSlabel);
% title(ax6, '\bf Frequency', 'FontSize', FStitle);

set(ax6, 'FontSize', FS);


%% ============================================================
%  Global title / information
% =============================================================

sgtitle(tl, ...
    sprintf('%s  %s lens    |    Iteration = %d    |    stepSize = %.1e', ...
    params.Config.function, ...
    params.lens.shape, ...
    params.solver.iter, ...
    params.solver.stepSize), ...
    'FontSize', 11, ...
    'FontWeight', 'bold');


%% ============================================================
%  Additional lens information
% =============================================================

annotation(params.solver.figC, 'textbox', ...
    [0.37 0.91 0.26 0.055], ...
    'String', sprintf( ...
        'W_{in}: %.1f\\lambda_0    W_{out}: %.1f\\lambda_0  |  AR_{in}: %.1f^\\circ  AR_{out}: %.1f^\\circ   |  Macrocell_t = %d', ...
        params.array.Win/params.lambda0, ...
        params.lens.Wout/params.lambda0, ...
        0.886*(params.lambda0/params.array.Win)*(180/pi), ...
        0.886*(params.lambda0/params.lens.Wout)*(180/pi), ...
        params.lens.macrocell_t / params.solver.dl), ...  % <--- Move closing parenthesis here
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle', ...
    'EdgeColor', 'none', ...
    'FontSize', 9);


%% ============================================================
%  Legend
% =============================================================

% Create legend using the first two axes.
% ax2 contains the actual curves corresponding to LegendTitles.
lgd = legend(ax2, params.analyzer.LegendTitles, ...
    'Location', 'none', ...
    'NumColumns', 3, ...
    'FontSize', 8.5, ...
    'Box', 'off');

% Position legend inside the figure, above the plots
lgd.Position = [0.67 0.97 0.32 0.11];


%% ============================================================
%  Save
% =============================================================

saveas(gcf, fullfile(params.folderPath, ...
                    sprintf('%s_Cost_per_iter.jpg', params.mainFilename)));

% exportgraphics(params.solver.figC, ...
%     fullfile(params.folderPath, ...
%     sprintf('%s_Cost_per_iter.jpg', params.mainFilename)), ...
%     'Resolution', 300);
    
end