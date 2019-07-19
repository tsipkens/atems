# UBC-TEM-analysis

This program contains several methods of characterizing aggregates from
TEM images, including evaluating the aggregate projected area, perimeter,
and primary particle diameter.


### Description

The software contains MATLAB designed to compare multiple
methods of analyzing TEM images of aggregates. These include the
pair correlation method (PCM), Kook, and manual methods.

#### Packages

###### +kook

This package contains a copy of the code provided by Kook et al. (2015),
with minor modifications to match in the input/output of some of the
other packages.

###### +kook_mod

This package contains a heavily modified version of the method proposed
by Kook et al. (2015).

###### +manual

An implementation of the manual sizing code developed at the University of
British Columbia.

###### +pcm

This package contains an update to code for evaluating the pair correlation
method (PCM) described by Dastanpour et al. (2016).

###### +thresholding_ui

This package contains a unified implementation of the thresholding user
interface associated with the PCM code of Dastanpour et al. (2016) and
manual code developed at the University of British Columbia.

### Output

The various methods of evaluating the properties of the aggregate properties
output the data in a structured format, which can be exported to a JSON
format to be analyzed in other software and languages.

--------------------------------------------------------------------------

#### License

This software is licensed under an MIT license (see the corresponding file
for details).


#### Contact information and acknowledgements

This code was primarily compiled by Timothy A. Sipkens while at the
University of British Columbia (UBC), who can be emailed at
[tsipkens@mail.ubc.ca](mailto:tsipkens@mail.ubc.ca). The code
itself was compiled from various sources and features code written by
several individuals at UBC, including Yeshun (Samuel) Ma, Ramin Dastanpour,
Yiling Kang, Una Trivanovich, and Steven Rogak, among others.

Also featured is the original MATLAB code of Kook et al.
([https://doi.org/10.4271/2015-01-1991](https://doi.org/10.4271/2015-01-1991)),
modified slightly to accommodate the expected inputs and outputs common
to the other functions, and a modification thereof by Ramin Dastanpour
and Yiling Kang.

The PCM code is adapted from the work of Dastanpour et al.
([https://doi.org/10.1016/j.powtec.2016.03.027](https://doi.org/10.1016/j.powtec.2016.03.027)).
