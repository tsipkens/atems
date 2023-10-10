---
title: 'atems: Analysis tools for TEM images of carbonaceous particles'
tags:
  - Matlab
  - aerosol science
  - electron microscopy
  - soot
  - image processing
  - tem
  - particle size distribution
  - aggregates
  - transmission electron microscopy tem-images aerosols 
  - particle diameter
authors:
  - name: Timothy A Sipkens
    orcid: 0000-0003-1719-7105
    corresponding: true
    affiliation: "1, 2"
  - name: Ramin Dastanpour
    affiliation: 1
  - name: Una Trivanovic
    orcid: 0000-0002-0748-017X
    affiliation: 1
  - name: Hamed Nikookar
    affiliation: 1
  - name: Steven N. Rogak
    orcid: 0000-0002-4418-517X
    affiliation: 1
affiliations:
 - name: Mechanical Engineering, University of British Columbia, Canada
   index: 1
 - name: Metrology Research Centre, National Research Council Canada, Canada
   index: 2
date: May 11, 2023
bibliography: paper.bib

---


# Introduction

Soot, carbon black, and other carbonaceous particles have important climate, health, and technological impacts that depend on their morphology. These particles have complex shapes composed of a collection of small, primary particles in fractal arrangements, as shown in \autoref{fig:soot}a. Transmission electron microscopy (TEM) images of these particles allow for detailed information about particle morphology that is unavailable in other characterization techniques. However, extracting this information requires image analysis across a statistically-significant number of particles, with the quality of conclusions improving as the number of characterized particles increases. For instance, @kelesidis2020 suggested quantifying at least 400 primary particles per experimental condition in a premixed flame to get an accurate average primary particle diameter from manually drawing elipses (that study counted 800 primary particles). In the broader literature, a few hundred particles per condition seems to be standard, with other authors having employed between 150 and 400 particles per condition [@liati2014; @marhaba2019; @trivanovic2019; @trivanovic2020], depending on the type of analysis. For multiple conditions, this can quickly expand to over 1000 particles. This characterization is often done manually, which at a minimum of several minutes per aggregate, is incredibly labour intensive. Unfortunately, the low contrast (carbonaceous particles on carbon films) and complex particle morphology of common carbonaceous particles makes automated analysis challenging, requiring unique analysis methods over those developed for traditional TEM image analysis of many engineered nanomaterials [@schneider2012imagej]. At the same time, existing automated methods across the literature are typically only applied to data from a single laboratory, with few exceptions [@anderson2017repeatability; @sipkensfrei2021cnn]. This limits comparability between laboratories [@sipkens2023]. 

The objective of `atems` is to provide a suite of open source analysis tools (largely in Matlab) for TEM image analysis that are specifically designed for soot and related carbonaceous particles (e.g., tarballs). This codebase started as a manual analysis code by @dastanpour2014, with the first automated methods added by @dastanpour2016. The current, open source version has been streamlined and expanded to include a larger suite of automated analysis methods from the literature, as detailed in the following section. In this regard, a key contribution of this codebase is to provide open source implementations of multiple analysis methods spanning a range of laboratories. This codebase places these methods in the same framework, with the goal of enabling intercomparisons of analysis routines across a range of data. 

![Sample TEM image of soot demonstrating the aggregate structure, where **a** is an unlabeled image containing soot aggregates and **b** is that same image with the aggregates labeled.\label{fig:soot}](01-sample-image.png){ width=90% }


# Methods

After loading images (with an automated method provided for doing so), analysis involves two major steps. 

The first step is segmentation of the aggregates from their background. Available methods include the slider-based manual approach of @dastanpour2014; the common Otsu method; a modification of Otsu by @dastanpour2016 that employs morphological operations to improve segmentation; the *k*-means approach of @sipkens2021kmeans; and `carboseg`, which is the convolutional neural network (CNN) approach from @sipkensfrei2021cnn. Functionality is also available to prepare (e.g., read and crop image footers) and export images for external analysis, prior to reading the images in for subsequent analysis. This enables external extensions, such as the WEKA segmentation method of @altenhoff2020. Tools are then available to compute aggregate projected area, perimeter, and circularity, among other properties. A sampling of segmentations produced by these methods is presented in \autoref{fig:seg}. 

![Sample segmentations across a range of methods available in this code. The manual method corresponds to an updated version of the code development by @dastanpour2016. The Otsu segmentation is standard Otsu, without any adaptations. The *k*-means method is that described by @sipkens2021kmeans. TWS refers to trainable WEKA segmentation based on the method described by @altenhoff2020, which makes use of the code enabling external extensions. These first four panels correspond to images from @sipkens2021kmeans. The final panel corresponds to the convolutional neural network method described by @sipkensfrei2021cnn. \label{fig:seg}](02-seg-methods.png){ width=100% }

Second, this code works to identify primary particles, that is the small, roughly circular structures inside the aggregates. Available methods include a updated version of the Euclidean distance mapping--surface-based scale analysis (EDM-SBS) of @bescond2014, converted from SciLab to Matlab in association with @sipkensfrei2021cnn (functionality between the two languages resulted in minor differences); the Euclidean distance mapping--watershed (EDM-WS) method of @detemmerman2014; the pair correlation method (PCM) of @dastanpour2016; the Hough transform method of @kook2016; and the Hough transform method of @altenhoff2020. 

General plotting and other utilities (`tools.*`) are provided to enable further analysis and visualization (e.g., as in \autoref{fig:soot}b and \autoref{fig:seg}). 


# Use

This code has been used in a number of studies in the literature. This code was used by @sipkensfrei2021cnn to compare multiple segmentation and primary particle analysis methods. The code was also used by @trivanovic2019, @kheirkhah2020, and @trivanovic2020 to perform image analysis of marine engine and flare soot. The *k*-means method in this code [@sipkens2021kmeans] was also employed for soot by @li2022flame. 


# Acknowledgements

We wish to acknowledge related code released in association with some of the cited work. These including Matlab code provided in @kook2016 and [SciLab code](https://www.coria.fr/en/edm-sbs-automated-analysis-of-tem-images/) released in association with @bescond2014. The code from @altenhoff2020 was provided by the authors and adapted to the present format. 

We also wish to acknowledge funding by the Canadian Council of the Arts (Killam Fellowship), the Natural Sciences and Engineering Research Council of Canada (NSERC), and Transport Canada. 


# References