function params = setupCylindricalLens(params)

params.lens.bh = 1;
params.lens.bt = params.lens.macrocell_t / params.solver.dl;
params.lens.Base_P = params.lens.Base_d + params.lens.Base_h;
params.lens.NBase_P = params.lens.Base_P / params.solver.dl;

params.lens.beta2 = -params.lens.beta1/2;
params.lens.beta3 = -params.lens.beta2 * ((params.lens.NBase_P-1)/2);

params.lens.thickness = params.lens.nLayers * params.lens.Base_P;
Dielectric_Ro = params.geometry.Fo + params.lens.thickness;
params.lens.width = 2 * Dielectric_Ro;

dr0 = params.solver.dl;
NSr0 = round( params.lens.thickness / dr0 );

cr = mod(params.lens.bh - mod(NSr0, params.lens.bh), params.lens.bh); % Ensure divisible by bx
params.lens.NSr = NSr0 + cr;
params.lens.NSh = params.lens.NSr;
params.lens.drS = params.lens.thickness / (params.lens.NSr);
params.lens.rS_values = params.geometry.Fo + 0.5 * params.lens.drS : params.lens.drS : Dielectric_Ro - 0.5 * params.lens.drS;

dphi0 = params.solver.dl / Dielectric_Ro;
dphi0_deg = dphi0 * 180 /pi;
Teeth_n0 = round( 2 * params.lens.PhiMax / (params.lens.bt * dphi0_deg ) );
cNphi0 = mod(2 - mod(Teeth_n0, 2), 2);         % Ensure divisible by 2
Teeth_n = Teeth_n0 + cNphi0;

params.lens.NSphi = Teeth_n * params.lens.bt;
params.lens.NSt = params.lens.NSphi;
dphiS_deg = 2 * params.lens.PhiMax / params.lens.NSphi;
params.lens.dphiS = dphiS_deg * (pi / 180);

params.lens.phiS_values = -params.lens.PhiMax + 0.5 * dphiS_deg : ...
    dphiS_deg : ...
    params.lens.PhiMax - 0.5 * dphiS_deg;

params.lens.NS = params.lens.NSr * params.lens.NSphi;

params.lens.Teeth_n = params.lens.NSphi / params.lens.macrocell_t;
params.lens.nH = params.lens.nLayers * params.lens.Teeth_n;


end