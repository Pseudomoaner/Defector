# Defector
Analysis and tracking of topological defects

## Introduction
Defector is a suite of tools designed to allow localisation, analysis and visualisation of half-integer topological defects within grayscale images. These are singularities in images where features of differing orientation meet at a single point. A good example of toplogical defects are the loops and whirls of fingerprints:

<p align="center">
  <img src="https://raw.githubusercontent.com/Pseudomoaner/Defector/master/Images/Frame_0000.jpg" alt="Fingerprint"/>
</p>

An example analysis with Defector is provided in the DefectorExample.m script; the variable names throughout this document are copied from this example script.

## Usage

### Part 1: DefectorFind

The first part of the defector package allows detection of defects and measurement of their orientation and topological charge. This set of analysis is performed by the DefectorFind.m function.

#### File setup

To set up your images for analysis, first select a root directory (`Root`). All subsequent file locations will be relative to this root.

Now save all the images in your dataset in a subdirectory of this root called 'RawFrames'. Each file should have a name 'Frame_X.tif', where X is a zero-padded four digit number defining the index of the image (in the case of timeseries). You can easily export images in this format by using Fiji/ImageJ's Export Image Sequence save function.

The limits of the number of images in the dataset are set via the `startFrame` and `endFrame` variables.

#### Analysis parameters
The settings for the analysis are defined in the `procSettings` structure. Three fields of `procSettings` need to be defined:

 - `minimumDist`: The minimum distance two defects of opposite topological charge can be apart from one another for them to be considered genuine defects. Defects closer than this will be automatically annihilated.
 - `tensorSize`: The spatial scale (in physical units) over which you wish to perform your defect detection. Larger values tend to result in smoother director fields and smaller numbers of defects being detected.
 - `pixSize`: The size of a single pixel (in physical units) in the original image dataset.
 
When run with these parameters, DefectFind will output a file called 'Defects.mat'. This contains the locations (`posDefCents`, `negDefCents`) and orientations (`posDefOris`, `negDefOris`) of all the defects in each frame.

#### Visualising the output
As well as finding and measuring defects, DefectorFind.m can be used to display the results as an overlay on top of your original images. To do this, set the `plotting` input to true, and provide a suitable output directory location as the `outImgDir` variable. Images such as that shown below will then be generated and automatically saved to the chosen directory as DefectFind proceeds.

<p align="center">
  <img src="https://raw.githubusercontent.com/Pseudomoaner/Defector/master/Images/Overlay.jpg" alt="Defect Overlay"/>
</p>

### Part 2: DefectorTrack

If you have a timeseries dataset, you may wish to track your defects over time. Defector contains the DefectorTrack.m function, which makes use of the FAST tracking framework (https://github.com/Pseudomoaner/FAST) to perform this analysis.

#### Analysis parameters

To make use of DefectorTrack, you will need to define the `trackSettings` structure. This contains the following fields, used to define the parameters of tracking with FAST:

 - `incProp`: The fraction of training links you want to include during the model training stage of the FAST tracking algorithm.
 - `tgtDensity`: The ambiguous link probablility during tracking. Decrease to increase the stringency of tracking.
 - `minTrackLength`: The minimum length of a defect track to be included in the final output of the function.
 - `pixSize`: The size of a single pixel (in physical units). Typically the same as that defined in part 1.
 - `dt`: Timestep size between frames.
 - `imgHeight`: Height of the original image (in physical units).
 - `imgWidth`: Width of the original image (in physical units).

Further details on the top three parameters can be found at the FAST wiki: https://mackdurham.group.shef.ac.uk/FAST_DokuWiki/dokuwiki/doku.php?id=usage:tracking.

#### Tracking outputs

The output of defect tracking, `procDefTracks`, will be appended to the 'Defects.mat' file generated during part 1. The format of this structure corresponds to the usual FAST track format: https://mackdurham.group.shef.ac.uk/FAST_DokuWiki/dokuwiki/doku.php?id=usage:tracking.

Two fields of `procDefTracks` are defined which differ from the usual set of fields:

 - `sparefeat1`: Contains the topological charge information for each defect track.
 - `population`: Set to 1 for +1/2 defects, 2 for -1/2 defects and 3 for defects without a fixed charge (erronious tracks).

## References
- Püspöki Z., Storath M., Sage D., Unser M. (2016). Transforms and Operators for Directional Bioimage Analysis: A Survey. In: De Vos W., Munck S., Timmermans JP. (eds) Focus on Bio-Image Informatics. Advances in Anatomy, Embryology and Cell Biology, vol 219. Springer, Cham. https://doi.org/10.1007/978-3-319-28549-8_3
- Mermin, N. D. (1979). The topological theory of defects in ordered media. Review of Modern Physics 51, 591–648. https://doi.org/10.1103/RevModPhys.51.591
- Huterer, D. and Vachaspati, T. (2005). Distribution of singularities in the cosmic microwave background polarization. Physical Review D 72(4), https://doi.org/043004.10.1103/PhysRevD.72.043004
- Meacock, O.J., Doostmohammadi, A., Foster, K.R. et al (2020). Bacteria solve the problem of crowding by moving slowly. Nat. Phys. https://doi.org/10.1038/s41567-020-01070-6

## Contributors

- Oliver J. Meacock
- Amin Doostmohammadi
