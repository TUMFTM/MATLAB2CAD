classdef stl_file < handle
    %stl_file: This class documents a series of basic methods for shifting,
    %mirroring and rotating .stl objects.
    
    properties
        Cv
        Pts
        Plot_handle
    end
    
    methods
        
        %% Static method for class creation
        function obj = stl_file(stl_file_link)
            % Create the class and retrieve the STL file
            if ~isstring(stl_file_link) && ~ischar(stl_file_link)
                error('To create the class you have to assign the link of the STL file as STRING or CHAR');
            end

            % Read the STL data
            try
                stl_data = stlread(stl_file_link);
            catch
                error('The given path does not contain any STL file');
            end

            % Assign the Connectivity list and points to the class object
            obj.Cv   = stl_data.ConnectivityList; % [n x 3 Matrix]: Documents which points are connected to each other
            obj.Pts  = stl_data.Points;           % [n x 3 Matrix]: Coordinates of the STL points along the x, y and z direction. Expressed as [X,Y,Z]
        end
        
        %% Method for object translation
        function obj = translate(obj, pos_x, pos_y, pos_z)            
            % Description: Translate the object (the reference is set to the CoSY of the original STL file)
            % Function call example: STL = stl_file(_Link_stl_file_)
            %                        STL.translate(100,200,300)  -> The object will be translated in X of 100 mm, in Y by 200 mm and in Z by 300 mm
            % Further remarks: The unit for the translation (mm, inches etc.) depends on the set unit in the original stl file
                obj.Pts(:,1) = obj.Pts(:,1) + pos_x;
                obj.Pts(:,2) = obj.Pts(:,2) + pos_y;
                obj.Pts(:,3) = obj.Pts(:,3) + pos_z;
        end
        
        %% Method for object scaling
        function obj = scale(obj, scale_x, scale_y, scale_z)
            % Description: Scale the dimensions of the object along the X, Y and Z directions
            % Function call example: STL = stl_file(_Link_stl_file_)
            %                        STL.scale(2,2,3)
            % Further examples: scale_x = 1 -> The dimensions do not change along X
            %                   scale_x < 1 -> The dimensions get smaller along X
            %                   scale_x > 1 -> The dimensions get bigger along X
                if any([scale_x, scale_y, scale_z]<0)
                    error('Attention! At least one of the given scalng factors are negative! This will lead not only to a scaling but also to a mirroring of the object! Only positive values are accepeted!')
                end
                
                % Scale the object according to the given scaling factors
                obj.Pts(:,1) = obj.Pts(:,1)*scale_x;
                obj.Pts(:,2) = obj.Pts(:,1)*scale_y;
                obj.Pts(:,3) = obj.Pts(:,1)*scale_z;
        end
        
        %% Method for object mirroring
        function obj = mirror(obj, mirror_plane)
            % Description: Mirror the position of the STL points according to the selected mirror plane
            % Function call example: STL = stl_file(_Link_stl_file_)
            %                        STL.mirror('XY')
            % Further examples: STL.mirror('XY') -> The points are mirrored on the XY plane
            %                   STL.mirror('YZ') -> The points are mirrored on the YZ plane
            %                   STL.mirror('XZ') -> The points are mirrored on the XZ plane              
                switch mirror_plane
                    case 'XY'
                        % Mirror the object on the XY plane
                        obj.Pts(:,3) = -obj.Pts(:,3);
                    case 'YZ'
                        % Mirror the object on the YZ plane
                        obj.Pts(:,1) = -obj.Pts(:,1);
                    case 'XZ'
                        % Mirror the object on the XZ plane
                        obj.Pts(:,2) = -obj.Pts(:,2);
                end
        end
        
        %% Method for object rotation
        function obj = rotate(obj, axis, rot_angle)
            % Description: Rotate the object according to the given axis and angle (in radiant!)
            % Function call example: STL = stl_file(_Link_stl_file_)
            %                        STL.rotate('X',pi)
            % Further examples: STL.rotate('Y',pi/2) -> Rotate on the Y axis for 90 degrees 
            %                   STL.rotate('Z',pi/4) -> Rotate on the Z axis for 90 degrees 
            
            switch axis
                case 'X'
                    rot_mat      = [1, 0 , 0; 0, cos(rot_angle), -sin(rot_angle); 0, sin(rot_angle), cos(rot_angle)]; %Rotation matrix along Z
                    
                case 'Y'
                    rot_mat      = [cos(rot_angle), 0, sin(rot_angle); 0, 1, 0; -sin(rot_angle), 0, cos(rot_angle)]; %Rotation matrix along Z
                
                case 'Z'
                    rot_mat      = [cos(rot_angle), sin(rot_angle), 0; -sin(rot_angle), cos(rot_angle), 0; 0, 0, 1]; %Rotation matrix along Z
            end
            
            %Rotate the points of the .stl object:
            obj.Pts = (rot_mat*obj.Pts')';
        end
        
        %% Method for object plot
        function obj = plot_stl(obj, varargin)
            % Description: Plots the STL. The number of inputs of this method is not fixed! The inputs can be declared and given just like in the function trisurf (see the trisurf documentation for further infos)
            % Function call example: STL = stl_file(_Link_stl_file_)
            %                        STL.plot('FaceColor',[1,1,1])
            % Further examples: STL.plot('FaceColor',[1,1,1],'FaceAlpha',0.1)
            %                   STL.plot('FaceColor',[1,1,1],'EdgeColor',[1,1,1])
                
                % Set the view
                view(-45,45);

                % Create a triangulation object from the STL
                stl_tri = triangulation(obj.Cv,obj.Pts);

                % Plot the triangulation object + Error handling
                try
                    stl_tri = trisurf(stl_tri,varargin{:});
                catch
                    error('Error by the input assignement. The method plot_stl must be called following the input structure of the MATLAB function trisurf. For more information to this regard, check the documentation of the trisurf function');
                end
                
                axis equal
                
                % Make figure on top:
                figure(gcf);

                % By appending stl_tri to the variable obj, it is possible
                % to change the graphical properties of the object in a later step.
                obj.Plot_handle = stl_tri;
              
        end
    end
end

