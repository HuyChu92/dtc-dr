from django.contrib.auth.models import User, Group
from rest_framework import viewsets
from rest_framework import permissions
from django.shortcuts import render, redirect
from django.http import JsonResponse
from django.http import HttpResponse, FileResponse
from django.shortcuts import get_object_or_404

from rest_framework.decorators import api_view
from rest_framework.relations import ManyRelatedField
from rest_framework.response import Response

from pymongo import MongoClient
from bson.json_util import dumps
import json
import pandas as pd
import pickle
from sklearn.linear_model import *
import os
import pickle
from .modelhandler import *
from datetime import datetime
from .forms import FileUploadForm
from pathlib import Path
from django.conf import settings


PREDICTIONS_MAPPING = [
    "Stage1.Output.Measurement0.U.Actual",
    "Stage1.Output.Measurement1.U.Actual",
    "Stage1.Output.Measurement2.U.Actual",
    "Stage1.Output.Measurement3.U.Actual",
    "Stage1.Output.Measurement4.U.Actual",
    "Stage1.Output.Measurement5.U.Actual",
    "Stage1.Output.Measurement6.U.Actual",
    "Stage1.Output.Measurement7.U.Actual",
    "Stage1.Output.Measurement8.U.Actual",
    "Stage1.Output.Measurement9.U.Actual",
    "Stage1.Output.Measurement10.U.Actual",
    "Stage1.Output.Measurement11.U.Actual",
    "Stage1.Output.Measurement12.U.Actual",
    "Stage1.Output.Measurement13.U.Actual",
    "Stage1.Output.Measurement14.U.Actual",
]



def home(request):
    return render(request, "api/home.html", {"test": "test"})


@api_view(["GET"])
def fetchInputTestData(request):
    try:
        # Open the JSON file and load its content
        with open(r"D:\dtc-dr\models.py\json_test_data.json", "r") as json_file:
            data = json.load(json_file)

        # Return a JsonResponse with the loaded data
        return JsonResponse(
            data, safe=False
        )  # 'safe=False' is needed for non-dict objects (e.g., a list)
    except FileNotFoundError:
        return JsonResponse({"error": "File not found"}, status=404)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)


@api_view(["POST"])
def getPrediction(request):
    # Open het model
    with open(
        r"D:\dtc-dr\digitaltwins\api\linear_regression_model.pkl", "rb"
    ) as model_file:
        loaded_model = pickle.load(model_file)

    data = request.data
    result = []
    # itereer over iedere invoerdata
    for index, input in enumerate(data):
        output_dict = {}
        feature_values = []

        for key, value in input.items():
            feature_values.append(value)

        predictions_list = loaded_model.predict([feature_values]).tolist()
        predictions = {}
        for index, value in enumerate(predictions_list[0]):
            predictions[PREDICTIONS_MAPPING[index]] = value
        output_dict[index] = {"input": input, "predictions": predictions}
        result.append(output_dict)
    return JsonResponse(result, safe=False)

@api_view(["POST"])
def trainModel(request):
    """ Train een model gebasseerd op de geselecteerde features en model

    Args:
        request (dict): _description_

    Returns:
        _type_: _description_
    """
    data = request.data
    features = data["features"]
    y = data["y"]
    selected_model = data["model"]
    dataset = data["dataset"]
    scaler = data["scaler"]
    save_model = data["save_model"]

    model = ModelSelector(
        dataset,
        features,
        y,
        selected_model,
        scaler
    )
    evaluation = model.meta_info

    return JsonResponse({"evaluation": evaluation})

@api_view(["GET"])
def fetchDatasets(request):
    """ Toon de datasets die de gebruiker heeft toegevoegd

    Args:
        request (_type_): _description_

    Returns:
        _type_: _description_
    """
    source = os.path.join(settings.BASE_DIR, 'api', 'datasets')
    files = []

    for root, dirs, filenames in os.walk(source):
        for filename in filenames:
            # Check if the file has a CSV or Excel extension
            if filename.endswith(".csv") or filename.endswith(".xlsx"):
                # Append the filename to the list
                files.append(filename)

    return JsonResponse({"files": files})

@api_view(["GET"])
def fetchDatasetInfo(request):
    return None


def uploadDataset(request):
    if request.method == 'POST':
        form = FileUploadForm(request.POST, request.FILES)
        if form.is_valid():
            # Get the uploaded file from the form
            uploaded_file = form.cleaned_data['file']
            file_name = uploaded_file.name.split('.')[0]
            # folder_path = os.path.join('api/datasets', file_name)
            folder_path = Path('api/datasets') / file_name
            folder_path.mkdir(parents=True, exist_ok=True)

            plots_path = Path('api/datasets') / file_name / "plots"
            plots_path.mkdir(parents=True, exist_ok=True)

            models_path = Path('api/datasets') / file_name / "models"
            models_path.mkdir(parents=True, exist_ok=True)

            # Specify the directory where you want to save the file
            upload_directory = os.path.join('api/datasets', file_name)

            # Ensure the directory exists, create it if necessary
            os.makedirs(upload_directory, exist_ok=True)

            # Build the full path to save the file
            file_path = os.path.join(upload_directory, uploaded_file.name)

            # Open the destination file in binary write mode and copy the uploaded file's content
            with open(file_path, 'wb') as destination_file:
                for chunk in uploaded_file.chunks():
                    destination_file.write(chunk)

            # Generate evaluation metrics and plots
            DatasetEvaluator(Path('api/datasets') / file_name / uploaded_file.name, Path('api/datasets') / file_name)

            return render(request, 'api/upload.html', {'form': form})
    else:
        form = FileUploadForm()
    return render(request, 'api/upload.html', {'form': form})

def dataset_detail(request, dataset):
    dataset_source = os.path.join('api/datasets', dataset.split('.')[0], dataset)
    df = pd.read_csv(dataset_source) if 'csv' in dataset else pd.read_excel(dataset_source)
    total_nan_count = df.isna().sum().sum()
    duplicate_count = df.duplicated().sum()
    columns = df.tolist()
    return JsonResponse({"NaN": int(total_nan_count), "duplicate_count": int(duplicate_count), "columns": columns })

# def dataset_plotimage(request, dataset, imagename):
#     # Assuming your images are stored in a 'media' directory within your Django project
#     image_path = os.path.join('api/datasets', dataset.split('.')[0], "plots", imagename)

#     # Check if the file exists
#     if not os.path.exists(image_path):
#         return HttpResponse("Image not found", status=404)

#     # Open the file for reading
#     with open(image_path, 'rb') as image_file:
#         # Determine the content type based on the file extension
#         _, extension = os.path.splitext(imagename)
#         content_type = f'image/{extension.lstrip(".")}'

#         # Set the response content type
#         response = HttpResponse(image_file.read(), content_type=content_type)

#         # Set the content-disposition header to make the browser display the file inline
#         response['Content-Disposition'] = f'inline; filename="{imagename}"'

#         return response

def dataset_plotimage(request, dataset, imagename):
    # Assuming your images are stored in a 'media' directory within your Django project
    image_path = os.path.join(settings.BASE_DIR, 'api/datasets', dataset.split('.')[0], "plots", imagename)

    # Check if the file exists
    if not os.path.exists(image_path):
        return FileResponse("Image not found", status=404)

    # Determine the content type based on the file extension
    _, extension = os.path.splitext(imagename)
    content_type = f'image/{extension.lstrip(".")}'

    # Set the response content type
    response = FileResponse(open(image_path, 'rb'), content_type=content_type)

    # Set the content-disposition header to make the browser display the file inline
    response['Content-Disposition'] = f'inline; filename="{imagename}"'

    return response


def fetchScatterplot(request, dataset, model, imagename):
    # Assuming your images are stored in a 'media' directory within your Django project
    image_path = os.path.join(settings.BASE_DIR, 'api/datasets', dataset.split('.')[0], 'models', model, imagename)
    print(image_path)
    # Check if the file exists
    if not os.path.exists(image_path):
        return FileResponse("Image not found", status=404)

    # Determine the content type based on the file extension
    _, extension = os.path.splitext(imagename)
    content_type = f'image/{extension.lstrip(".")}'

    # Set the response content type
    response = FileResponse(open(image_path, 'rb'), content_type=content_type)

    # Set the content-disposition header to make the browser display the file inline
    response['Content-Disposition'] = f'inline; filename="{imagename}"'

    return response

def fetchModels(request, dataset):
    # Assuming your images are stored in a 'media' directory within your Django project
    models_path = os.path.join(settings.BASE_DIR, 'api/datasets', dataset.split('.')[0], "models")
    files = []

    for root, dirs, filenames in os.walk(models_path):
        for filename in filenames:
            # Check if the file has a CSV or Excel extension
            if filename.endswith(".pkl"):
                # Append the filename to the list
                files.append(filename)

    return JsonResponse({"files": files})