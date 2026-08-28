function  plotPermittivityProfileCylindricalLens(design, params)

color1 = [11,31,59]./255;
color2 = [217,164,65]./255;
myMap = [color1; color2];

er_disp = reshape(real(design.eps_r_vec(1:params.lens.NS/2)), [params.lens.NSr, params.lens.NSphi/2]);

figure('Units', 'centimeters', ...
       'Position', [7, 5, params.analyzer.PlotWidth, 4.5]);

imagesc(params.lens.phiS_values(1:params.lens.NSphi/2), ...
        (params.lens.rS_values - params.geometry.Fo) ./ params.lambda0, ...
        er_disp);

colormap(myMap)
axis xy

xlabel('\phi (deg.)');
ylabel('r / \lambda_0');

title('\epsilon_r(r,\phi)', ...
      'FontSize', params.analyzer.FontSize);

set(gca, 'FontSize', params.analyzer.FontSize);

% Main axes
ax = gca;

% Get position of the main axes in normalized figure coordinates
ax.Units = 'normalized';
axPos = ax.Position;

% Create an invisible axes above the main plot
annAx = axes('Position', axPos, ...
             'Color', 'none', ...
             'XColor', 'none', ...
             'YColor', 'none', ...
             'XLim', [0 1], ...
             'YLim', [0 1], ...
             'Visible', 'off');

hold(annAx, 'on');

% Position of annotations
% x = 0 corresponds to the left side of the plot
% y > 1 places them above the plot, at the title level
y = 1.25;

% epsilon_r^max
rectangle(annAx, ...
          'Position', [0, y-0.15, 0.035, 0.2], ...
          'FaceColor', color2, ...
          'EdgeColor', 'none', ...
          'Clipping', 'off');

text(annAx, 0.045, y + 0.0275, '\epsilon_{r}^{max}', ...
     'FontSize', 14, ...
     'VerticalAlignment', 'middle', ...
     'Clipping', 'off');

% epsilon_r^min
rectangle(annAx, ...
          'Position', [0.16, y-0.15, 0.035, 0.2], ...
          'FaceColor', color1, ...
          'EdgeColor', 'none', ...
          'Clipping', 'off');

text(annAx, 0.205, y + 0.0275, '\epsilon_{r}^{min}', ...
     'FontSize', 14, ...
     'VerticalAlignment', 'middle', ...
     'Clipping', 'off');

% Make sure the annotation axes does not interfere with the main plot
uistack(ax, 'bottom');

hold on
[m, n] = size(er_disp);

% Major grid lines
for k = -n:1:n
    xline(k, 'w', 'LineWidth', 0.2, 'Alpha', 0.2)
end
for k = 0:1:m
    yline(k, 'w', 'LineWidth', 0.2, 'Alpha', 0.2)
end

%%

% Export for publication
set(gcf,'Renderer','painters');
exportgraphics(gcf,fullfile(params.folderPath, ...
    sprintf('%s_Permittivity_Profile.pdf', params.mainFilename)),...
    'ContentType','vector', ...
    'BackgroundColor','white');

end
