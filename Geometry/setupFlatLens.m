function params = setupFlatLens(params)
    
    Teeth_n0 = round(params.lens.width / params.lens.macrocell_t);
    cteeth = mod(2 - mod(Teeth_n0, 2), 2); % Ensure divisible by 2
    params.lens.Teeth_n = Teeth_n0 + cteeth;
    params.lens.width = params.lens.Teeth_n * params.lens.macrocell_t;
    
    params.lens.nH = params.lens.nLayers * params.lens.Teeth_n;
    params.lens.Base_P = params.lens.Base_d + params.lens.Base_h;
    params.lens.NBase_P = params.lens.Base_P / params.solver.dl;
    params.lens.thickness = params.lens.nLayers * params.lens.Base_P;

    params.lens.bh = round( (params.lens.Base_d + params.lens.Base_h)  / params.solver.dl);
    params.lens.bt = params.lens.macrocell_t / params.solver.dl;

    params.lens.beta2 = -params.lens.beta1/2;
    params.lens.beta3 = -params.lens.beta2 * ((params.lens.bh-1)/2);
    
    % Determine Simulation Parameters
    dxS0 = params.solver.dl;
    NSX0 = round( params.lens.thickness / dxS0 );
    
    % Adjust by adding correction cx, cy
    cx = mod(1 - mod(NSX0, 1), 1);
    params.lens.NSX = NSX0 + cx;
    params.lens.NSh = params.lens.NSX;
    
    params.lens.NSY = params.lens.bt * params.lens.Teeth_n;
    params.lens.NSt = params.lens.NSY;
    
    params.lens.dxS = params.lens.thickness / params.lens.NSX;
    params.lens.dyS = params.lens.width / params.lens.NSY;
    
    params.lens.NS = params.lens.NSX * params.lens.NSY;
    
    params.lens.xS_values = ( 0 : (params.lens.NSX-1) ) .* params.lens.dxS ...
        + params.lens.dxS/2 + params.geometry.Fo;
    params.lens.yS_values = -params.lens.width/2 ...
        + (0:(params.lens.NSY - 1)) .* params.lens.dyS + params.lens.dyS/2;   
        
  

end