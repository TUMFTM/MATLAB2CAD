# MATLAB2CAD
Developed by: Lorenzo Nicoletti, Institute of Automotive Technology, Technical University of Munich, Boltzmannstr. 15, 85748 Garching, Germany

This repository contains a series of examples to create a direct connection between MATLAB and CATIA V5 **without having to use Excel**. This direct connection enables to update CATIA models from MATLAB and also to retrieve calculated data from CATIA to MATLAB

**Let me know in the comments if you have feedbacks or further examples you would like to see! I will try to add them!**

# Background and Motivation
For the ones who are not very confident with CATIA, the basic language to program in CATIA is VBA. Using the VBA editor (Tools/Macro/Visual Basic Editor) it is possible to automatize a broad set of tasks by building VBA Macros. VBA has a direct connection to CATIA but its editor is not one of the best programming environments and, if complex models are required, these models are usually implemented in other programs. One programming language that keeps gaining momentum among engineers is MATLAB and there are many cases where MATLAB-implemented models are are connected with CATIA to visualize the results. In this cases, CATIA is often used exclusevly for visualization purposes. We will denote this case as a MATLAB2CAD connection.

When a MATLAB2CAD connection is required, the most common solution is to create a parametric model in CATIA and connect it with an Excel table. MATLAB can then calculate the required parameters and store them in the Excel table. Finally, once the Excel table is reclosed and saved, CATIA will notice that the entries of the table have been changed and will update. This process can take - depedning on the CATIA model complexity - several minutes and requires the usage of three different programs (MATLAB, CATIA, and Excel). Therefore the question arises:
**is it possible to create a MATLAB2CAD connection without having to use Excel?** The answer is, of course, yes.

In this repository, we will see: 
- 1) How to update parametric CATParts from MATLAB
- 2) How to create new objects (Sketches, Pads) in CATIA by using exclusively MATLAB code
- 3) How to plot object created in CATIA in MATLAB (we denote this case as CATPART2MATLAB connection)
- 4) How to control and update parametric CATProducts from MATLAB (we denote this case as CATPRODUCT2MATLAB connection)

# How can I implement different, more complex automatization steps for a MATLAB2CATPART connection?
Probabily one of the most interesting part of this repository is the number 2) of the following list. In this repository we only show how very simple object creation processes in CATIA can be automatized in MATLAB. If you want to automatize more complex design process and you have a basic knowledge of VBA, you can follow these steps:

- a) First conduct the set of manual tasks which you want to automatize in CATIA (example create a new sketch, pad, etc.)
- b) While you are doing this, activate the VBA macro recorder (More information to this regard [HERE](https://www.youtube.com/watch?v=kKFdi-owlXM)).
- c) Once you are done you can stop the recorder
- d) In the VBA editor, you will see that most of the tasks you have conducted (sadly some tasks are not recored by default) will have been translated in VBA code.
- e) Now you can translate this code in MATLAB and relauch it from MATLAB to reproduce the same tasks in an automatize way.

The last step (translating VBA in MATLAB code) may seem challenging. On the contrary, it is a quite intuitive task. The scope of this repository is to show how most of the basis VBA tasks can be translated in MATLAB by using the commads "get", "invoke", and "set".

# MATLAB2CATPart
As example a cube (named Cube.CATPart) is given. The cube is built as parametrized CATIA models (More information regarding how to create a parametrized CATIA model can be found [HERE](https://grabcad.com/tutorials/parametric-design-in-catia-v5)) and its dimensions are controlled by the three parameters _Cube_length_, _Cube_width_, and _Cube_height_. With the three parameters it is possible to change the cube dimensions. In the example shown in this section, we are going to see how to programmatically change the cube dimension with MATLAB. 
More examples applied on the Cube.CATPart file are documented in [MATLAB2CATPart_examples.m](../01_MATLAB2CATPart/MATLAB2CATPart_examples.m).

<p align="center">
<img src="/04_Pictures/Figure_1.png?raw=true" alt="The cube object which will be used as an example for this section"/>
</p>

In the following paragraphs, the MATLAB code is showed next to the corresponding VBA code: this helps understanding how the VBA code can be translated in MATLAB. First of all, MATLAB has to create a connection with CATIA. This is achieved as follows:
```
catia = actxserver('catia.application');                VBA Code: Not required for this step
```
The variable ```catia``` represents a connection with the catia application. To select the open CATIA windows, the following line has to be added:
```
Docs = get(catia,'Documents');                          VBA Code: Set Docs = CATIA.Documents
```
With this line, MATLAB assigns to the variable ```Docs``` all the opened windows in CATIA. It can be imagined, that the variable Docs contains all opened CATIA documents (CATParts, CATProducts, etc.). You can check how many Documents are opened by using the _count_ property:
```
Opened_Docs = get(Docs,count);                          VBA CODE: Opened_Docs = Docs.count
```
Since the variable Docs contains ALL the opened documents, to change the cube properties we have to select the Cube.CATPart document. For this scope we can use the _Item_ property combined with the name of the CAD- Document:
```
Docpart = invoke(Docs,'Item','Cube.CATPart');           VBA CODE: Set Docpart = Docs.Item("Cube.CATPart")          
```
```Docpart``` selects the whole window of the Cube.CATPart document. To select the Part (the node denoted as _Cube_part_ in the figure) another command is required:
```
Cube = get(Docpart,'part');                             VBA CODE: Set Cube = Docpart.Part
```
Now the variable ```Cube``` represents a direct connection to the node _Cube_part_. We can use this variable to access the _Cube_part_ properties and to change them. For example, if we want to change the Length of the cube, we first have to select the set of parameters:
```
Parameters = get(Cube, 'Parameters');                   VBA CODE: Set Parameters = Cube.Parameters
```
The variable ```Parameters``` contains all the Parameters of ```Cube```. This include the parameters _Cube_length_, _Cube_width_, and _Cube_height_ (visible in the CATIA tree) as well as a set of further parameters which are not visible in the CATIA tree.

Let us suppose that we want to change _Cube_length_. First of all, we have to select from ```Parameters``` the corresponding Parameter _Cube_length_ and assign it to a new variable:
```
Par_length = invoke(Parameters,'Item','Cube_length');   VBA CODE: Set Par_length = Parameters.Item("Cube_length")
```
```Par_length``` now represents a direct connection with the parameter _Cube_length_. We can now retrieve the value of _Cube_length_ and save it in another MATLAB variable:
```
Cube_length = get(Par_length,'Value');                  VBA CODE: Cube_length = Par_length.Value
```
Or we can also use the connection contained in ```Par_length``` to change the value of _Cube_length_ from MATLAB:
```
set(Par_length,'Value',200);                            VBA CODE: Par_length.Value = 200
```
At first you may not see any result. This may be caused by the fact that CATIA does not automatically reupdate the model its parameter are changed. Of course there is also a way to solve this problem programmatically:
```
invoke(Cube,'update')                                   VBA CODE: Cube.Update
```
In the first script, you will see a series of example regarding how to create objects, change their appearance, introduce new formulas and parameters, etc. 

# CATPART2MATLAB
It is also possible to invert the process and to export CATPart in MATLAB. Let us suppose that we have a CATPart, in this example a vehicle rim as shown in the figure underneath:

<p align="center">
<img src="/04_Pictures/Figure_2.png?raw=true" alt="The cube object which will be used as an example for this section"/>
</p>

It is possible to export the CATPart to MATLAB. For this scope, the CATPart has to be first saved as STL file, thus generating the file Rim.stl
Once the stl file is saved, it is possible to import it directly in MATLAB. For this scope, the class ```stl_file``` documented in this repository was created:
```
RIM = stl_file('Rim.stl')                    %Import Rim.stl in MATLAB with the class stl_file and assign it to the variable RIM
```
The class offers a set of basis functionalities such as translation, mirroring, rotation, and plot of the STL file. This properties are documented in directly in the class file. Furthermore, an example script which shows how to employ the properties of the ```stl_file``` class is documented in the script [```CATPART2MATLAB_example.m```](../02_CATPART2MATLAB/CATPART2MATLAB_example.m).

Exporting and modifing STL files is not the only way to plot 3D objects in MATLAB. To show the potential of the MATLAB functions, the ```MATLAB2CATPart_examples.m``` also shows hot to plot elementary objects such as cubes and cylinder by solely using MATLAB functions. For this scope, the functions [plot_cube.m](../02_CATPART2MATLAB/plot_cube.m) and [plot_cylinder.m](../02_CATPART2MATLAB/plot_cylinder.m) are created. The script ```MATLAB2CATPart_examples.m``` combines MATLAB function with STL file to visualize a complex assembbly - in this case an electric vehicle powertrain - in MATLAB. As a final result, the script yields the following MATLAB plot:

<p align="center">
<img src="/04_Pictures/Figure_3.png?raw=true" alt="The cube object which will be used as an example for this section"/>
</p>





