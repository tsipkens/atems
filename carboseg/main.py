
"""Function to run carboseg independent of Matlab.

By default, results are read from the carboseg/input folder, 
requiring that the images be saved in PNG format previously, 
and written to the carboseg/output folder. 

AUTHOR: Timothy Sipkens, Max Frei, 2020
"""

import glob

from PIL import Image

from segmenter import Segmenter

if __name__ == '__main__':

    image_paths = glob.glob("input/*.png")  # get all images in the input folder

    seg = Segmenter()  # create an instance of the classifier
    predictions = seg.run_images(image_paths)  # run the classifier to get predictions

    seg.save_predictions(predictions, image_paths)  # save the results to output folder

    Image.fromarray(predictions[0]).show()  # show a single prediction (the first image)
