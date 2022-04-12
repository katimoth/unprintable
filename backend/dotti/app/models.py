from django.db import models
from app.detection.detect_guitar import load_json

# Create your models here.
CHORDS = load_json("app/detection/chords.json")

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

OVERLAY_CACHE = {}