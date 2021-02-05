
import functools
import os
from pathlib import Path

import numpy as np
import onnxruntime as rt
import requests
from PIL import Image
from tqdm import tqdm


class Segmenter:
    def __init__(
        self,
    ):

        self.checkpoint_path = Path(__file__).parent / "FPN-resnet50-imagenet.onnx"

        # If ONNX file is not available locally.
        if not self.checkpoint_path.exists():
            print("Downloading ONNX file...")
            self.download_checkpoint()
            print("Complete.\n")

        self.onnx_session = rt.InferenceSession(str(self.checkpoint_path))

    @staticmethod
    def read_image(image_path):
        return Image.open(image_path).convert("RGB")

    @staticmethod
    def to_tensor_image(x, **kwargs):
        return x.transpose(2, 0, 1).astype("float32")

    @staticmethod
    def transform_input(x, mean=None, std=None, input_space="RGB", input_range=None, **kwargs):
        """
        Reformat image input, as necessary to apply classifier.
        From segmentation-models-pytorch package.
        """

        if input_space == "BGR":
            x = x[..., ::-1].copy()

        if input_range is not None:
            if x.max() > 1 and input_range[1] == 1:
                x = x / 255.0

        if mean is not None:
            mean = np.array(mean)
            x = x - mean

        if std is not None:
            std = np.array(std)
            x = x / std

        return x

    def segment_image(self, image):
        """ Apply a classifier to a single image, given as PIL Image. """

        # Pre-process image.
        # Preprocess fun is based on segmentation-models-pytorch package.
        image = np.asarray(image)

        params = {
            "input_space": "RGB",
            "input_size": [3, 224, 224],
            "input_range": [0, 1],
            "mean": [0.485, 0.456, 0.406],
            "std": [0.229, 0.224, 0.225],
        }
        preprocess_fun = functools.partial(self.transform_input, **params)
        image = preprocess_fun(image)

        image = self.to_tensor_image(image)
        image = np.expand_dims(image, 0)

        # Produce raw prediction.
        input_name = self.onnx_session.get_inputs()[0].name
        output_name = self.onnx_session.get_outputs()[0].name
        prediction = self.onnx_session.run([output_name], {input_name: image})[0]

        # Format output and return.
        return prediction.squeeze().round().astype(bool)

    def run_images(self, image_paths):
        """
        Upper level wrapper to classify a series of images.
        Takes a list of file paths as input.
        """

        predictions = [None] * len(image_paths)  # initialize the predictions list

        # Loop through images and generate predictions.
        print("Classifying images...")
        for ii in range(len(image_paths)):
            print("Classifying image " + str(ii + 1) + " of " + str(len(image_paths)) + ".")
            image = Image.open(image_paths[ii]).convert("RGB")  # read in image
            predictions[ii] = self.segment_image(image)  # run classifier on image
        print("Finished classifying.\n")

        return predictions

    @staticmethod
    def save_predictions(predictions, image_paths, folder="output"):
        """ Utility to save predictions to the specified folder. """

        # Loop through image paths.
        for ii in range(len(predictions)):
            Image.fromarray(predictions[ii]).save(folder + os.path.sep + os.path.basename(image_paths[ii]))

        print("Images saved.")

    def download_checkpoint(self):
        """
        Get ONNX file is not currently available locally.
        Based on:
        https://stackoverflow.com/questions/37573483/progress-bar-while-download-file-over-http-with-requests
        """
        checkpoint_filename = self.checkpoint_path.name

        expected_checkpoint_filenames = ["FPN-resnet50-imagenet.onnx"]

        assert (
            checkpoint_filename in expected_checkpoint_filenames
        ), f"Expected checkpoint file name to be in {checkpoint_filename}."

        # url = os.path.join(CHECKPOINT_URL_BASE, checkpoint_filename)
        # TODO: Replace temporary checkpoint url.
        url = "https://uni-duisburg-essen.sciebo.de/s/J7bS47nZadg4bBH/download"
        request_stream = requests.get(url, stream=True)

        # Total size in bytes.
        total_size = int(request_stream.headers.get("content-length", 0))
        block_size = 1024  # 1 Kibibyte

        print(f"Downloading checkpoint file from {url}...")

        # print(f"Downloading checkpoint file from {url}...")
        progress_bar = tqdm(total=total_size, unit="iB", unit_scale=True)
        with open(self.checkpoint_path, "wb") as file:
            for data in request_stream.iter_content(block_size):
                progress_bar.update(len(data))
                file.write(data)
        progress_bar.close()
        if total_size != 0 and progress_bar.n != total_size:
            raise RuntimeError("Error while downloading checkpoint file.")
