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
    path('fetchAverageMachine1/', views.fetchAverageMachine1, name='fetchAverageMachine1'),
] + static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)






