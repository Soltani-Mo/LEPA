%% ============================================================
%  MAIN
%  ============================================================
% This code was developed and tested using MATLAB versions R2023b and R2024b.
%% ============================================================
%  FUNCTION LIST
%  ============================================================
%
% Main.m
% │
% ├── Config/
% │   └── createConfig.m
% │
% ├── Geometry/
% │   └── setupGeometry.m
% │	      ├── setupFlatLens.m
% │	      └── setupCylindricalLens.m
% │
% ├── InitializeDesign/
% │   ├── setupFlatLens.m
% │   ├── setupCylindricalLens.m
% │   ├── IncidentEpatchArray.m
% │   ├── Exx_Calc.m
% │   ├── QXX.m
% │   └── self_term_H02_rect.m
% │
% ├── Solver/
% │   ├── Solver.m
% │   ├── ForwardBackwardSolver.m
% │   ├── MappingFunction.m
% │   ├── CostPlot.m
% │   ├── GradientPlot.m
% │   └── SaveData.m
% │
% ├── PostProcessing/
% │   ├── PostProcessing.m
% │   ├── HFSSautomationFlatLens.m
% │   ├── Define_New_Design_Variable.m
% │   ├── Creat_Permittivity_Box.m
% │   ├── HFSSautomationCylindricalLens.m
% │   └── Creat_Permittivity_Sector.m
% │
% ├── Analysis/
% │   ├── analyzeDesign.m
% │   ├── plotFieldsFlatLens.m
% │   ├── plotDirectivityExpanding.m
% │   ├── plotDirectivityCompressing.m
% │   ├── plotSpectrumFlatLens.m
% │   ├── plotPermittivityProfileFlatLens.m
% │   ├── plotSpatialTransferMatrix.m
% │   ├── plotPermittivityProfileCylindricalLens.m
% │   ├── plotFieldsCylindricalLens.m
% │   └── calcIPR.m
% │
% └── SaveResults/
%% ============================================================
%  VARIABLES / PARAMETERS
%  ============================================================
%
% ├── params
% │   ├── lambda0
% │   ├── f0
% │   ├── freq_range
% │   ├── caseID
% │   ├── folderPath
% │   ├── mainFilename
% │   ├── physics
% │   │	  ├── mu0
% │   │	  ├── ep0
% │   │	  ├── eta0
% │   │   └── c
% │   │
% │   ├── units
% │   │	  ├── GHz
% │   │   ├── cm
% │   │	  └── mm
% │   │
% │   ├── lens
% │   │	  ├── width 	
% │   │	  ├── thickness 	
% │   │	  ├── shape
% │   │	  ├── Wout
% │   │	  ├── dxS, drS
% │   │	  ├── dyS, dphiS
% │   │	  ├── NSX, NSr = NSh
% │   │	  ├── NSY, NStheta = NSt
% │   │	  ├── NS
% │   │	  ├── xS_values, rS_values
% │   │	  ├── yS_values, phiS_values
% │   │	  ├── xv_Out	
% │   │	  ├── xv_In1	
% │   │	  ├── xv_In2	
% │   │	  ├── macrocell_t		
% │   │	  ├── macrocell_h				
% │   │	  ├── Base_P
% │   │	  ├── nLayers	
% │   │	  ├── Base_d
% │   │	  ├── Teeth_n
% │   │	  ├── NBase_P
% │   │	  ├── beta1
% │   │	  ├── beta2
% │   │	  ├── beta3
% │   │	  ├── p0
% │   │	  ├── bx, br		
% │   │	  ├── by, bphi		
% │   │	  └── PhiMax 		
% │   │	
% │   ├── solver
% │   │	  ├── dl
% │   │	  ├── maxIter
% │   │	  ├── stepSize
% │   │	  ├── useGPU
% │   │	  ├── Apply_IterBatching		
% │   │	  ├── IterBatchSize		
% │   │	  ├── BinarizationIter	
% │   │	  └── iter
% │   │	
% │   ├── material
% │   │	  ├── tanDelta
% │   │	  ├── epsMin
% │   │	  └── epsMax
% │   │	
% │   ├── array
% │   │	  ├── de
% │   │	  ├── Win
% │   │	  ├── Ne
% │   │	  ├── xj
% │   │	  ├── yj
% │   │	  ├── patch_a
% │   │	  ├── patch_b
% │   │	  ├── patch_er
% │   │	  ├── patch_h
% │   │	  └── phi_i
% │   │	
% │   ├── geometry
% │   │	  ├── Fo
% │   │	  ├── dlp
% │   │	  ├── NpX
% │   │	  ├── NpY
% │   │	  ├── xP_values
% │   │	  ├── yP_values
% │   │	  ├── nA
% │   │	  ├── xsA
% │   │	  ├── ysA
% │   │	  ├── NYvec
% │   │	  ├── Y_vec
% │   │	  ├── xF	
% │   │	  └── yF	
% │   │
% │   ├── Config
% │   │	  ├── function
% │   │	  ├── nF
% │   │	  ├── nG
% │   │	  ├── phi_s	
% │   │	  ├── phi_t	
% │   │	  ├── Nphi
% │   │	  ├── dphi
% │   │	  ├── Phi
% │   │	  ├── range
% │   │	  ├── bb0
% │   │	  └── nP
% │   │
% │   ├── analyzer
% │   │	  ├── Gradient_Display_Flag
% │   │	  ├── Gradient_Iter_Save_Flag
% │   │	  ├── Cost_per_Iter_Save_Flag
% │   │	  ├── LegendTitles
% │   │	  ├── Spatial_Transfer_Matrix_Flag
% │   │	  ├── Directivity_Display_Flag
% │   │	  ├── Permittivity_Display_Flag
% │   │	  ├── Field_Display_Flag
% │   │	  ├── Display_Spectrum
% │   │	  ├── FontSize
% │   │	  └── PlotWidth
% │   │
% │   └── postprocessing
% │   	  ├── box_x
% │   	  └── Quantization_Levels_Vec
% │
% └── design
%     ├── Dir_goal
%     ├── Dir_inc
%     ├── omega_vec
%     ├── k_vec
%     ├── EiF
%     ├── Gvv	
%     ├── Gff
%     ├── Gv_F
%     ├── Gv_In
%     ├── Gv_Out1
%     ├── Gv_Out2
%     ├── Gl_ai
%     ├── Gao_l
%     ├── Gao_ai
%     ├── EffFi
%     ├── E_Aperturei_F
%     ├── E_Aperturei_F_Out1
%     ├── E_Aperturei_F_Out2
%     ├── JF
%     ├── JA
%     ├── X
%     ├── p
%     ├── EiA
%     ├── Dir_mag
%     ├── Delta_U_hat
%     ├── cost
%     ├── eps_r_vec
%     ├── Eff
%     ├── new_gg
%     └── new_bb
%  ============================================================
%% -----------------------------------------------------------
clc; clear; close all;

% Define fundamental constants and unit conversion factors
params.physics.c = 3e8;
params.units.GHz = 1e9;

%% ------------------------------------------------------------
%  1. SELECT DESIGN CASE
%  ------------------------------------------------------------

% Select the design configuration:
%   1 - Angular-channel compression, Flat lens
%   2 - Angular-channel compression, cylindrical lens
%   3 - Coherent-aperture expansion, Flat lens
%   4 - Coherent-aperture expansion, cylindrical lens
params.caseID = 4;

switch params.caseID
    case 1
        params.Config.function = "Angular_Compression";
        params.lens.shape = "Flat";

    case 2
        params.Config.function = "Angular_Compression";
        params.lens.shape = "Cylindrical";

    case 3
        params.Config.function = "Coherent_Expansion";
        params.lens.shape = "Flat";

    case 4
        params.Config.function = "Coherent_Expansion";
        params.lens.shape = "Cylindrical";
end


%% ------------------------------------------------------------
%  2. PHYSICAL / ARRAY PARAMETERS
%  ------------------------------------------------------------

% Operating frequency and corresponding free-space wavelength
params.f0      = 30 * params.units.GHz;
params.freq_range   = [30] * params.units.GHz;
params.lambda0 = params.physics.c / params.f0;

% Array element spacing
params.array.de = 0.5 * params.lambda0;


%% ------------------------------------------------------------
%  3. LENS PARAMETERS
%  ------------------------------------------------------------

% Lens parameter controlling the initial design/parameterization
params.lens.beta1 = 10;


%% ------------------------------------------------------------
%  4. SOLVER PARAMETERS
%  ------------------------------------------------------------

% Spatial discretization used by the electromagnetic solver
params.solver.dl = params.lambda0 / 10;

% Enable GPU acceleration and iterative batching
params.solver.useGPU = true;
params.solver.Apply_IterBatching = true;


%% ------------------------------------------------------------
%  5. MATERIAL PARAMETERS
%  ------------------------------------------------------------

% Material loss tangent and allowable relative-permittivity range
params.material.tanDelta = 0.0046;
params.material.epsMin = 1 + 1e-12;
params.material.epsMax = 2.5;


%% ------------------------------------------------------------
%  6. PLOT PARAMETERS
%  ------------------------------------------------------------

% Spatial discretization used for geometry visualization
params.geometry.dlp = params.solver.dl;


%% ------------------------------------------------------------
%  7. FUNCTION- AND GEOMETRY-SPECIFIC PARAMETERS
%  ------------------------------------------------------------

% Set the geometry, lens, and optimization parameters for the
% selected design case.
switch params.caseID

    case 1 % Angular-channel compression, Flat lens

        % Approximate simulation resources:
        % CPU: 10 cores, RAM: 70 GB, GPU: A100:1, memory: 40 GB, Time: 30
        % h (without fields plot)
        
        % -----------------------------------------------------
        % Geometry parameters
        % -----------------------------------------------------
        params.geometry.Fo = 15 * params.lambda0;
        params.array.Win = 6 * params.lambda0;

        % Lens dimensions and discretization
        params.lens.Wout  = 15 * params.lambda0;
        params.lens.width = 70 * params.lambda0;

        params.lens.macrocell_t = 1 * params.solver.dl;
        params.lens.macrocell_h = 3 * params.solver.dl;
        params.lens.Base_d = 3 * params.solver.dl;
        params.lens.Base_h = 0 * params.solver.dl;
        params.lens.nLayers = 10;

        % -----------------------------------------------------
        % Optimization parameters
        % -----------------------------------------------------
        params.solver.maxIter = 5000;
        params.solver.BinarizationIter = params.solver.maxIter - 20;
        params.solver.stepSize = 5e-1;
        params.solver.IterBatchSize = 20;

        % Initial design parameter
        params.lens.p0 = -0.2;


    case 2 % Angular-channel compression, Cylindrical lens

        % Approximate simulation resources:
        % CPU: 10 cores, RAM: 60 GB, GPU: A100:1, memory: 40 GB, Time: 13 h

        % -----------------------------------------------------
        % Geometry parameters
        % -----------------------------------------------------
        params.geometry.Fo = 15 * params.lambda0;
        params.array.Win = 3.5 * params.lambda0;

        % Lens dimensions and maximum angular extent
        params.lens.Wout = 9 * params.lambda0;
        params.lens.PhiMax = 85;

        params.lens.macrocell_t = 1 * params.solver.dl;
        params.lens.macrocell_h = 3 * params.solver.dl;
        params.lens.Base_d = 3 * params.solver.dl;
        params.lens.Base_h = 0 * params.solver.dl;
        params.lens.nLayers = 10;

        % -----------------------------------------------------
        % Optimization parameters
        % -----------------------------------------------------
        params.solver.maxIter = 3000;
        params.solver.BinarizationIter = params.solver.maxIter - 20;
        params.solver.stepSize = 2e-1;
        params.solver.IterBatchSize = 8;

        % Initial design parameter
        params.lens.p0 = 0.0;


    case 3 % Coherent-aperture expansion, Flat lens

        % Approximate simulation resources:
        % CPU: 10 cores, RAM: 100 GB, GPU: A100:1, memory: 40 GB, Time: 48 h

        % -----------------------------------------------------
        % Geometry parameters
        % -----------------------------------------------------
        params.geometry.Fo = 8 * params.lambda0;
        params.array.Win = 5.5 * params.lambda0;

        % Lens dimensions
        params.lens.Wout  = 20 * params.lambda0;
        params.lens.width = 70 * params.lambda0;

        params.lens.macrocell_t = 1 * params.solver.dl;
        params.lens.macrocell_h = 3 * params.solver.dl;
        params.lens.Base_d = 3 * params.solver.dl;
        params.lens.Base_h = 0 * params.solver.dl;
        params.lens.nLayers = 10;

        % -----------------------------------------------------
        % Optimization parameters
        % -----------------------------------------------------
        params.solver.maxIter = 5000;
        params.solver.BinarizationIter = params.solver.maxIter - 20;
        params.solver.stepSize = 1.5e-1;
        params.solver.IterBatchSize = 8;

        % Initial design parameter
        params.lens.p0 = -0.4;


    case 4 % Coherent-aperture expansion, Cylindrical lens

        % Approximate simulation resources:
        % CPU: 10 cores, RAM: 60 GB, GPU: A100:1, memory: 40 GB, Time: 9 h

        % -----------------------------------------------------
        % Geometry parameters
        % -----------------------------------------------------
        params.geometry.Fo = 10 * params.lambda0;
        params.array.Win = 3.5 * params.lambda0;

        % Lens dimensions and maximum angular extent
        params.lens.Wout = 10.5 * params.lambda0;
        params.lens.PhiMax = 85;

        params.lens.macrocell_t = 2 * params.solver.dl;
        params.lens.macrocell_h = 6 * params.solver.dl;
        params.lens.Base_d = 6 * params.solver.dl;
        params.lens.Base_h = 0 * params.solver.dl;
        params.lens.nLayers = 7;

        % -----------------------------------------------------
        % Optimization parameters
        % -----------------------------------------------------
        params.solver.maxIter = 2000;
        params.solver.BinarizationIter = params.solver.maxIter - 20;
        params.solver.stepSize = 5e0;
        params.solver.IterBatchSize = 8;

        % Initial design parameter
        params.lens.p0 = 0.0;
end


%% ------------------------------------------------------------
%  8. ANALYZER PARAMETERS
%  ------------------------------------------------------------

% Enable or disable individual analysis outputs
params.analyzer.Directivity_Display_Flag = true;
params.analyzer.Field_Display_Flag = true;
params.analyzer.Permittivity_Display_Flag = true;
params.analyzer.Display_Spectrum = true;
params.analyzer.Spatial_Transfer_Matrix_Flag = true;
params.analyzer.Gradient_Display_Flag = true;
params.analyzer.Gradient_Iter_Save_Flag = true;
params.analyzer.Cost_per_Iter_Save_Flag = true;

% General figure formatting parameters
params.analyzer.FontSize = 14;
params.analyzer.PlotWidth = 24;


%% ------------------------------------------------------------
%  9. ADD REQUIRED PROJECT PATHS
%  ------------------------------------------------------------

% Add all project subdirectories required by the configuration,
% geometry, initialization, solver, analysis, and post-processing
% routines.
addpath(genpath('Config'));
addpath(genpath('Geometry'));
addpath(genpath('InitializeDesign'));
addpath(genpath('Solver'));
addpath(genpath('PostProcessing'));
addpath(genpath('Analysis'));
addpath(genpath('SaveResults'));


%% ------------------------------------------------------------
%  10. CREATE GEOMETRY AND TARGET
%  ------------------------------------------------------------

% Generate the configuration and initialize the geometry and
% target response based on the selected design case.
params = createConfig(params);
params = setupGeometry(params);


%% ------------------------------------------------------------
%  11. INITIALIZE DESIGN
%  ------------------------------------------------------------

% Generate the initial material distribution and update any
% parameters required by the optimization.
[design, params] = initializeDesign(params);


%% ------------------------------------------------------------
%  12. RUN COMMON SOLVER
%  ------------------------------------------------------------

% Perform the full-wave inverse-design optimization.
[design, params] = Solver(design, params);


%% ------------------------------------------------------------
%  13. ANALYZE FINAL DESIGN
%  ------------------------------------------------------------

% Evaluate and visualize the electromagnetic performance of
% the optimized design.
analyzeDesign(design, params);


%% ------------------------------------------------------------
%  14. POST-PROCESSING
%  ------------------------------------------------------------

% Generate and save the final post-processing results.
PostProcessing(design, params);


% ------------------------------------------------------------
%  End of Code
% ------------------------------------------------------------