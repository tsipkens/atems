## Colormaps information

These `.mat` files contain the colormaps from two primary sources:

1. Kristen M. Thyng, Chad A. Greene, Robert D. Hetland, Heather M. Zimmerle,
and Steven F. DiMarco. True colors of oceanography: Guidelines for effective
and accurate colormap selection. Oceanography, September 2016.  
http://dx.doi.org/10.5670/oceanog.2016.66 (more information is available at
https://matplotlib.org/cmocean/).

2. The matplotlib (mpl) colormaps designed by Stéfan van der Walt and
Nathaniel Smith (more information is available at https://bids.github.io/colormap/).

When loaded directly, the colormaps will appear as the variable `cm` in the
workspace. Otherwise `load_cmap` can be used to load the colormap specified
by a string, `str`, containing the colormap name. The function `load_cmap`
also takes `n` as a second input, which can be used reduce the number of
colors in the colormap, while still respecting the color order.

It is also noted that the *deep*, *dense*, *matter*, and *tempo* colormaps
are reversed from their original order, such that the darker colour is
always first.

### Included Colormaps

##### Sequantial

From mpl colormaps:
1. *viridis*
2. *inferno*
3. *plasma*
4. *magma*

From cmocean:
5. *thermal*
6. *haline*
7. *ice*
8. *deep*
9. *dense*
10. *matter*
11. *tempo*
12. *speed* - Yellow, green colormap

##### Divergent colormaps

From cmocean:
1. *balance*
2. *delta*
3. *curl*

##### Rainbow, uniform colormaps

From cmocean:
1. *phase*
