Kook Image Processing
Originally By: Ben Gigone and Emre Karatas, PhD
Adapted from Kook et al. 2016, SAE
Modified By: Yiling Kang

This code was modified to provide more accurate primary particle size data with 
fuzzier and lower quality backgrounds.The code also now saves all data into one 
Excel spreadsheet, and creates folders for each individual image and saves the 
processed images for further review if required.

Pre-processing steps are as follows:
1. Select individual particle to be processed
2. Use thresholding method adapted from Dastanpour et al. 2016 to extract binary 
   image from particle
3. Bottom hat filter to fix background illumination and particle illumination
4. Enhance contrast between individual particles and betweent the agglomerate and
   background
5. Median filter to remove salt and pepper noise from the particles and background
6. Save results of pre-processing into new folder for image

Processing steps are as follows:
1. Multiply binary image by grayscale image to delete the background (replace
   with 0/black pixels)
2. Canny edge detection* to detect the edge of the individual particle circles
3. Imposing white background onto image so the program does not detect any 
   background particles.
4. Use imfindcircles/circular hough transform** to detect circles from image. Use
   the 'dark' setting to detect dark cirlces only, and not the background
5. Save image results
6. Calculate size of circles and save data into Excel

*  Canny edge detection sensitivity can be adjusted with the edge_threshold
   parameter in line 34 of the program

** Circular hough transform sensitivity can be adjusted with sens_val in line 33
   of the code. In addition, the boundaries for the size of the circles detected
   can be adjusted to filter out outliers in line 31-32 with rmax and rmin