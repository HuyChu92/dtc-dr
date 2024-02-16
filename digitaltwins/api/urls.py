from django.urls import path
from . import views
from django.conf.urls.static import static
from django.conf import settings

urlpatterns = [
    path('', views.home, name='home'),
    path('getPrediction/', views.getPrediction, name='getPrediction'),
    path('trainModel/', views.trainModel, name='trainModel'),
    path('fetchDatasets/', views.fetchDatasets, name='fetchDatasets'),
    path('uploadDataset/', views.uploadDataset, name='uploadDataset'),
    path('dataset_detail/<str:dataset>', views.dataset_detail, name='dataset_detail'),
    path('dataset_detail/<str:dataset>/<str:imagename>', views.dataset_plotimage, name='dataset_plotimage'),
    path('fetchModels/<str:dataset>', views.fetchModels, name='fetchModels'),
    path('fetchScatterplot/<str:dataset>/<str:model>/<str:imagename>', views.fetchScatterplot, name='fetchScatterplot')
] + static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)






