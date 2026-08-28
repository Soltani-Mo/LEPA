function params = setupGeometry(params)


switch params.lens.shape

    case "Flat"

        params = setupFlatLens(params);

    case "Cylindrical"

        params = setupCylindricalLens(params);

    otherwise
        error("Unknown geometry.");

end


params.array.Ne = round( params.array.Win / params.array.de ) + 1;
params.array.xj = zeros(1, params.array.Ne);           % Phased Array Location (Circular)
params.array.yj = linspace( (-params.array.Win)/2, (params.array.Win)/2, params.array.Ne);

params.array.patch_a = params.lambda0/2;
params.array.patch_b = params.array.de;
params.array.patch_er = 2.2;
params.array.patch_h = 0.508 * params.units.mm;
params.array.phi_i = 90;

Y_vec_max = max(3 * (params.geometry.Fo + params.lens.thickness) * tand(max(abs(params.Config.phi_s))), 2* params.lens.width);
params.geometry.NYvec = ceil( Y_vec_max / params.solver.dl );
params.geometry.Y_vec = linspace(-Y_vec_max/2, Y_vec_max/2, params.geometry.NYvec);


params.lens.xv_Out = ( params.geometry.Fo + params.lens.thickness + 0.05 * params.lambda0 ) .* ones(size(params.geometry.Y_vec)); % xv at the Input side of the problem
params.lens.xv_In1 =  ( params.geometry.Fo - 0.05 * params.lambda0 ) .* ones(size(params.geometry.Y_vec)); % xv at the Output side of the problem
params.lens.xv_In2 =  ( 1 *  params.geometry.Fo / 3 ) .* ones(size(params.geometry.Y_vec)); % xv at the Output side of the problem


params.geometry.nA = ceil(params.lens.Wout / params.array.de) + 1;  % Magnified Linear Phasing
params.geometry.xsA = params.lens.thickness + params.geometry.Fo;
params.geometry.ysA = linspace( (-params.lens.Wout)/2, (params.lens.Wout)/2, params.geometry.nA);

params.geometry.xF = ( params.geometry.Fo + params.lens.thickness +  0.05 * params.lambda0 ) .* ones(size(params.geometry.Y_vec));
params.geometry.yF = params.geometry.Y_vec;

Disp_X1 = -params.lambda0/5;
Disp_X2 = params.geometry.Fo + 5 * params.units.cm;
Disp_X = Disp_X1 + Disp_X2 + params.lens.thickness;
params.geometry.NpX = ceil(Disp_X/params.geometry.dlp);
Disp_Y = params.lens.width + 6 * params.units.cm;
params.geometry.NpY = ceil(Disp_Y/params.geometry.dlp);
dxP = (Disp_X1 + Disp_X2 + params.lens.thickness) / params.geometry.NpX;
% dyP = params.Disp_Y / params.NpY;
params.geometry.xP_values = -Disp_X1 + (0:(params.geometry.NpX - 1)) .* dxP;
params.geometry.yP_values = linspace(-Disp_Y/2, Disp_Y/2, params.geometry.NpY);


end