
import glob

from PIL import Image

from segmenter import Segmenter


image_paths = glob.glob("input/*.png")  # get all images in the input folder

segmenter = Segmenter()  # create an instance of the classifier
predictions = segmenter.run_images(image_paths)  # run the classifier to get predictions

segmenter.save_predictions(predictions, image_paths)  # save the results to output folder

Image.fromarray(predictions[0]).show()  # show a single prediction (the first image)
