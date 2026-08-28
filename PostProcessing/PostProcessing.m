function PostProcessing(design, params)

    params.postprocessing.box_x = 5 * params.units.mm;
    Num_Quantization_Levels = 2;
    params.postprocessing.Quantization_Levels_Vec = linspace(params.material.epsMin, real(params.material.epsMax), Num_Quantization_Levels);
    
    if params.lens.shape == "Flat"
        HFSSautomationFlatLens(design, params);
    elseif params.lens.shape == "Cylindrical"
        HFSSautomationCylindricalLens(design, params);
    end

end