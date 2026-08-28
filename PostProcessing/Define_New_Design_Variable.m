
function [] = Define_New_Design_Variable(fid,Variable_Name,Variable_Value)

%% Define Variables

fprintf( fid, 'oDesign.ChangeProperty(\n');
fprintf( fid, '	[\n');
fprintf( fid, '		"NAME:AllTabs",\n');
fprintf( fid, '		[\n');

fprintf( fid, '			"NAME:LocalVariableTab",\n');
fprintf( fid, '			[\n');
fprintf( fid, '				"NAME:PropServers", \n');
fprintf( fid, '				"LocalVariables"\n');
fprintf( fid, '			],\n');
fprintf( fid, '			[\n');
fprintf( fid, '				"NAME:NewProps",\n');
fprintf( fid, '				[\n');
%fprintf( fid, '					"NAME:Ax",\n');
fprintf( fid, '					"NAME:');
fprintf( fid, Variable_Name);
fprintf( fid, '",\n');
fprintf( fid, '					"PropType:="		, "VariableProp",\n');
fprintf( fid, '					"UserDef:="		, True,\n');
%fprintf( fid, '					"Value:="		, "422um"\n');
fprintf( fid, '					"Value:="		, "');
fprintf( fid, Variable_Value);
fprintf( fid, '"\n');

fprintf( fid, '				]\n');
fprintf( fid, '			]\n');
fprintf( fid, '		]\n');
fprintf( fid, '	])\n');

end
