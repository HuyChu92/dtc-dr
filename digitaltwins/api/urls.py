from django.urls import path
from . import views
from django.conf.urls.static import static
from django.conf import settings

urlpatterns = [
    path('', views.home, name='home'),
    path('dtc-configurator/', views.dtc_configurator, name='dtc-configurator'),
    path('saveMeasurement/', views.saveMeasurement, name='saveMeasurement'),
    path('fetchLatestMeasurement/', views.fetchLatestMeasurement, name='fetchLatestMeasurement'),
    path('fetchAllMeasurements/', views.fetchAllMeasurements, name='fetchAllMeasurements'),
    path('fetchInputTestData/', views.fetchInputTestData, name='fetchInputTestData'),
    path('fetchAverageMachine1/', views.fetchAverageMachine1, name='fetchAverageMachine1'),
    path('getPrediction/', views.getPrediction, name='getPrediction'),
    path('trainModel/', views.trainModel, name='trainModel'),
    path('fetchDatasets/', views.fetchDatasets, name='fetchDatasets'),
    path('uploadDataset/', views.uploadDataset, name='uploadDataset'),
    path('dataset_detail/<str:dataset>', views.dataset_detail, name='dataset_detail'),
    path('dataset_detail/<str:dataset>/<str:imagename>', views.dataset_plotimage, name='dataset_plotimage'),
    path('fetchModels/<str:dataset>', views.fetchModels, name='fetchModels')
] + static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)






