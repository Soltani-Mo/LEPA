function HFSSautomationCylindricalLens(design, params)


%% Creat Boxes

Box_Selection_String = 'Polyline1_1';
Box_Counter = 0;


dphi_deg = params.lens.dphiS * 180 / pi;
Teeth_T = params.lens.macrocell_t / params.solver.dl;
er_grid = reshape(design.eps_r_vec(1:params.lens.NS/2), [params.lens.NSr, params.lens.NSphi/2]);

% Number of values taken by n
numN = numel(1:Teeth_T:params.lens.NSphi/2);

totalIter = numN * params.lens.NSr;
blockSize = 2000;
numBlocks = ceil(totalIter / blockSize);

for b = 1:numBlocks

    % Define index range for this block
    startIdx = (b-1)*blockSize + 1;
    endIdx   = min(b*blockSize, totalIter);

    % Initialize .txt file
    filename = char(strcat(params.folderPath, '/', ...
    sprintf('%s_File_%d_of_%d_Infinite_Array.py', params.mainFilename, b, numBlocks)));

    fid = fopen( filename, 'wt' );
    fprintf( fid, 'import ScriptEnv\n');
    fprintf( fid, 'ScriptEnv.Initialize("Ansoft.ElectronicsDesktop")\n');
    fprintf( fid, 'oDesktop.RestoreWindow()\n');
    fprintf( fid, ['oProject = oDesktop.SetActiveProject("DL_Writer_v', num2str(b), '")\n']);
    fprintf( fid, 'oDesign = oProject.SetActiveDesign("HFSSDesign1")\n');
    fprintf( fid,'oEditor = oDesign.SetActiveEditor("3D Modeler")\n');
    Define_New_Design_Variable(fid, 'box_x', sprintf('%f mm', params.postprocessing.box_x * 1000) );

    Previously_Defined_Material = zeros(size(params.postprocessing.Quantization_Levels_Vec));

    for k = startIdx:endIdx

        ii = k;   % equivalent to ii = ii + 1

        % Recover indices (stride-aware)
        nIndex = ceil(k / params.lens.NSr);
        m      = mod(k-1, params.lens.NSr) + 1;
        n      = 1 + (nIndex-1)*Teeth_T;

        % ---- Your original computation here ----
        phi_deg = params.lens.phiS_values(n);
        rv = params.lens.rS_values(m);

        er_value = er_grid(m, n);

        if er_value > (1.0001)

            Box_Counter = Box_Counter + 1;
            Box_Number_String = num2str(Box_Counter);

            Previously_Defined_Material = Creat_Permittivity_Sector(fid, Box_Number_String, rv, phi_deg, params.lens.drS, dphi_deg, 'box_x', real(er_value), params.postprocessing.Quantization_Levels_Vec, Previously_Defined_Material, params.material.tanDelta, Teeth_T);

            if ii > 1
                Box_Selection_String = strcat(Box_Selection_String,',Polyline1_',Box_Number_String);
            end
       end

    end

    fprintf( fid, 'oEditor.DuplicateMirror(\n');
    fprintf( fid, '	[\n');
    fprintf( fid, '		"NAME:Selections",\n');
    fprintf( fid, '		"Selections:="		, "');
    fprintf( fid, Box_Selection_String);
    fprintf( fid, '",\n');

    fprintf( fid, '		"NewPartsModelFlag:="	, "Model"\n');
    fprintf( fid, '	], \n');
    fprintf( fid, '	[\n');
    fprintf( fid, '		"NAME:DuplicateToMirrorParameters",\n');
    fprintf( fid, '		"DuplicateMirrorBaseX:=", "0mm",\n');
    fprintf( fid, '		"DuplicateMirrorBaseY:=", "0mm",\n');
    fprintf( fid, '		"DuplicateMirrorBaseZ:=", "0mm",\n');
    fprintf( fid, '		"DuplicateMirrorNormalX:=", "0mm",\n');
    fprintf( fid, '		"DuplicateMirrorNormalY:=", "1mm",\n');
    fprintf( fid, '		"DuplicateMirrorNormalZ:=", "0mm"\n');
    fprintf( fid, '	], \n');
    fprintf( fid, '	[\n');
    fprintf( fid, '		"NAME:Options",\n');
    fprintf( fid, '		"DuplicateAssignments:=", True\n');
    fprintf( fid, '	], \n');
    fprintf( fid, '	[\n');
    fprintf( fid, '		"CreateGroupsForNewObjects:=", False\n');
    fprintf( fid, '	])\n');

    fclose(fid);

    Box_Selection_String = sprintf('Polyline1_%d', Box_Counter);

end


disp(['Total number of boxes for this lens = ', num2str(Box_Counter)]);
disp('Finished witing into the .py file.');


end