function  analyzeDesign(design, params)

if params.analyzer.Directivity_Display_Flag

    if params.Config.function == "Coherent_Expansion"

        plotDirectivityExpanding(design, params)

    elseif params.Config.function == "Angular_Compression"

        plotDirectivityCompressing(design, params)

    end
  
end


if params.lens.shape == "Flat"
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%   Calculate Plot Spectrum %%%%%%%%%%%%%%%%%%%%%%%%
    
    if params.analyzer.Display_Spectrum
    
        plotSpectrumFlatLens(design, params);

    end

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%   Plot Spatial Tansfer Matrix %%%%%%%%%%%%%%%%%%%%%%%%
    if params.analyzer.Spatial_Transfer_Matrix_Flag

        plotSpatialTransferMatrix(design, params);

    end

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot Permittivity on Grid %%%%%%%%%%%%%%%%%%%%%%%%%5

    if params.analyzer.Permittivity_Display_Flag
    
        plotPermittivityProfileFlatLens(design, params);
    
    end
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot Fields %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if params.analyzer.Field_Display_Flag
    
        plotFieldsFlatLens(design, params);
        
    end

    

elseif params.lens.shape == "Cylindrical"

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot Permittivity on Grid %%%%%%%%%%%%%%%%%%%%%%%%%5

    if params.analyzer.Permittivity_Display_Flag
    
        plotPermittivityProfileCylindricalLens(design, params);
    
    end

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot Fields %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if params.analyzer.Field_Display_Flag
    
        plotFieldsCylindricalLens(design, params);
        
    end

    

end


end
