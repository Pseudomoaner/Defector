# Defector
Analysis of topological defects

## Introduction
Defector is a suite of tools designed to allow localisation, analysis and visualisation of topological defects within grayscale images. These are singularities in images where the orientation of the features within the image change instantaneously. A good example of toplogical defects are the loops and whirls of fingerprints:

<p align="center">
  <img src="https://raw.githubusercontent.com/Pseudomoaner/Defector/master/Images/Frame_0000.jpg" alt="Fingerprint"/>
</p>

Note that the method described here can only find half integer (+1/2 and -1/2) topological defects.

## Usage

### Part 0: Setting up Fiji
1. To begin, you will need to download and install [Fiji](https://fiji.sc/)/[ImageJ](https://imagej.nih.gov/ij/). 
2. Next, you will need to install the [OrientationJ](http://bigwww.epfl.ch/demo/orientation/) plugin. To do this, simply download the OrientationJ_.jar file and move it to the Plugins directory of your Fiji/ImageJ installation. 

### Part 1: Finding the orientation field
How you find the orientation field will depend upon your file type:

1. For single images, you can run OrientationJ directly out of the Fiji Plugins menu. It can be found in Plugins -> OrientationJ -> OrientationJ Analysis. To ensure that the output is saved in a format that later processing stages can understand, you can also run the macro applyOrientationJSingleFrame.ijm. This will produce a grayscale 32-bit image, which should be saved in a separate directory. For our fingerprint, this looks like:

<p align="center">
  <img src="https://raw.githubusercontent.com/Pseudomoaner/Defector/master/Images/Orientation.png" alt="Orientation"/>
</p>

   If you want to make locations where the orientation goes from -pi/2 to pi/2 smooth, you can use a circular colourmap such as Fiji's 'Spectrum' LUT:

<p align="center">
  <img src="https://raw.githubusercontent.com/Pseudomoaner/Defector/master/Images/OrientationC.png" alt="OrientationC"/>
</p>

   Save the grayscale 32-bit image in a subfolder of the directory containing your original image called 'Orientations'.

2. For timeseries, you will first need to save your image sequence as a series of frames within a single directory. You can achieve this within Fiji by using File -> Save As -> Image Sequence... , then choosing settings as shown below:

<p align="center">
  <img src="https://raw.githubusercontent.com/Pseudomoaner/Defector/master/Images/ImageSequence.jpg" alt="Image Sequence"/>
</p>

   Now you can run the script applyOrientationJBatch.ijm. Write the directory in which your image sequence is saved as the Root variable, the total number of timepoints you wish to analyse as the tmax variable.

In both cases, you will need to choose the tensorSize variable. This sets the width of the Gaussian filter that blurs the image gradients, with larger values tending to reduce the number of defects detected.

### Part 2: Analysing defects
1. Now open Matlab. The main script you will need to run here is fusedDefectFinder.m. You will need to define the following variables:

<p align="center">
  <img src="https://raw.githubusercontent.com/Pseudomoaner/Defector/master/Images/DefectSettings.PNG" alt="Defect Settings"/>
</p>

2. If you wish to export plots of the defects on top of your original image, ensure that the variable 'plotting' is set to true. You will also need to have the [export_fig](https://uk.mathworks.com/matlabcentral/fileexchange/23629-export_fig) package for Matlab downloaded and on your path. With this active, you will export plots like this:

<p align="center">
  <img src="https://raw.githubusercontent.com/Pseudomoaner/Defector/master/Images/Overlay.jpg" alt="Defect Overlay"/>
</p>

   These will be saved in a subdirectory in your root directory called DefectOverlays.
   
   If you don't like how these overlays look, you can access the plotting parameters within the analyseDefects.m function. 
   
3. Once the script has finished running, your defect properties will be saved in your root directory in a file called 'Defects.mat'. This file contains four variables: 'positiveDefectStore' and 'negativeDefectStore' contain the x,y coordinates of the +1/2 and -1/2 defect cores, respectively, and 'posDefectOrientationStore' and 'negDefectOrientationStore' contain the orientations of the +1/2 and -1/2 defect cores.

## References
- Püspöki Z., Storath M., Sage D., Unser M. (2016). Transforms and Operators for Directional Bioimage Analysis: A Survey. In: De Vos W., Munck S., Timmermans JP. (eds) Focus on Bio-Image Informatics. Advances in Anatomy, Embryology and Cell Biology, vol 219. Springer, Cham. https://doi.org/10.1007/978-3-319-28549-8_3
- Mermin, N. D. (1979). The topological theory of defects in ordered media. Review of Modern Physics 51, 591–648. https://doi.org/10.1103/RevModPhys.51.591
- Huterer, D. and Vachaspati, T. (2005). Distribution of singularities in the cosmic microwave background polarization. Physical Review D 72(4), https://doi.org/043004.10.1103/PhysRevD.72.043004

## Contributors

- Oliver J. Meacock
- Amin Doostmohammadi
