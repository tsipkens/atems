
import glob

from PIL import Image

from segmenter import Segmenter

if __name__ == '__main__':

    image_paths = glob.glob("input/*.png")  # get all images in the input folder

    seg = Segmenter()  # create an instance of the classifier
    predictions = seg.run_images(image_paths)  # run the classifier to get predictions

    seg.save_predictions(predictions, image_paths)  # save the results to output folder

    Image.fromarray(predictions[0]).show()  # show a single prediction (the first image)
