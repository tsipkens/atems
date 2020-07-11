
# *A*nalysis tools for *TEM* images of *S*oot (ATEMS)

[![DOI](https://zenodo.org/badge/190795680.svg)](https://zenodo.org/badge/latestdoi/190795680)
[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)
[![Version](https://img.shields.io/badge/Version-0.4+-blue.svg)]()

This program contains several methods of characterizing aggregates from TEM images for image analysis at the University of British Columbia (UBC). This includes methods for evaluating the aggregate projected area, perimeter, and primary particle diameter.

The software contains MATLAB code designed to compare multiple methods of analyzing TEM images of aggregates. These include the pair correlation method (PCM), Kook, and manual methods. The program is primarily composed of two packages: 

1. +agg, which performs aggregate-level segmentation to output a binary image, and 

2. +pp, which determines the primarily particle detection. 

## 1. Data structures

#### 1.1 Imgs and Imgs_ref

Images in this program are handled primarily by two MATLAB structured arrays: `Imgs_ref` and `Imgs`. 

The former contains a reference to the images, including file name and containing directory. The reference can be generated manually or by using a file explorer by calling the `tools.get_img_ref()` function. 

The latter contains both the imported raw image, as well as processed versions of the image, such as those with the footer removed, and information extracted from the footer of the image. This structure can be used as input to most of the aggregate
segmentation and primary particle analysis functions. Typical fields include:

| Field | Description |
| :---  | :--- |
| raw | The raw unprocessed image, as imported. |
| cropped | A version of the image with the footer removed. |
| fname | The filename from which the image originated. |
| pixsize | The size, in nanometers, of the pixels in a given image. |
| binary | Used to store a binary version of the image resulting from aggregate segmentation, if desired. |

#### Aggs

The output data itself, `Aggs`, is a MATLAB structured array with one entry per aggregate. This data can then be exported to a JSON format using `tools.write_json(...)` or an Excel spreadsheet using `tools.write_excel(...)`, to be analyzed in other
software and languages.


## 2. Aggregate segmentation package (+agg)

This package contains an expanding library of functions aimed at
performing semantic segmentation of the TEM images into aggregate
and background areas. Some of the functions are modeled after the code of
[Dastanpour et al. (2016)][dastanpour2016], though code from that project has been
significantly altered in the present program.

#### 2.1 agg.seg* functions

Functions implementing different methods of aggregate-level semantic segmentation have filenames starting with `agg.seg*`. The functions generally share two common inputs:

1. `imgs` - An unmodified (save for removing the footer) single image or cellular array of images
of the aggregates. 

2. `pixsize` - The size of each pixel in the image (often used in the rolling ball transformation). 

Other arguments depend on the function. 

The available methods are summarized below. In each case, efforts are ongoing to standardize the outputs, which primarily consist of binary images in which pixels identified as part of the aggregate are assigned a value of `1` and pixels in the background are assigned a value of `0`.

Other methods, beyond those below, are currently under development.

###### 2.1.1 seg_otsu_rb

This method applies Otsu thresholding followed by a rolling ball transformation that fills gaps in the particles (as per [Dastanpour et al. (2016)][dastanpour2016]). This method uses the `rolling_ball` function included with this package to perform the rolling ball transformation.

###### 2.1.2 seg_slider

This is a GUI-based method with a slider for *adaptive* manual thresholding of the image (adaptive in that small sections of the image can be cropped and thresholded independently). Gaussian denoising is first performed on the image to reduce the noise in the thresholded image. Then, a slider is used to manually adjust the level of the threshold. This is a variant of the method included with the distribution of the PCM code by [Dastanpour et al. (2016)][dastanpour2016], though it has seen considerable updates
since that implementation. 

Several subfunctions are included within the main file.

*We note that this code saw several important bug updates since the original code by [Dastanpour et al. (2016)][dastanpour2016]. This includes fixing how the original code would repeatedly apply a Gaussian filter every time the user interacted with the slider in the GUI (which may cause some backward compatibility issues), a reduction in the use of global variables, and significant memory savings.*

###### 2.1.3 seg

This is included as a wrapper function (agg_det.m) that runs a
series of these other methods in series, prompting the user
if adequate thresholding was achieved by a given method.

#### 2.2 analyze_binary

This function analyzes the binary image output from any of the `agg.seg_*` functions. The output is a MATLAB structured array
containing information about the aggregate, such as area in pixels, radius of gyration, area-equivalent diameter, aspect ratio
etc., in an `Aggs` structured array. The array has one entry for each aggregate found in the image, defined as independent groupings of pixels. The function itself takes a binary image, the original image, and the pixel size as inputs, generating an `Aggs` structure by

```Matlab
Aggs = agg.analyze_binary(imgs_binary,imgs,pixsize,fname);
```

The `fname` argument is optional and adds this tag to the information in the output `Aggs` structure. 


## 3. Primary particle analysis package (+pp)

The +pp package contains multiple methods for determining the primary particle size of the aggregates of interest. Often this requires a binary mask of the image that can be generated using the +agg package methods.

#### 3.1 pcm

The University of British Columbia's pair correlation method (PCM) MATLAB code for processing TEM images of soot to determine morphological properties. This package contains a significant update to the previous code provided with [Dastanpour et al. (2016)][dastanpour2016].

#### 3.2 kook

This method contains a copy of the code provided by [Kook et al. (2015)][kook], with minor modifications to match in the input/output of some of the other packages. The method is based on using the Hough transform on a pre-processed image.

#### 3.3 kook_yl

This method contains a modified version of the method proposed by [Kook et al. (2015)][kook].

#### 3.4 manual

Code to be used in the manual sizing of soot primary particles developed at the University of British Columbia. The current method uses crosshairs to select the length and width of the particle. This is converted to various quantities, such as the mean primary particle diameter. The manual code is a heavily modified version of the code associated with [Dastanpour and Rogak (2014)][dastanpour2014].


## 4. Additional tools package (+tools)

This package contains a series of functions that help in visualizing or analyzing the aggregates.

#### Plotting functions (plot*)

These functions aid in visualizing the results. For example, `plot_binary_overlay(...)` will plot the image and overlay labels for the aggregates in a corresponding binary image.

--------------------------------------------------------------------------

#### License

This software is licensed under an MIT license (see the corresponding file for details).


#### Contributors and acknowledgements

This code was primarily compiled by Timothy A. Sipkens while at the University of British Columbia (UBC), who can be contacted at [tsipkens@mail.ubc.ca](mailto:tsipkens@mail.ubc.ca). The code itself was compiled from various sources and features code written by several individuals at UBC, including Ramin Dastanpour, [Una Trivanovic](https://github.com/unatriva), Yiling Kang, Yeshun (Samuel) Ma, and Steven Rogak, among others.

Included with this program is the MATLAB code of [Kook et al. (2015)][kook], modified to accommodate the expected inputs and outputs common to the other functions.

This program also contains heavily modified versions of the code distributed with [Dastanpour et al. (2016)][dastanpour2016]. This includes much of the manual processing codes and the PCM method, as noted in the README above.


#### References

1. [Kook et al., SAE Int. J. Engines (2015).][kook]
2. [Dastanpour et al., J. Powder Tech. (2016).][dastanpour2016]
3. [Dastanpour and Rogak, Aerosol Sci. Technol. (2014).][dastanpour2014]

[kook]: https://doi.org/10.4271/2015-01-1991
[dastanpour2016]: https://doi.org/10.1016/j.powtec.2016.03.027
[dastanpour2014]: https://doi.org/10.1080/02786826.2014.955565
