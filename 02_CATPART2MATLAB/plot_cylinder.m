function plot_cylinder(radius, height, position, orientation,varargin)
% Designed by: Lorenzo Nicoletti
%-------------
% Created on:25.03.2022
% ------------
% Version: Matlab2020b
%-------------
% Description: This function plots a cylinder in the chosen position and
%              orientation. The dimensions of the cylinder are set by the
%              parameters radius and height
% ------------
% Input: radius: [double] Radius of the cylinder
%        height: [double] Height of the cylinder
%        position [3x1 double array]: position of the cylinder [X, Y, Z]
%        orientation [char]: orientation of the cylinder (i.e. the axle to
%        which the simmetry axle of the cylinder is parallel: 'X', 'Y' or 'Z'
%        varargin: Extra inputs that can be used to change the cylinder
%        appearance. They follow the same structure of the PropertyNames for the function "surf"
% ------------
% Function call example: plot_cylinder(10,100,[1,1,1],'FaceColor',[1,0,0],'FaceAlpha',1)

%% Implementation   
cyl.orientation = orientation;
cyl.height = height;
cyl.radius = radius;
cyl.position = position;

plot_options = varargin;

if isempty(plot_options)
   plot_options{1} = 'FaceColor';
   plot_options{2} =[1,0,0];
end

% Number of points which are used to discretized the circle. It can be
% increased for more "defined-looking" cylinders
definition = 100;

% Based on the orientation (default value or assigned by the user) position the cylinder
switch cyl.orientation
    case 'X' % The simmetry axis of the cylinder is parallel to the X direction
       [cyl.zdata,cyl.ydata,cyl.xdata] = cylinder(cyl.radius,definition);
        cyl.xdata = cyl.xdata*cyl.height; 
        cyl.xdata = cyl.xdata -cyl.height/2;
    case 'Y' % The simmetry axis of the cylinder is parallel to the Y direction
       [cyl.xdata,cyl.zdata,cyl.ydata] = cylinder(cyl.radius,definition);
        cyl.ydata = cyl.ydata * cyl.height; 
        cyl.ydata = cyl.ydata - cyl.height/2;
    case 'Z' % The simmetry axis of the cylinder is parallel to the Z direction
       [cyl.xdata,cyl.ydata,cyl.zdata] = cylinder(cyl.radius,definition);
        cyl.zdata = cyl.zdata*cyl.height; 
        cyl.zdata = cyl.zdata-cyl.height/2;
    otherwise
        sprintf('The assigned orientation is wrong: The possiblities are:\n''X'': Cylinder axle parallel to X Axis\n''Y'': Cylinder axle parallel to Y Axis\n''Z'': Cylinder axle parallel to Z Axis')
        return
end

% Translate the cylinder center as desired
cyl.xdata = cyl.xdata + cyl.position(1);
cyl.ydata = cyl.ydata + cyl.position(2);
cyl.zdata = cyl.zdata + cyl.position(3);

%Plot the cylinder considering the inputs
hold on
S = surf(cyl.xdata,cyl.ydata,cyl.zdata,plot_options{:});
F1 = fill3(cyl.xdata(1,:),cyl.ydata(1,:),cyl.zdata(1,:),S.FaceColor);
F2 = fill3(cyl.xdata(2,:),cyl.ydata(2,:),cyl.zdata(2,:),S.FaceColor);

% Set the main proprieties of the fill surfaces like the surf surface
% For some reason it is not possible to assign the graphical properties
% with the same calls used for the function surf
F1.FaceAlpha = S.FaceAlpha; F2.FaceAlpha = S.FaceAlpha;
F1.EdgeColor = S.EdgeColor; F2.EdgeColor = S.EdgeColor; 

% Set the axis and view of the plot
axis equal
view(-35,45)
end