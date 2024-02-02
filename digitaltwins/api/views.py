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

CONNECTION_STRING = "mongodb+srv://digitaltwins:!Digitaltwins2023@cluster0.gcvozij.mongodb.net/?retryWrites=true&w=majority"
DB_NAME = "digitaltwins"
COLLECTION_NAME = "Container3"

# @api_view(['POST'])
# def saveMeasurement(request):
#     from azure.cosmos import CosmosClient

#     # Replace these with your actual values
#     endpoint = "https://digitaltwin.documents.azure.com:443/"
#     key = "6eEGRK0nklVJqBs4j34RLeedA02mz36p0U4hokpWjMr3xnBjibSoAq3FWoQzJR4o8PriTOFiFD4XACDb5TsQJw=="
#     database_name = "digitaltwin"
#     container_name = "Container1"

#     # Initialize the Cosmos client
#     client = CosmosClient(endpoint, key)

#     # Get a reference to your database
#     database = client.get_database_client(database_name)

#     # Get a reference to your container
#     container = database.get_container_client(container_name)
#     data = request.data
#     container.upsert_item(body=data)
#     return Response(data)


def home(request):
    return render(request, "api/home.html", {"test": "test"})


from django.shortcuts import render


def dtc_configurator(request):
    pck_path = "dtc-configurator/index.pck"
    wasm_path = "dtc-configurator/index.wasm"

    godot_config = {
        "args": [],
        "canvasResizePolicy": 2,
        "executable": "index",
        "experimentalVK": False,
        "fileSizes": {
            "index.pck": pck_path,
            "index.wasm": wasm_path,
        },
        "focusCanvas": True,
        "gdextensionLibs": [],
    }

    context = {
        "godot_config": godot_config,
    }

    response = render(request, "dtc-game/index.html", context)

    # Add the necessary headers
    response["Cross-Origin-Embedder-Policy"] = "require-corp"
    response["Cross-Origin-Opener-Policy"] = "same-origin"

    return response


@api_view(["POST"])
def saveMeasurement(request):
    # Connect to MongoDB
    client = MongoClient(CONNECTION_STRING)
    db = client[DB_NAME]
    collection = db[COLLECTION_NAME]

    # Get data from the request
    data = request.data
    print(data)
    # Insert the data into the MongoDB collection
    collection.insert_one(data)

    # Close the MongoDB connection
    client.close()

    # Return a response (you might want to customize this)
    return Response({"message": "Measurement saved successfully"})


@api_view(["GET"])
def fetchLatestMeasurement(request):
    try:
        # Connect to MongoDB
        client = MongoClient(CONNECTION_STRING)
        db = client[DB_NAME]
        collection = db[COLLECTION_NAME]
        # Find the latest record in the collection
        latest_measurement = collection.find_one(
            sort=[("timestamp", -1)]
        )  # Assuming 'timestamp' is the field for the timestamp
        if latest_measurement and "_id" in latest_measurement:
            del latest_measurement["_id"]

        # Close the MongoDB connection
        client.close()

        if latest_measurement:
            # If a record is found, return it as a JSON response
            return JsonResponse(latest_measurement)
        else:
            # If no records are found, return an appropriate response
            return JsonResponse({"message": "No records found"}, status=404)

    except Exception as e:
        # Handle any exceptions that may occur during the database operation
        print(f"Error fetching latest measurement: {e}")
        return JsonResponse({"message": "Internal server error"}, status=500)


def fetchAllMeasurements(request):
    try:
        # Connect to MongoDB
        client = MongoClient(CONNECTION_STRING)
        db = client[DB_NAME]
        collection = db[COLLECTION_NAME]
        # Retrieve all documents from the MongoDB collection and convert to a list
        all_documents = collection.find()

        # Convert each document to JSON and join them into a single JSON string
        json_data = (
            "["
            + ", ".join([json.dumps(doc, default=str) for doc in all_documents])
            + "]"
        )
        client.close()
        return JsonResponse(json_data, safe=False)

    except Exception as e:
        # Handle any exceptions that may occur during the database operation
        print(f"Error fetching latest all measurements: {e}")
        return JsonResponse({"message": "Internal server error"}, status=500)


def fetchAverageMachine1(request):
    # Connect to MongoDB
    client = MongoClient(CONNECTION_STRING)
    db = client[DB_NAME]
    collection = db[COLLECTION_NAME]
    # Use the aggregate framework to calculate the average
    pipeline = [
        {"$group": {"_id": None, "avgTemp": {"$avg": "$MachineRawMaterialProperty1"}}}
    ]

    result = list(collection.aggregate(pipeline))
    # Extract the average value
    average_property1 = round(result[0]["avgTemp"], 2)
    # Access the average value
    return JsonResponse({"averageTemperature": average_property1})


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

    # if save_model:
    #     file_path = f"{selected_model}_{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.pkl"
    #     print(file_path)
    #     with open(file_path, 'wb') as file:
    #         pickle.dump(model, file)

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
    return JsonResponse({"NaN": int(total_nan_count), "duplicate_count": int(duplicate_count) })

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