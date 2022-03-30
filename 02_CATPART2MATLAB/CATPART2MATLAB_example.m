% Designed by: Lorenzo Nicoletti
%-------------
% Created on:25.03.2022
% ------------
% Version: Matlab2020b
%-------------
% Description: This script is not intended to be a library of 3D plot
%              function. The scope of this script is to show that by combining STL data
%              and simple MATLAB functions (such as patch, surf, fill3) it is possible
%              to represent complex objects (in this case an electric vehicle powertrain)
%              For more information to this regard also check the readme of this repository
%              In this scription the following convetion is used when referring to the X,Y,Z directions
%              X: Parallel to the vehicle's driving direction (the positive X-axis points against the driving direction)
%              Y: Parallel to the vehicle's width
%              Z: Parallel to the vehicle's height
% ------------

%% Implementation
%1) Inputs/Dimensions used for the plot
%2) Plot the rims
%3) Plot the tires
%4) Plot the battery
%5) Plot the drive unit
%6) Create a dynamic plot of the wheel using stl_file.rotation:

%% 1) Inputs/Dimensions used for the plot
clear

% Vehicle dimensions 
vehicle_width     = 1700;                       %Vehicle width (W103 according to the SAE J1100) in mm
vehicle_wheelbase = 2800;                       %Vehicle width (L101 according to the SAE J1100) in mm

% Battery dimensions
battery_width  = vehicle_width*0.6;             %Battery housing width in mm -> Modeled as 60% of the vehicle width
battery_length = vehicle_wheelbase*0.6;         %Battery housing length in mm -> Modeled as 60% of the vehicle wheelbase
battery_height = 120;                           %Battery housing heigth in mm -> Realistic value 
battery_pos    = [vehicle_wheelbase/2,0,-100];  %Position of the battery housing
num_cell       = [30,3];                        %[Number of cells along X, Number of cells along Y]

% Drive unit dimensions:
machine_radius = 100;                           %Radius of the electric machine in mm
machine_length = 250;                           %Length of the electric machine in mm
gearbox_length = 100;                           %Length of the gearbox in mm
drive_shaft_diameter = 20;                      %Diameter of the driving shafts

% Create the figure
figure('Name','Vehicle_plot'); hold on

%% 2) Plot the rims
% In this step we use own-defined stl_file class. Create 4 objects, one for each rim
RIM_FL = stl_file('Rim.stl'); RIM_FR = stl_file('Rim.stl');
RIM_RL = stl_file('Rim.stl'); RIM_RR = stl_file('Rim.stl');
%Attention: the stl_file is a handle class (like a MATLAB GUI)! Meaning that the code
%RIM.FR.mirror('XZ') returns a mirrored version of RIM_FR but also changes RIM_FR!

% Secondly, the rims on the right side have to be mirrored with respect to the XZ plane
RIM_FR.mirror('XZ');
RIM_RR.mirror('XZ');

% Thirdly, all the rims have to be translated
RIM_FL.translate(0, -vehicle_width/2, 0);
RIM_FR.translate(0, +vehicle_width/2, 0);
RIM_RL.translate(vehicle_wheelbase, -vehicle_width/2, 0);
RIM_RR.translate(vehicle_wheelbase, +vehicle_width/2, 0);

% Finally we can plot
RIM_FL.plot_stl('FaceColor',[211,211,211]/255, 'EdgeColor',[0,0,0],'EdgeAlpha',0.2);
RIM_FR.plot_stl('FaceColor',[211,211,211]/255, 'EdgeColor',[0,0,0],'EdgeAlpha',0.2);
RIM_RL.plot_stl('FaceColor',[211,211,211]/255, 'EdgeColor',[0,0,0],'EdgeAlpha',0.2);
RIM_RR.plot_stl('FaceColor',[211,211,211]/255, 'EdgeColor',[0,0,0],'EdgeAlpha',0.2);

%% 3) Plot the tires
% In this step we use own-defined stl_file class. Create 4 objects, one for each tire
TIRE_FL = stl_file('Tire.stl'); TIRE_FR = stl_file('Tire.stl');
TIRE_RL = stl_file('Tire.stl'); TIRE_RR = stl_file('Tire.stl');

%Differently from the rims, the tires are loaded with a different orientation and need to be corrected:
TIRE_FL.rotate('Z',pi/2); TIRE_FR.rotate('Z',pi/2);
TIRE_RL.rotate('Z',pi/2); TIRE_RR.rotate('Z',pi/2);
% Attention the method "rotate" rotates using the MATLAB CoSy (0,0,0) as origin

% Also the tire need to be translated:
% The origin of the tire reference system is positioned at half of the tire
% width (which is 265 mm). This has to be considered when positioning the tires along Y
TIRE_FL.translate(0, -vehicle_width/2 + 265*0.5, 0);
TIRE_FR.translate(0, +vehicle_width/2 -265*0.5, 0);
TIRE_RL.translate(vehicle_wheelbase, -vehicle_width/2 + 265*0.5, 0);
TIRE_RR.translate(vehicle_wheelbase, +vehicle_width/2 -265*0.5, 0);

% Finally the tires need to be positioned in the vehicle:
TIRE_FL.plot_stl('FaceColor',[0,0,0], 'EdgeColor','none','FaceAlpha',0.5);
TIRE_FR.plot_stl('FaceColor',[0,0,0], 'EdgeColor','none','FaceAlpha',0.5);
TIRE_RL.plot_stl('FaceColor',[0,0,0], 'EdgeColor','none','FaceAlpha',0.5);
TIRE_RR.plot_stl('FaceColor',[0,0,0], 'EdgeColor','none','FaceAlpha',0.5);

% Additionally for the front axle we can also show the steered tires.
% Reload the STL file thus creating two more tires:
TIRE_FL_rot = stl_file('Tire.stl'); TIRE_FL_rot.rotate('Z',pi/2);
TIRE_FR_rot = stl_file('Tire.stl'); TIRE_FR_rot.rotate('Z',pi/2);

% Now rotate the tires with a steering angle of pi/6 
TIRE_FL_rot.rotate('Z',pi/6);
TIRE_FR_rot.rotate('Z',pi/6);

% Translate and plot:
TIRE_FL_rot.translate(0,-vehicle_width/2 + 265*0.5,0);
TIRE_FR_rot.translate(0,+vehicle_width/2 - 265*0.5,0);
TIRE_FL_rot.plot_stl('FaceColor',[1,0,0], 'EdgeColor',[1,1,1],'FaceAlpha',0.5,'EdgeAlpha',0.2);
TIRE_FR_rot.plot_stl('FaceColor',[1,0,0], 'EdgeColor',[1,1,1],'FaceAlpha',0.5,'EdgeAlpha',0.2);

%% 4) Plot the battery
% In this step we want to show, that for simple object it is not necessary
% to use STL data. It is possible to create 3D objects with surf, patch etc.
% Here we will only used the own-defined functions "plot_cylinder" and "plot_cube"

% Plot the battery housing which is simplified as a prismatic block
plot_cube(battery_pos,[battery_length,battery_width,battery_height],[211,211,211]/255,0.5)

% Estimates the dimensions of the cells that fit in the cube based on the
% given number of cells along X and Y. We suppose that the cells can only
% use 80% of the battery length and width
cell_dim = [battery_length*0.8/num_cell(1), battery_width*0.8/num_cell(2), battery_height*0.8];

% Estimate the space between the cells
spacing  = [battery_length*0.2/(num_cell(1)+1), battery_width*0.2/(num_cell(2)+1), battery_height*0.2/2];

% Start plotting the cells. Define the starting point which is the foremost
% rightmost angle of the battery housing
start_point = [battery_pos(1)-battery_length(1)*0.5, battery_width(1)*0.5, battery_pos(3)];

% Plot the cells using a for loop
for i = 1 : num_cell(1)
    
    % Derive the position of the i-th cell along X
    pos_x = start_point(1) + spacing(1) + cell_dim(1)/2 + spacing(1)*(i-1) + cell_dim(1)*(i-1);
    
    for ii = 1 : num_cell(2)
        % Derive the corresponding Y and Z positions
        pos_y = start_point(2) -spacing(2) - cell_dim(2)/2 - spacing(2)*(ii-1) - cell_dim(2)*(ii-1);
        pos_z = start_point(3);
        
        % Plot the cells
        plot_cube([pos_x,pos_y,pos_z],cell_dim,[227,114,34]./255,1) 
    end
end
% Of course it would also be possible to plot cylindrical cells using the
% function plto_cylinder (also contained in this repository)

%% 5) Plot the drive unit
% In this step we want to show, that for simple object it is not necessary
% to use STL data. It is possible to create 3D objects with surf, patch etc.
% Here we will only used the own-defined functions "plot_cylinder" and "plot_cube"

%Plot the machine and gearbox at the front axle (let's suppose we have a coaxial machine whith coaxial gearbox)
plot_cylinder(machine_radius,machine_length,[0,0,0],'Y','FaceColor',[162,173,0]/255,'EdgeColor','none','FaceAlpha',0.8);
plot_cylinder(machine_radius,gearbox_length,[0,(machine_length+gearbox_length)/2,0],'Y','FaceColor',[0,101,189]/255,'EdgeColor','none','FaceAlpha',0.8);

%Plot the machine and gearbox at the front axle (let's suppose we have a coaxial machine whith coaxial gearbox)
plot_cylinder(machine_radius,machine_length,[vehicle_wheelbase,0,0],'Y','FaceColor',[162,173,0]/255,'EdgeColor','none','FaceAlpha',0.8);
plot_cylinder(machine_radius,gearbox_length,[vehicle_wheelbase,(machine_length+gearbox_length)/2,0],'Y','FaceColor',[0,101,189]/255,'EdgeColor','none','FaceAlpha',0.8);

%Plot the driving shafts at the two axles:
plot_cylinder(drive_shaft_diameter,vehicle_width-30,[0,0,0],'Y','FaceColor',[0,0,0]);
plot_cylinder(drive_shaft_diameter,vehicle_width-30,[vehicle_wheelbase,0,0],'Y','FaceColor',[0,0,0]);


%% 6) Create a dynamic plot of the wheel using stl_file.rotation: 
% As final example we show how the rotation matrix can be used to create
% dynamic plots, in this case of the rim.

% Create a new figure
figure('Name','Wheel_dynamic');

% Load a new rim, in this example the positioning is not important
RIM = stl_file('Rim.stl');


% Iterate for 100 steps
for i = 1: 100
    
    % For each step rotate the rim by 2*pi/100 along the Y axis
    RIM.rotate('Y',-2*pi/100) 
    
    % Plot the rim
    RIM.plot_stl('FaceColor',[211,211,211]/255, 'EdgeColor',[0,0,0],'EdgeAlpha',0.2);
    drawnow
    
end