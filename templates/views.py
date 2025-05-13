from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import api_view, action
from django.shortcuts import get_object_or_404
from .models import SVGFile, ConversionTask
from .serializers import SVGFileSerializer, ConversionTaskSerializer
from django.core.files.base import ContentFile
import vsdx
from svglib.svglib import svg2rlg
from reportlab.graphics import renderPM
import os
import logging

logger = logging.getLogger(__name__)

@api_view(['GET'])
def auth_check(request):
    if request.user.is_authenticated:
        return Response({'authenticated': True})
    return Response({'authenticated': False}, status=401)

class SVGFileViewSet(viewsets.ModelViewSet):
    queryset = SVGFile.objects.all()
    serializer_class = SVGFileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return self.queryset.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    @action(detail=True, methods=['post'])
    def convert_to_svg(self, request, pk=None):
        svg_file = get_object_or_404(SVGFile, pk=pk, user=request.user)
        
        task = ConversionTask.objects.create(
            svg_file=svg_file,
            status='processing'
        )
        
        try:
            file_path = svg_file.original_file.path
            logger.debug(f"Intentando convertir archivo: {file_path}")
            
            if file_path.endswith('.vsdx'):
                with vsdx.VsdxFile(file_path) as vsdx_file:
                    svg_content = vsdx_file.to_svg()
            elif file_path.endswith(('.drawio', '.xml')):
                svg_content = "<svg>...</svg>"  # Lógica para DrawIO
            else:
                raise ValueError("Formato de archivo no soportado")
            
            conversion_dir = os.path.join(os.getcwd(), 'media', 'conversions')
            os.makedirs(conversion_dir, exist_ok=True)
            
            svg_filename = f"{os.path.splitext(svg_file.file_name)[0]}.svg"
            svg_path = os.path.join('conversions', svg_filename)
            
            svg_file.converted_svg.save(svg_path, ContentFile(svg_content))
            svg_file.save()
            
            task.status = 'completed'
            task.save()
            
            return Response({
                "status": "completed",
                "svg_url": svg_file.converted_svg.url
            })
            
        except Exception as e:
            logger.error(f"Error en conversión: {str(e)}")
            task.status = 'failed'
            task.error_message = str(e)
            task.save()
            return Response(
                {"error": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

class ConversionTaskViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = ConversionTaskSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return ConversionTask.objects.filter(svg_file__user=self.request.user)