# forms.py
from django import forms
from django.core.exceptions import ValidationError
from .models import UploadedFile

class FileUploadForm(forms.ModelForm):
    class Meta:
        model = UploadedFile
        fields = ['file']

    def clean_file(self):
        file = self.cleaned_data.get('file')
        if file:
            # Check the file extension
            allowed_extensions = ['.csv', '.xlsx']
            if not any(file.name.endswith(ext) for ext in allowed_extensions):
                raise ValidationError('Only CSV or XLSX files are allowed.')

            # Optionally, you can also check the file content type
            allowed_content_types = ['application/vnd.ms-excel', 'text/csv', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']
            if file.content_type not in allowed_content_types:
                raise ValidationError('Invalid file type. Please upload a valid CSV or XLSX file.')

        return file
