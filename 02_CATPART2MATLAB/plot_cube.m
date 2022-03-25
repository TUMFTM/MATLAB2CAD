function plot_cube(origin,dim,color,falpha)
% Designed by: Lorenzo Nicoletti
%-------------
% Created on: 07.01.2022
% ------------
% Version: Matlab2020b
%-------------
% Description: This function plots the prismatic object. It is based on the
%              "voxel" function created by Suresh Joel.
% ------------
% Sources: Suresh Joel (2020). Voxel (https://www.mathworks.com/matlabcentral/fileexchange/3280-voxel), MATLAB Central File Exchange. Retrieved July 16, 2020.
% ------------
% Input: origin: [3x1 double] Position of the cube's center (defined at the COG of the cube) -> [X,Y,Z]
%        dim:    [3x1 double] Dimensions of the cube -> [dim_X,dim_Y,dim_Z]
%        color:  [3x1 double] Color of the cube as RGB triple
%        falpha: [double]     Transparency of the cube: values from 0 to 1
% ------------
%% Implementation
%Define all the position of the points of the cube
x=[origin(1)+[-dim(1)/2 -dim(1)/2 -dim(1)/2 -dim(1)/2 dim(1)/2 dim(1)/2 dim(1)/2 dim(1)/2]; ...
   origin(2)+[-dim(2)/2 -dim(2)/2 dim(2)/2 dim(2)/2 -dim(2)/2 -dim(2)/2 dim(2)/2 dim(2)/2]; ...
   origin(3)+[-dim(3)/2 dim(3)/2 -dim(3)/2 dim(3)/2 -dim(3)/2 dim(3)/2 -dim(3)/2 dim(3)/2]]';
%The origin (reference for plotting the cube) will be positioned at the cube's COG

hold on

%Plot the six faces of the cube
for n=1:3
    if n==3
        x=sortrows(x,[n,1]);
    else
        x=sortrows(x,[n n+1]);
    end
    temp=x(3,:);
    x(3,:)=x(4,:);
    x(4,:)=temp;
    p1 = patch(x(1:4,1),x(1:4,2),x(1:4,3),color);
    p1.FaceAlpha = falpha;
    temp=x(7,:);
    x(7,:)=x(8,:);
    x(8,:)=temp;
    p2= patch(x(5:8,1),x(5:8,2),x(5:8,3),color);
    p2.FaceAlpha = falpha;
end
end