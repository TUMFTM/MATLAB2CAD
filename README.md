# MATLAB2CAD
Developed by: Lorenzo Nicoletti, Institute of Automotive Technology, Technical University of Munich, Boltzmannstr. 15, 85748 Garching, Germany

Used MATLAB Version: MATLAB R2020b
Used CATIA Version: CATIA V5 6-R2018

This repository shows how to create a direct connection between MATLAB and CATIA **without having to use Excel**. This connection enables to update CATIA models from MATLAB and to plot CATParts in MATLAB.

**Let me know in the comments if you have feedbacks or further examples you would like to see! I will try to add them!**

# Background and Motivation
The basic language to program in CATIA is VBA. Using the VBA editor (Tools/Macro/Visual Basic Editor) it is possible to automatize a broad set of tasks by building VBA Macros. VBA has a direct connection to CATIA but its editor is not one of the best programming environments and, if complex models are required, these models are usually implemented in other programs. One programming language that keeps gaining momentum among engineers is MATLAB and there are many cases where MATLAB-implemented models are connected with CATIA to visualize the results. In these cases, CATIA is often used exclusively for visualization purposes. We will denote this case as a MATLAB2CAD connection.

the most common solution to implement a MATLAB2CAd connection is to create a parametric model in CATIA. Subsequently, the parameters of the CATIA model can be connected with an Excel table, which stores their values. MATLAB can then calculate the required parameters and store them in the Excel table. Finally, once the Excel table is reclosed and saved, CATIA will notice that the entries of the table have been changed and will update. This process can take - depending on the CATIA model complexity - several minutes and requires three different programs (MATLAB, CATIA, and Excel). Therefore the question arises:
**is it possible to create a MATLAB2CAD connection without having to use Excel?** The answer is, of course, yes.

In this repository, we will see: 
- 1) How to update parametric CATParts from MATLAB (we denote this case as MATLAB2CATPART connection)
- 2) How to create new objects (Sketches, Pads) in CATIA by using exclusively MATLAB code
- 3) How to plot CATIA parts in in MATLAB (we denote this case as CATPART2MATLAB connection)
- 4) How to control and update parametric CATProducts from MATLAB (we denote this case as CATPRODUCT2MATLAB connection)

# Outlook for more complex implementations
In this repository we only show how very simple CATIA processes can be automatized in MATLAB. If you want to automatize more complex design steps and you have a basic knowledge of VBA, you can follow these steps:

- a) Activate the VBA macro recorder (More information to this regard [HERE](https://www.youtube.com/watch?v=kKFdi-owlXM)).
- b) Conduct the set of manual tasks which you want to automatize in CATIA (create a sketch, pad, etc.).
- c) Once you are done, stop the recorder.
- d) In the VBA editor you will see that most of your tasks (some tasks are not recorded by default) will have been translated into VBA code.
- e) Now you can translate this code in MATLAB.

Translating VBA into MATLAB code may seem challenging. On the contrary, it is a quite intuitive task. The scope of this repository is to show how VBA code can be translated into MATLAB by using the commands "get", "invoke", and "set".

# MATLAB2CATPART
As an example a cube ([Cube.CATPart](../01_MATLAB2CATPart/Cube.CATPart)) is given. The cube is built as parametrized CATPart (More information regarding how to create a parametrized CATPart [HERE](https://grabcad.com/tutorials/parametric-design-in-catia-v5)) and its dimensions are controlled by three parameters: _Cube_length_, _Cube_width_, and _Cube_height_. In the example shown in this section, we are going to see how to programmatically change the cube dimension with MATLAB. 

<p align="center">
<img src="/04_Pictures/Figure_1.png?raw=true" alt="The cube object which will be used as an example for this section"/>
</p>

In the following paragraphs, the MATLAB code is shown next to the corresponding VBA code: this helps understanding how the VBA code can be translated into MATLAB code. **Attention: For the code to work correctly, Cube.CATPart has to be opened in CATIA**. First of all, we create a MATLAB connection with CATIA:
```
catia = actxserver('catia.application');                VBA Code: Not required for this step
```
The variable ```catia``` is the connection with the CATIA application. To select the currently opened CATIA windows, the following line has to be added:
```
Docs = get(catia,'Documents');                          VBA Code: Set Docs = CATIA.Documents
```
With this line, MATLAB assigns to the variable ```Docs``` all the opened windows in CATIA. The variable Docs contains a linkt to all opened CATIA documents (CATParts, CATProducts, etc.). You can check how many Documents are opened by using the _count_ property:
```
Opened_Docs = get(Docs,count);                          VBA CODE: Opened_Docs = Docs.count
```
Since the variable Docs contains ALL the opened documents, to change the cube properties we have to select the Cube.CATPart document. For this scope we can use the _Item_ property:
```
Docpart = invoke(Docs,'Item','Cube.CATPart');           VBA CODE: Set Docpart = Docs.Item("Cube.CATPart")          
```
```Docpart``` selects the CATIA window with Cube.CATPart. To select the Part (the node denoted as _Cube_part_ in the figure) another command is required:
```
Cube = get(Docpart,'part');                             VBA CODE: Set Cube = Docpart.Part
```
Now the variable ```Cube``` represents a direct connection to the node _Cube_part_. We can use this variable to access the _Cube_part_ properties. For example, if we want to change the Length of the cube, we first have to select its set of parameters:
```
Parameters = get(Cube, 'Parameters');                   VBA CODE: Set Parameters = Cube.Parameters
```
The variable ```Parameters``` contains all the parameters of ```Cube```, including _Cube_length_, _Cube_width_, and _Cube_height_ (visible in the CATIA tree) as well as a set of further parameters which are not visible in the CATIA tree. If we want to change _Cube_length_, we have to create a connection with this parameter:
```
Par_length = invoke(Parameters,'Item','Cube_length');   VBA CODE: Set Par_length = Parameters.Item("Cube_length")
```
```Par_length``` now represents a direct connection with the parameter _Cube_length_. We can now retrieve the value of _Cube_length_ and save it in another MATLAB variable:
```
Cube_length = get(Par_length,'Value');                  VBA CODE: Cube_length = Par_length.Value
```
Or we can also use the connection to change the value of _Cube_length_ from MATLAB:
```
set(Par_length,'Value',200);                            VBA CODE: Par_length.Value = 200
```
At first, you may not see any change in CATIA, because (depending on your specific settings) CATIA does not automatically reupdate the Cube.CATPart when its parameters are changed. We can impose the update programmatically from MATLAB:
```
invoke(Cube,'update')                                   VBA CODE: Cube.Update
```
In [MATLAB2CATPart_examples.m](../01_MATLAB2CATPart/MATLAB2CATPart_examples.m) you will find other examples to create objects, change their appearance, introduce new formulas and parameters, etc. 

# CATPART2MATLAB
It is also possible to invert the process and import a CATPart in MATLAB. In this example we will export the vehicle rim shown in the figure underneath:

<p align="center">
<img src="/04_Pictures/Figure_2.png?raw=true" alt="The CATPart which will be imported in MATLAB"/>
</p>

To import the CATPart in MATLAB, we have to save it as .stl file, thus creating the file _Rim.stl_. Once the stl file is saved, we can import it in MATLAB. For this scope, the class [```stl_file```](../02_CATPART2MATLAB/stl_file.m) was created. Calling the class with the link where the .stl file is saved creates a MATLAB import of the ._Rim.stl_:
```
RIM = stl_file('Rim.stl')                    % Import Rim.stl in MATLAB with the class stl_file and assign it to the variable RIM
```
The class ```stl_file``` contains a set of basic functionalities to translate, mirror, and rotate .stl files. These properties are documented in the class file. Furthermore, an example script that shows how to employ the properties of the ```stl_file``` is documented in [```CATPART2MATLAB_example.m```](../02_CATPART2MATLAB/CATPART2MATLAB_example.m).

Exporting and modifying .stl files is not the only way to plot 3D objects in MATLAB. To show the potential of the MATLAB functions, ```MATLAB2CATPart_examples.m``` also shows how to plot elementary objects such as cubes and cylinders by solely using MATLAB functions. For this scope, the functions [plot_cube.m](../02_CATPART2MATLAB/plot_cube.m) and [```plot_cylinder.m```](../02_CATPART2MATLAB/plot_cylinder.m) are created. The script ```MATLAB2CATPart_examples.m``` combines MATLAB function with .stl files to visualize a complex assembly - in this case, an electric vehicle powertrain - in MATLAB. As a final result, the script yields the following MATLAB plot:

<p align="center">
<img src="/04_Pictures/Figure_3.png?raw=true" alt="The resulting plot form the script CATPART2MATLAB_example"/>
</p>

# MATLAB2CATPRODUCT
The workflow of a MATLAB2CATPRODUCT is similar to a MATLAB2CATPART connection but more complex. The first problem is, that in order to create a parametric assembly of different subproducts (each one with its own parameters) a few important steps have to be followed
- First of all the assembly can be created in CATIA by importing or creating the single CATPARTs.
- Secondly, a new component, (which is denoted as ```Parameters``` in our example). Is added to the Assembly.
- ```Parameters``` can be used as the fixed reference Coordinate System for the assembly and to store the assembly's parameters
-  In the component ```Parameters``` it is now possible to initialize all the parameters required for the assembly.
-  If you have the extension Knowledgeware/Knowledge Advisor it is also possible to organize the Parameters in sets
-  Once all the parameters are defined, it is necessary to publish them. By publishing the parameters you make them visible (and therefore linkable) to all the subproducts contained in the assembly. If you do not publish the parameters, they will be usable only within the subproduct ```Parameters``` and could not be used by other subproducts such as ```Cube_part_1```.
-  The Publications can now be linked within the other subproduct. To do so it is necessary to copy them and then paste them in the subproduct node where they are required by using the option Paste/As a Result with Link
-  The Parameters will now appear in a separate set named "External Parameters"
-  You can now connect these parameters with the local parameter declared in the Subproduct
-  With this solution, you have a single Subproduct node (uin this case ```Parameters```) where it is possible to set all the Parameters of the assembly.

In this repository, we already created a parametric CATProduct by following all the steps listed above: [Cube_Assembly.CATProduct](../03_MATLAB2CATPRODUCT/Cube_Assembly.CATProduct). The Assembly is shown underneath:

<p align="center">
<img src="/04_Pictures/Figure_4.png?raw=true" alt="The CATPart which will be imported in MATLAB"/>
</p>


This can be achieved as follows. First of all we have to create a connection with the document (as already done in  MATLAB2CATPart). **Attention: For the code to work correctly, Cube_Assembly.CATProduct has to be opened in CATIA**.
```
catia = actxserver('catia.application');                    VBA Code: Not required for this step
Docs = get(catia,'Documents');                              VBA Code: Set Docs = CATIA.Documents
```
Once the variables are initialized we select the Product document containing the assembly:
```
Docprod = invoke(Docs,'Item','Cube_Assembly.CATProduct');   VBA Code: Set Docprod = Docs.Item("Cube_Assembly.CATProduct")
```
And subsequently select the list of products in the assembly
```
Assembly = get(Docprod,'product');                          VBA Code: Set Assembly = Docprod.Product
Assembly_prods = get(Assembly,'products');                  VBA Code: Set Assembly_prods = Assembly.Products
```
From the list, we now select the Subproduct parameters, which contains the list of parameters and the corresponding pubblications
```
Param_prod = invoke(Assembly_prods,'Item','Parameters');    VBA Code: Set Param_prod = Assembly_prods.Item("Parameters")
```
Finally, from the variable ```Param_prod``` we can select the Publications of the assembly:
```
Publications = get(Param_prod,'Publications');              VBA Code: Set Publications = Param_prod.Publications
```
With this variable, we are now able to read and set all the parameters of the assembly. The procedure to achieve this is documented in the script [```MATLAB2CATPRODUCT.m```](../03_MATLAB2CATPRODUCT/MATLAB2CATPRODUCT.m).



