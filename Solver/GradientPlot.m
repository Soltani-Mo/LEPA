function params = GradientPlot(design, params)

if params.solver.iter == 1 
    params.solver.figD = figure('Units', 'centimeters', 'Position', [1, 1, 20, 10]); 
end 
figure(params.solver.figD);
set(params.solver.figD, 'Color', 'w');
clf(params.solver.figD); 
if params.lens.shape == "Flat" 
    [h_grid, t_grid] = meshgrid((params.lens.xS_values - params.geometry.Fo) ./ params.lambda0, (params.lens.yS_values(1,1:(params.lens.NSY/2))) ./ params.lambda0); % Display Grid 
    xLabelText = 'x/\lambda_0';
    yLabelText = 'y/\lambda_0';
elseif params.lens.shape == "Cylindrical" 
    [h_grid, t_grid] = meshgrid( (params.lens.rS_values - params.geometry.Fo) ./ params.lambda0, params.lens.phiS_values(1:params.lens.NSphi/2) ); % Display Grid 
    xLabelText = 'r/\lambda_0';
    yLabelText = '\phi (deg.)';
end 
nrow = 1; ncol = 4; 
subplot(nrow, ncol, 1); 
s = surf(h_grid, t_grid, abs(design.JF_grid)); 
colormap turbo 
colorbar 
s.EdgeColor = 'none'; 
view(0, 90) 
title([sprintf('%s\n', params.Config.function), sprintf('%s lens\n', params.lens.shape), '\bf |JF|']); 
axis tight
xlabel(xLabelText);
ylabel(yLabelText);

subplot(nrow, ncol, 2); 
s = surf(h_grid, t_grid, design.p_grid); 
colormap turbo 
colorbar 
s.EdgeColor = 'none'; 
view(0,90) 
title([sprintf('f = %1.1f GHz\n', design.omega_vec(1, design.new_bb)/(2*pi*params.units.GHz)), ... 
    sprintf('phi_s: %1.1f \n', params.Config.phi_s(design.new_gg)), ... 
    sprintf('Iteration = %d \n', params.solver.iter), '\bf p']); 
axis tight
xlabel(xLabelText);
ylabel(yLabelText);

subplot(nrow, ncol, 3); 
s = surf(h_grid, t_grid, design.dp_grid); 
colormap turbo 
colorbar 
s.EdgeColor = 'none'; 
view(0, 90) 
title(['stepSize', sprintf('= %1.2e \n', params.solver.stepSize), '\bf dp']); 
axis tight 
xlabel(xLabelText);
ylabel(yLabelText);

subplot(nrow, ncol, 4); 
s = surf(h_grid, t_grid, real(design.er_grid)); 
colormap turbo 
colorbar 
s.EdgeColor = 'none'; 
view(0, 90) 
title([sprintf('p0 = %1.1f \n', params.lens.p0) , '\bf \epsilon_r']); 
axis tight 
clim([params.material.epsMin real(params.material.epsMax)]); 
xlabel(xLabelText);
ylabel(yLabelText);
if params.analyzer.Gradient_Iter_Save_Flag 
    saveas(gcf, fullfile(params.folderPath, ... 
        sprintf('%s_Gradient_per_iter.jpg', params.mainFilename))); 
end 
if params.solver.iter == params.solver.maxIter 
    saveas(gcf, fullfile(params.folderPath, ... 
        sprintf('%s_Gradient_per_iter.jpg', params.mainFilename))); 
end

end