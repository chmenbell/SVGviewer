from django.db import models
from django.contrib.auth import get_user_model
User = get_user_model()
import os

class SVGFile(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    original_file = models.FileField(upload_to='uploads/')
    converted_svg = models.FileField(upload_to='conversions/', null=True, blank=True)
    upload_date = models.DateTimeField(auto_now_add=True)
    conversion_date = models.DateTimeField(null=True, blank=True)
    file_name = models.CharField(max_length=255)
    file_size = models.IntegerField()
    
    def save(self, *args, **kwargs):
        if not self.file_name:
            self.file_name = os.path.basename(self.original_file.name)
        super().save(*args, **kwargs)

class ConversionTask(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('processing', 'Processing'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
    ]
    
    svg_file = models.OneToOneField(SVGFile, on_delete=models.CASCADE)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    start_time = models.DateTimeField(auto_now_add=True)
    end_time = models.DateTimeField(null=True, blank=True)
    error_message = models.TextField(null=True, blank=True)