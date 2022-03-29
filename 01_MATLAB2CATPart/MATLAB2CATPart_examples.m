% Designed by: Lorenzo Nicoletti (FTM, Technical University of Munich)
%-------------
% Created on: 10.03.2022
% ------------
% Version: Matlab2020b
%-------------
% Description: In this script there are different section to perform different tasks on a given CATPart
%              Also compare the documentation in the README of this
%              repository.
%              The code becomes more and more compact from example 1 to
%              example 7
% ------------

%% PREPROCESSING: The variables declared in this section are required for the other sections!
% Create a connection with the CATIA Application
catia = actxserver('catia.application');

% The Cube.CATPart must already be opened in CATIA. Check if this is the case
try invoke(get(catia, 'Windows'),'Item','Cube.CATPart')
catch 
    errordlg('BEFORE STARTING, OPEN THE FILE Cube.CATPart','Error');
    return
end

% Remind the User to open Activate the product (only necessary for CATIA settings where the product is not loaded in design mode)
disp('BEFORE STARTING, MAKE SURE THAT Cube.CATPart IS IN DESIGN MODE AND THAT IT IS ACTIVATED')
% If the CATIA tree looks like in the first figure of the README, then the part is activated correctly

% Select all the opened documents
Docs=get(catia,'Documents');

% Select the Cube.CATPart document (This selects the whole document, not the "Part")
Docpart = invoke(Docs,'Item','Cube.CATPart');

% Select the uppermost node of the CATIA tree -> This is the master node of the CATPart
Cube = get(Docpart,'part'); % In the first figure in the README this is the node "Cube_part"

%% Implementation:
%1) Create a screenshot of the Active Window and save it as bmp image
%2) Change the dimensions of the cube in "Cube.CATPart"
%3) Add new formulas and design parameters to "Cube.CATPart"
%4) Change the graphic properties of the cube
%5) Create a cylinder next to the cube
%6) Create a new plane and build a new cube on it
%7) Create a closed sketch with n sides and extrude it


%% 1) Create a screenshot of the Cube.CATPart and save it as bmp image
%     The image will be saved using the basis path where the CATPart file is contained

%There may be more than one window open: make sure that the "Cube.CATPart" is the active one
Windows     = get(catia, 'Windows');                   %Select all available windows
Cube_Window = invoke(Windows,'Item','Cube.CATPart');   %Select the window containing the "Cube.CATPart"
invoke(Cube_Window,'Activate');                        %Activate the "Cube.CATPart" window (if there are more than one opened window, this will shift the view to "Cube.CATPart")

%Get the ActiveViewer object of the object
objview3=get(get(catia,'ActiveWindow'),'ActiveViewer');

% The number denotes the file type (1 to 4)
invoke(objview3,'CaptureToFile', 1, 'Screenshot_cube.bmp')

%% 2) Change the dimensions of the cube in "Cube.CATPart"
%     The dimensions of the cube will be changed directly from this MATLAB
%     script. The desired dimensions can be set with the array "input_2"

input_2 = [100, 100, 100]; %cube dimensions expressed as [Length, Width, Height] -> Unit is the default unit set in CATIA, in my case mm

% Show the name of the selected object using the "Name" property
disp(['The name of the selected object is ', get(Cube,'Name')]);

% Select the Parameter set of the cube 
Parameters = get(Cube, 'Parameters');

% Select the Parameters controlling the size of the cube
Par_matlab{1} = invoke(Parameters,'Item','Cube_length');
Par_matlab{2} = invoke(Parameters,'Item','Cube_width');
Par_matlab{3} = invoke(Parameters,'Item','Cube_height');

% Store the dimensions of the Cube in MATLAB
Cube_dim(1,1) = get(Par_matlab{1},'Value');
Cube_dim(1,2) = get(Par_matlab{2} ,'Value');
Cube_dim(1,3) = get(Par_matlab{3},'Value');

% Set the parameters to the new values:
set(Par_matlab{1},'Value',input_2(1));    %Set the length
set(Par_matlab{2}, 'Value',input_2(2));   %Set the width
set(Par_matlab{3},'Value',input_2(3));    %Set the height

% Store the NEW dimensions of the Cube in MATLAB
Cube_dim(2,1) = get(Par_matlab{1},'Value');
Cube_dim(2,2) = get(Par_matlab{2} ,'Value');
Cube_dim(2,3) = get(Par_matlab{3},'Value');

% Display the canges in cube dimensions
disp(['The dimensions of the cube have been changed from [', num2str(Cube_dim(1,:)), '] to [', num2str(Cube_dim(2,:)),']']);

% Activate the "Update" option in CATIA to update the cube
invoke(Cube,'update');

%% 3) Add new formulas and design parameters to "Cube.CATPart"
%     Create a new parameter "New_par" and connect it to the parameters described in 2) with a formula.
%     Subsequently, update the parameter presented in 2) with new values, let CATIA recalculate the new
%     value of "New_par" and restore the result in MATLAB

% Assign the set of Relation (formulas) implemented for "Cube_part"
Relations = get(Cube, 'Relations');

% Retireve the Parameter set of the cube
Parameters = get(Cube, 'Parameters');

% Now create a new parameter of the type length. If desired, the parameter name can be assigned in the empty field following 'CreateDimension'
New_par     = invoke(Parameters,'CreateDimension','','LENGTH',120); 

% Now that the new parameter is created, connect it with a formula with the other parameters
invoke(Relations, 'CreateFormula', '', '', New_par, 'Cube_length+Cube_height+Cube_width'); %The two empty input are for the "Name of the formula" and the "Comment to the formula" respectively

% Store the actual value of "New_Par"
New_parvalue(1) = get(New_par, 'Value');

% Now change the values of the other parameters (double them):
set(invoke(Parameters,'Item','Cube_length'), 'Value', get(invoke(Parameters,'Item','Cube_length'), 'Value')*0.5 );
set(invoke(Parameters,'Item','Cube_width') , 'Value', get(invoke(Parameters,'Item','Cube_width'),  'Value')*0.5 ); 
set(invoke(Parameters,'Item','Cube_height'), 'Value', get(invoke(Parameters,'Item','Cube_height'), 'Value')*0.5 );
invoke(Cube,'update') 

% And without retireve back the new "New_Parameter" which has been calculated from CATIA
New_parvalue(2) = get(New_par, 'Value');

% Display the result
disp(['The dimensions of the New Parameter have been changed from ', num2str(New_parvalue(1)), ' to ', num2str(New_parvalue(2))]);

%% 4) Change the graphic properties of "Cube.CATPart"
%     This section shows some properties to control the appearance of the cube

input_4      = [0, 101, 189, ...% The RGB triple with values comprised between 0 and 255.
                255, ...        % The opacity of the Cube, comprised between 0 and 255.
                4, ...          % Line width: The value ranges from 1 to 63. Each index is a line type customizable in the page Tools/Options/General/Display/Line Type.
                4];             % Line type: The value ranges from 1 to 63. Each index is a thickness customizable in the page Tools/Options/General/Display/thickness.

% Assign the Body and Block nodes of the CATPart to two distinct MATLAB variables
Bodies     = get(Cube, 'Bodies');                                   %Entire set of the Bodies which belong to "Cube_part"
Cube_body  = invoke(Bodies, 'Item','Cube_body');                    %Assign the "Cube_body" node (there is only one but we use this line to show the 'Item' property)
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

% Update the cube
invoke(Cube,'update')

%% 5) Create a cylinder next to the cube
%     The cylinder will be created at the starting from the same basis
%     plane of the cube. The position and dimensions of the cylinder can be
%     set with the variables "Cylinder_center", "Cylinder_radius", and "Cylinder_height"

input_5 = [0,0, ...    %Position of the cylinder center in the XY plane: [x coordinate, y coordinate] -> Unit is the default unit set in CATIA, in my case mm
           50, ...     %Radius of the cylinder -> Unit is the default unit set in CATIA, in my case mm
           500];       %Height of the cylinder -> Unit is the default unit set in CATIA, in my case mm

% Add a new body to the "Cube_part"
New_body = invoke(get(Cube, 'Bodies'),'Add');

% Select the origin elements of the "Cube_Part"
origin_elements = get(Cube, 'OriginElements' );

% Select the plane where the sketch is going to be created
reference = get(origin_elements, 'PlaneXY');

% Select the sketches set of the "New_body" (at the moment it is empty)
Sektches = get(New_body,'Sketches');

% Add a new Sketch to "New_body"
New_sketch=invoke(Sektches, 'Add', reference);

% Set the sketch as "in work object"
set(Cube,'InWorkObject',New_sketch);

% Inside the new sketch select the object "Factory_2D" which allows to create 2D elements (points, lines) within a sketch
Factory_2D = invoke(New_sketch, 'OpenEdition');

% Create a circle sketch. 
invoke (Factory_2D, 'CreateClosedCircle', input_5(1),input_5(2),input_5(3));

% Set the "New_body" as "in work object"
set(Cube,'InWorkObject',New_body);

% Get the 3D shape factory, which is required to create Pads, Extrusions etc.
Body_shapefactory = get(Cube,'ShapeFactory');

% With the selected "Body_shapefactory" extrude the cricle sketch, thus creating a cylinder
Cylinder_pad = invoke(Body_shapefactory, 'AddNewPad', New_sketch, input_5(4));
set(Cylinder_pad,'IsSymmetric',1);

% Without an update the Cylinder won't be visible
invoke(Cube,'update');

%% 6) Create a new plane and build a new cube on it
%     First we will create a new plane, parallel to the XY plane. Then we
%     will create a new cube by extruding a square sketch. The vertexes of the square
%     sketch are referred to the origin of the axes and listed in
%     "Cube_vertex".
%     If the position of the plane was defined with a parameter (see the
%     examples in 1 and 2) it would be possible to shift the object built
%     on the plane by tuning the parameter from MATLAB

input_6      = [-100, 100,... %X and Y coordinates of the first vertex of the square
                100, 100,...  %X and Y coordinates of the second vertex of the square
                100, -100,... %X and Y coordinates of the third vertex of the square
                -100,-100,... %X and Y coordinates of the fourth vertex of the square
                300, ...      %Offset between the XY plane and the new plane      
                100];         %Height of the cube

% Assign the "Cube_body" node (there is only one but we use this line to show the 'Item' property)
Cube_body = invoke(get(Cube, 'Bodies') , 'Item' , 'Cube_body');       

% Get the Geometrical Sets and the Shape factory variables of the "Cube_part"
Hybridbodies    = get(Cube, 'HybridBodies');          % Represents all the geometrical sets of the object
Hybrid_shapefac = get(Cube, 'HybridShapeFactory');    % Represents the object to add/delete/shift hybrid shapes (e.g. plane, points etc.)

% Add a new geometrical set, this is where the new plane will be added
Hybridbody   = invoke(Hybridbodies,'Add');  % This is the newly added geometrical set
invoke(Cube,'update');                      % Update the geometrical set

% Select a plane parallel to the plane we want to build the new cube: We choose the XY plane of "Cube_part"
Basis_plane = get(get(Cube, 'OriginElements'),'PlaneXY');

% Derive a reference to the Basis plane
Reference_plane = invoke(Cube,'CreateReferenceFromObject',Basis_plane);

% Create a plane parallel to "Basis plane" and with the offset given in input_6
New_plane = invoke(Hybrid_shapefac, 'AddNewPlaneOffset' , Reference_plane , input_6(9) , 1);

% Position the new plane in the geometrical set "Hybridbody"
invoke(Hybridbody,'AppendHybridShape',New_plane)
invoke(Cube,'update');                          % Update the geometrical set

% Set the Plane as in Work object
set(Cube,'InWorkObject',New_plane);

% Create a variable to connect to all the hybridshapes (planes, line etc) contained in the geometrical set "Hybridbody"
hshapes = get(Hybridbody,'HybridShapes');             

% Create a reference from the newly create plane "New_plane"
Reference_plane_new = invoke(hshapes,'Item',get(New_plane,'Name'));

% Select all the Sketches contained in the "Cube_body" node
Sketches = get(Cube_body,'Sketches');

% On the "New_plane" create a new sketch
New_sketch = invoke(Sketches,'Add',Reference_plane_new);

% Create the four extreme point of the square sketch
invoke(invoke(New_sketch,'OpenEdition') , 'CreatePoint', input_6(1), input_6(2))
invoke(invoke(New_sketch,'OpenEdition') , 'CreatePoint', input_6(3), input_6(4))
invoke(invoke(New_sketch,'OpenEdition') , 'CreatePoint', input_6(5), input_6(6))
invoke(invoke(New_sketch,'OpenEdition') , 'CreatePoint', input_6(7), input_6(8))

% Connect the points with lines, thus creating a closed Sketch
invoke(invoke(New_sketch,'OpenEdition'), 'CreateLine', input_6(1), input_6(2), input_6(3), input_6(4))
invoke(invoke(New_sketch,'OpenEdition'), 'CreateLine', input_6(3), input_6(4), input_6(5), input_6(6))
invoke(invoke(New_sketch,'OpenEdition'), 'CreateLine', input_6(5), input_6(6), input_6(7), input_6(8))
invoke(invoke(New_sketch,'OpenEdition'), 'CreateLine', input_6(7), input_6(8), input_6(1), input_6(2))

% Terminate the Edition part of the sketch
invoke(New_sketch,'CloseEdition');

% Now we are going to extrude the sketch: set the "Cube_body" node as "in work object":
set(Cube,'InWorkObject',Cube_body);

% Get the 3D shape factory, which is required to create Pads, Extrusions etc.
Body_shapefactory = get(Cube,'ShapeFactory');

% Extrude the created sketch simmetricaly:
Cube_pad = invoke(Body_shapefactory, 'AddNewPad', New_sketch, input_6(10));
set(Cube_pad,'IsSymmetric',1);                                      

% Set the node "Cube_part" as "in work object"
set(Cube,'InWorkObject',Cube);
invoke(Cube,'update');                       % Update the Cube

%% 7) Create a closed sketch with n sides and extrude it
%     The number of sides can be defined in input_7. After creating the
%     sketch it will be extruded to create a pad. This excercise shows how
%     MATLAB can be used to define shapes and sketches (by means of
%     for-loops) in CATIA

input_7 = [3   ... % Number of sides of the sketch (minimum 3)
           500 ... % All the points of the sketch lay on a circle. This entry is the radius of the circle
           100];   % Height of the extrusion

%Ensure the number of sides is not lower than 3
if input_7(1)<3; errordlg('THE NUMBER OF SIDES FOR THE POINT   7) MUST BE BIGGER THAN 2','Error');return; end

% Select the plane where the sketch is going to be created
reference = get(get(Cube, 'OriginElements' ), 'PlaneXY');

%Add a new Sketch to "New_body"
New_sketch = invoke(get(invoke(get(Cube, 'Bodies'),'Add'),'Sketches') , 'Add', reference);

% Retrieve the Factory 2D object to create points and line within sketches
Factory_2D = invoke(New_sketch, 'OpenEdition');

% Angle to define the position of the sketch vertexes (we will use polar coordinates)
alpha = 0 : 2*pi/input_7(1) : 2*pi*(1-1/input_7(1));

% In this for loop the vertex are disposed in the sketch and then connected with lines
for i= 1:numel(alpha)   
    invoke(Factory_2D,'CreatePoint',input_7(2)*cos(alpha(i)),input_7(2)*sin(alpha(i)));
    if i < numel(alpha)
        invoke(Factory_2D,'CreateLine',input_7(2)*cos(alpha(i)),input_7(2)*sin(alpha(i)),input_7(2)*cos(alpha(i+1)),input_7(2)*sin(alpha(i+1)));
    else
        invoke(Factory_2D,'CreateLine',input_7(2)*cos(alpha(end)),input_7(2)*sin(alpha(end)),input_7(2)*cos(alpha(1)),input_7(2)*sin(alpha(1)));
    end
end

% Once the sketch is done, it is possible to extrude it, thus creatinf a new pad
invoke(get(Cube,'ShapeFactory'), 'AddNewPad', New_sketch, input_7(3));

%Update the cube to show the results
invoke(Cube,'update');