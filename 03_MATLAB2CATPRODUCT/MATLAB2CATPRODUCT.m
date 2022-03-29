% Designed by: Lorenzo Nicoletti (FTM, Technical University of Munich)
%-------------
% Created on: 10.03.2022
% ------------
% Version: Matlab2020b
%-------------
% Description: In this script there are different section to perform different tasks on
%              a given CATIA Assembly.
%              Also compare the documentation in the README of this
%              repository.
% ------------
%% PREPROCESSING: The variables declared in this section are required for the other sections!
% Create a connection with the CATIA Application
catia = actxserver('catia.application');

% The Cube_Assembly.CATProduct MUST already be opened in CATIA. Check if this is the case
try invoke(get(catia, 'Windows'),'Item','Cube_Assembly.CATProduct')
catch 
    errordlg('BEFORE STARTING, OPEN THE FILE Cube_Assembly.CATProduct','Error');
    return
end

% Select all the opened documents
Docs=get(catia,'Documents');

% Select the Cube_Assembly.CATProduct document
Docprod = invoke(Docs,'Item','Cube_Assembly.CATProduct');

% Select the uppermost node of the CATIA tree -> This is the master node of the CATPart
Assembly = get(Docprod,'product'); % In the first figure in the README this is the node "Cube_part"

% Get the list of products contained in the assembly
Assembly_prods = get(Assembly,'products');

%% 1) Explore the characteristics of the Product

% Get the Product Parameters, which contains all the parameters of the assembly
Param_prod = invoke(Assembly_prods,'Item','Parameters');


% Select the Publications of the Prameters Prod
Publications = get(Param_prod,'Publications');

%List the available publications:
str = 'The Product contains the following publications\n';
for i = 1 : Publications.get('Count')
   Pub = Publications.invoke('Item',i);
   str = [str,Pub.get('Name'),'\n'];     
end

sprintf(str)


str = 'The Product contains the following subproducts\n';
for i = 1 : Assembly_prods.get('Count')
   Prod = Assembly_prods.invoke('Item',i);                    
   str = [str,Prod.get('Name'),'\n'];     
end
    
%Print the list of publications
sprintf(str)


%% 2) Set all the Publications/Parameters to a given value

% Get the Product Parameters, which contains all the parameters of the assembly
Param_prod = invoke(Assembly_prods,'Item','Parameters');

% Select the Publications of the Prameters Prod
Publications = get(Param_prod,'Publications');

Newcube_dim = 1000;
Newcube_offset = 500;

% Set the dimensions of the cube to a value of 100 mm
for i = 1: Publications.get('Count')
    
    Pub = Publications.invoke('Item',i);
    
    Val = get(Pub,'Valuation');
    
    % The Publications that control the cube dimensions have the identifier "Cube"
    if contains(Pub.get('Name'),'Cube')
        set(Val,'Value',Newcube_dim);
    end
    
end


% Set the dimensions of the cube to a value of 100 mm
for i = 1: Publications.get('Count')
    
    Pub = Publications.invoke('Item',i);
    
    Val = get(Pub,'Valuation');
    
    % The Publications that control the distances between the cubes have the identifier "Offset"
    if contains(Pub.get('Name'),'Offset')
        set(Val,'Value',Newcube_offset);
    end
    
end


Assembly.invoke('Update');

%% 3) Change appearance to the first Cube:

% Get the Product Parameters, which contains all the parameters of the assembly
Docpart = invoke(Docs,'Item','Cube_part_2.CATPart');

% Get tzhe part node:
Cube = Docpart.get('part');

input_4      = [0, 101, 189, ...% The RGB triple with values comprised between 0 and 255.
                255, ...        % The opacity of the Cube, comprised between 0 and 255.
                4, ...          % Line width: The value ranges from 1 to 63. Each index is a line type customizable in the page Tools/Options/General/Display/Line Type.
                4];             % Line type: The value ranges from 1 to 63. Each index is a thickness customizable in the page Tools/Options/General/Display/thickness.

% Assign the Body and Block nodes of the CATPart to two distinct MATLAB variables
Cube_body  = invoke(get(Cube, 'Bodies'), 'Item','Cube_body');                    %Assign the "Cube_body" node (there is only one but we use this line to show the 'Item' property)
Cube_block = invoke(get(Cube_body, 'Shapes'),'Item','Cube_block');  %Assign the "Cube_block" node

% In order to access the graphic propreties, the Cube has to be assigned to a Selection object. Therefore, two corresponding selection objects are created 
Sel_cube{1} = get(Docpart,'Selection');   %This selection object will store the node "Cube_body" of "Cube_part"
Sel_cube{2} = get(Docpart,'Selection');   %This selection object will store the node "Cube_block" of "Cube_part"

% Clear the selection object to make sure that they do not contain selections from previous code runs
invoke(Sel_cube{1},'clear');
invoke(Sel_cube{2},'clear');

% Now that the selection object are created and cleared, it is possible to assign the "Cube_body" and "Cube_block" object to them
invoke(Sel_cube{1},'Add',Cube_body);
invoke(Sel_cube{2},'Add',Cube_block);

% With the hereby updated Selections, it is possible to access to the VisProperties of the object "Cube_body" and "Cube_block"
cube_visprop       = get(Sel_cube{1}, 'VisProperties');
cube_bolck_visprop = get(Sel_cube{2}, 'VisProperties');
%The Visproperties contains a Set of graphical properties which can be changed directly here in the script

% Change the color of the cube
invoke(cube_visprop,'SetRealColor',input_4(1), input_4(2), input_4(3), 1)

% Make the cube visible/invisible
invoke(cube_visprop,'SetShow',1); %Cube is not visible (hidden)
invoke(cube_visprop,'SetShow',0); %Cube is visible 

% Set the opacity/transparency of the Cube (255: no transparency; 0: full transparency)
invoke(cube_visprop,'SetRealOpacity',input_4(4), 1)
invoke(cube_bolck_visprop,'SetRealOpacity',input_4(4), 1)

% Change the line thickness of the cube edges
invoke(cube_visprop,'SetRealWidth',input_4(5), 1);
invoke(cube_bolck_visprop,'SetRealWidth',input_4(5), 1);

% Change line type of the cube edges
invoke(cube_visprop,'SetRealLineType',input_4(6), 1);
invoke(cube_bolck_visprop,'SetRealLineType',input_4(6), 1);

%% 4) Add a new cube to the main product 

sel1 = get(Docprod,'Selection')

sel1.invoke('Clear')


Cubeprod = invoke(Assembly_prods,'Item','Cube_part_1');

sel1.invoke('Add', Cubeprod)

sel1.invoke('Copy')



sel1.invoke('Paste')

% Update the cube
invoke(Cube,'update')








