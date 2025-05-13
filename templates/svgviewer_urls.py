from django.urls import path
from rest_framework.routers import DefaultRouter
from .views import SVGFileViewSet, ConversionTaskViewSet

router = DefaultRouter()
router.register(r'svg-files', SVGFileViewSet, basename='svgfile')
router.register(r'conversion-tasks', ConversionTaskViewSet, basename='conversiontask')

urlpatterns = router.urls