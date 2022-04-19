from django.db import models
from google.cloud import automl_v1beta1

# Create your models here.

CONVERSIONS = {
  'C#': 'Db',
  'D#': 'Eb',
  'F#': 'Gb',
  'G#': 'Ab',
  'A#': 'Bb',
  'Db': 'C#',
  'Eb': 'D#',
  'Gb': 'F#',
  'Ab': 'G#',
  'Bb': 'A#',
}

PREDICTION_CLIENT = automl_v1beta1.PredictionServiceClient()
