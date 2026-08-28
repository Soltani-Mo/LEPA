function [Previously_Defined_Material_out] = Creat_Permittivity_Box(fid, Box_Number_String, Xpos, Ypos, Zpos, Xsize, Ysize, Zsize, Permittivity, Quantization_Levels_Vec, Previously_Defined_Material_in, Loss_Tangent)

%% Creat Box

fprintf( fid, 'oEditor.CreateBox(\n');
fprintf( fid, '	[\n');
fprintf( fid, '		"NAME:BoxParameters",\n');
fprintf( fid, '		"XPosition:="		, "');
fprintf( fid, Xpos);
fprintf( fid, '",\n');

fprintf( fid, '		"YPosition:="		, "');
fprintf( fid, Ypos);
fprintf( fid, '",\n');

fprintf( fid, '		"ZPosition:="		, "');
fprintf( fid, Zpos);
fprintf( fid, '",\n');

fprintf( fid, '		"XSize:="		, "');
fprintf( fid, Xsize);
fprintf( fid, '",\n');

fprintf( fid, '		"YSize:="		, "');
fprintf( fid, Ysize);
fprintf( fid, '",\n');

fprintf( fid, '		"ZSize:="		, "');
fprintf( fid, Zsize);
fprintf( fid, '"\n');

fprintf( fid, '	], \n');
fprintf( fid, '	[\n');
fprintf( fid, '		"NAME:Attributes",\n');

fprintf( fid, '		"Name:="		, "Box');
fprintf( fid, Box_Number_String);
fprintf( fid, '",\n');
fprintf( fid, '		"Flags:="		, "",\n');

c = turbo(numel(Quantization_Levels_Vec));

% idx = find(Quantization_Levels_Vec == Permittivity);
[~, idx] = min(abs(Quantization_Levels_Vec - Permittivity));

%idx

cii = num2str( floor( c( idx, : ) .* 255 ) );

% group_edges = linspace(er_min, er_max, N);
% entry = str2double(Permittivity_String);
% cii = num2str([1 1 1]);
% for ii = 1:N
%     if entry >= group_edges(ii) && entry < group_edges(ii+1)
%         cii = num2str( floor( c(ii,:).*255 ) );
%         break;
%     end
% end

fprintf( fid, '		"Color:="		, "(');
fprintf( fid, cii);
fprintf( fid, ')",\n');

fprintf( fid, '		"Transparency:="	, 0,\n');
fprintf( fid, '		"PartCoordinateSystem:=", "Global",\n');
fprintf( fid, '		"UDMId:="		, "",\n');
fprintf( fid, '		"MaterialValue:="	, "\\"vacuum\\"",\n');
fprintf( fid, '		"SurfaceMaterialValue:=", "\\"\\"",\n');
fprintf( fid, '		"SolveInside:="		, True,\n');
fprintf( fid, '		"ShellElement:="	, False,\n');
fprintf( fid, '		"ShellElementThickness:=", "0mm",\n');
fprintf( fid, '		"IsMaterialEditable:="	, True,\n');
fprintf( fid, '		"UseMaterialAppearance:=", False,\n');
fprintf( fid, '		"IsLightweight:="	, False\n');
fprintf( fid, '	])\n');


%% Change Permittivity

if ~Previously_Defined_Material_in(idx)

    Previously_Defined_Material_in(idx) = 1;

    % Define New Permittivity

    fprintf( fid, 'oDefinitionManager = oProject.GetDefinitionManager()\n');
    fprintf( fid, 'oDefinitionManager.AddMaterial(\n');
    fprintf( fid, '	[\n');

    fprintf( fid, '		"NAME:MaterialBox');
    % fprintf( fid, Box_Number_String);
    fprintf( fid, num2str(idx));
    fprintf( fid, '",\n');
    fprintf( fid, '		"CoordinateSystemType:=", "Cartesian",\n');
    fprintf( fid, '		"BulkOrSurfaceType:="	, 1,\n');
    fprintf( fid, '		[\n');
    fprintf( fid, '			"NAME:PhysicsTypes",\n');
    fprintf( fid, '			"set:="			, ["Electromagnetic"]\n');
    fprintf( fid, '		],\n');
    fprintf( fid, '		"permittivity:="	, "');
    fprintf( fid, num2str( Permittivity ));
    fprintf( fid, '",\n');

    fprintf( fid, '		"dielectric_loss_tangent:=", "');
    fprintf( fid, num2str(Loss_Tangent));
    fprintf( fid, '"\n');
    fprintf( fid, '	])\n');

end

fprintf( fid, 'oEditor.ChangeProperty(\n');
fprintf( fid, '	[\n');
fprintf( fid, '		"NAME:AllTabs",\n');
fprintf( fid, '		[\n');
fprintf( fid, '			"NAME:Geometry3DAttributeTab",\n');
fprintf( fid, '			[\n');
fprintf( fid, '				"NAME:PropServers", \n');
fprintf( fid, '				"Box');
fprintf( fid, Box_Number_String);
fprintf( fid, '"\n');

fprintf( fid, '			],\n');
fprintf( fid, '			[\n');
fprintf( fid, '				"NAME:ChangedProps",\n');
fprintf( fid, '				[\n');
fprintf( fid, '					"NAME:Material",\n');
fprintf( fid, '					"Value:="		, "\\"MaterialBox');
% fprintf( fid, Box_Number_String);
fprintf( fid, num2str(idx));

fprintf( fid, '\\""\n');
fprintf( fid, '				]\n');
fprintf( fid, '			]\n');
fprintf( fid, '		]\n');
fprintf( fid, '	])\n');

% else

% Assign Previously Defined Material

% fprintf( fid, 'oEditor.ChangeProperty(\n');
% fprintf( fid, '	[\n');
% fprintf( fid, '		"NAME:AllTabs",\n');
% fprintf( fid, '		[\n');
% fprintf( fid, '			"NAME:Geometry3DAttributeTab",\n');
% fprintf( fid, '			[\n');
% fprintf( fid, '				"NAME:PropServers", \n');
% fprintf( fid, '				"Box\n');
% fprintf( fid, Box_Number_String);
% fprintf( fid, '"\n');
% fprintf( fid, '			],\n');
% fprintf( fid, '			[\n');
% fprintf( fid, '				"NAME:ChangedProps",\n');
% fprintf( fid, '				[\n');
% fprintf( fid, '					"NAME:Material",\n');
% fprintf( fid, '					"Value:="		, "\"Material1\""\n');
% fprintf( fid, '				]\n');
% fprintf( fid, '			]\n');
% fprintf( fid, '		]\n');
% fprintf( fid, '	])\n');
% % fprintf( fid, '\n');
% % fprintf( fid, '\n');
% % fprintf( fid, '\n');
% % fprintf( fid, '\n');
% % fprintf( fid, '\n');
% % fprintf( fid, '\n');
% % fprintf( fid, '\n');
% % fprintf( fid, '\n');
% fprintf( fid, '\n');
% fprintf( fid, '\n');
% fprintf( fid, '\n');
% fprintf( fid, '\n');

% end

% Pass it to the next loop
Previously_Defined_Material_out = Previously_Defined_Material_in;


end

