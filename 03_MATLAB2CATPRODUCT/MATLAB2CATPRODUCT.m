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
%              BEFORE STARTING: Open the Assembly ../03_MATLAB2CATPRODUCT/Cube_Assembly.CATProduct in CATIA
% ------------
%% PREPROCESSING: The variables declared in this section are required for the other sections!
% Create a connection with the CATIA V5
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
Assembly = get(Docprod,'product'); 

% Get the list of the products contained in the assembly
Assembly_prods = get(Assembly,'products');

%% Implementation:
%1) Retrieve list of subproducts and publications
%2) Set all the Publications/Parameters to a given value
%3) Change appearance to the first Cube of the assembly

%% 1) Retrieve list of subproducts and publications
%     List all the contained subproducts and publication names. The same
%     procedure can be used to explore also other properties of an
%     assembly.

% Get the subproduct "Parameters", which stores the parameters of the assembly
Param_prod = invoke(Assembly_prods,'Item','Parameters');

% Select the Publications contained in "Parameters"
Publications = get(Param_prod,'Publications');

% Loop the Publications list and create a list of the existing publications
pub_list = 'The Product contains the following publications\n';
for i = 1 : Publications.get('Count')
   
    % Select the i-nth publication
    Pub = Publications.invoke('Item',i);
    
    % Retrieve the name of the i-nth publication
    pub_list = [pub_list,Pub.get('Name'),'\n'];     
   
end

% Print the list of Publication
sprintf(pub_list)

% Loop through the subproducts at the first level
subprod_list = 'The Product contains the following subproducts\n';
for i = 1 : Assembly_prods.get('Count')
    
    % Select the i-nth subproduct
    Prod = Assembly_prods.invoke('Item',i);     
    
    % Retrieve the name of the i-nth subproduct 
    subprod_list = [subprod_list,Prod.get('Name'),'\n'];     
   
end
    
%Print the list of subproducts on the first level
sprintf(subprod_list)
    

%% 2) Set all the Publications/Parameters to a given value
%     In this section we show how to change the parameters of the assembly
%     by using the publication. We will change the dimensions of the two
%     cubes and their relative distance

input_2 = [500, ... % Dimension of cube length, width and height (all set as equal)
           300];    % Distance between the two cube in X, Y and Z (all set as equal)

% Get the subproduct "Parameters", which contains all the parameters of the assembly
Param_prod = invoke(Assembly_prods,'Item','Parameters');

% Select the Publications of the subproduct
Publications = get(Param_prod,'Publications');

% Set the dimensions of the cube to a value of 100 mm
for i = 1: Publications.get('Count')
    
    % Select the i-nth publication
    Pub = Publications.invoke('Item',i);
    
    % Select the Valuation object of the i-nth publication
    Val = get(Pub,'Valuation');
    
    % The Publications that control the cube dimensions have the identifier "Cube"
    if contains(Pub.get('Name'),'Cube') % If 1 then change the value of the publication
        set(Val,'Value',input_2(1));
    end   
end


% Set the dimensions of the cube to a value of 100 mm
for i = 1: Publications.get('Count')
    
    Pub = Publications.invoke('Item',i);
    
    Val = get(Pub,'Valuation');
    
    % The Publications that control the distances between the cubes have the identifier "Offset"
    if contains(Pub.get('Name'),'Offset')
        set(Val,'Value',input_2(2));
    end
    
end

Assembly.invoke('Update');

%% 3) Change appearance to the first Cube of the assembly
%     In this section we show how to change the appearance of one of the
%     cube. For this scope we apply the code implemented in "MATLAB2CATPart_examples.m"
%     As you can see, as long as the subproduct is selected correctly, all
%     the functions shown in "MATLAB2CATPart_examples.m" can also be used
%     for CATProducts

input_3      = [0, 101, 189, ...% The RGB triple with values comprised between 0 and 255.
                255, ...        % The opacity of the Cube, comprised between 0 and 255.
                4, ...          % Line width: The value ranges from 1 to 63. Each index is a line type customizable in the page Tools/Options/General/Display/Line Type.
                4];             % Line type: The value ranges from 1 to 63. Each index is a thickness customizable in the page Tools/Options/General/Display/thickness.

% Select the part document of the subproduct we want to change
Docpart = invoke(Docs,'Item','Cube_part_2.CATPart');

% Get the corresponding part node:
Cube = Docpart.get('part');
            
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
invoke(cube_visprop,'SetRealColor',input_3(1), input_3(2), input_3(3), 1)

% Make the cube visible/invisible
invoke(cube_visprop,'SetShow',1); %Cube is not visible (hidden)
invoke(cube_visprop,'SetShow',0); %Cube is visible 

% Set the opacity/transparency of the Cube (255: no transparency; 0: full transparency)
invoke(cube_visprop,'SetRealOpacity',input_3(4), 1)
invoke(cube_bolck_visprop,'SetRealOpacity',input_3(4), 1)

% Change the line thickness of the cube edges
invoke(cube_visprop,'SetRealWidth',input_3(5), 1);
invoke(cube_bolck_visprop,'SetRealWidth',input_3(5), 1);

% Change line type of the cube edges
invoke(cube_visprop,'SetRealLineType',input_3(6), 1);
invoke(cube_bolck_visprop,'SetRealLineType',input_3(6), 1);
