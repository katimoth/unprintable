from django.shortcuts import render
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.db import connection
from app.detection.detect_guitar import run, load_json
import autochord
import cv2
import base64
import json
import os

conversions = {
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

def getsong(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    response = {}
    
    cursor = connection.cursor()
    #named table songs for now
    cursor.execute('SELECT * FROM songs ORDER BY name ASC')
    rows = cursor.fetchall()
    #need to change once tables are set up in db
    # response['name'] = result['name']
    # response['artist'] = result['artist']
    # response['bpm'] = result['bpm']
    # response['chords'] = result['chords']
    for i, row in enumerate(rows):
        song = list(row)
        try:
            song[3] = json.loads(song[3])
            rows[i] = song
        except json.JSONDecodeError:
            continue
        
    response['songs'] = rows
    
    return JsonResponse(response)

def getmetrics(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    response = {}
    
    cursor = connection.cursor()
    #named table metrics for now
    cursor.execute('SELECT * FROM metrics')
    rows = cursor.fetchall()
    #need to change once tables are set up in db
    response['metric'] = ['TBD']
    
    return JsonResponse(response)

@csrf_exempt
def extractchord(request):
    if request.method != 'POST':
        return HttpResponse(status=404)
    response = {}
    json_data = json.loads(request.body)
    b64audio = json_data['audio']
    if os.path.exists("temp.m4a"):
        os.remove("temp.m4a")
    if os.path.exists("temp.wav"):
        os.remove("temp.wav")
    with open("temp.m4a", 'wb') as m4a_file:
        audio_bin = base64.b64decode(b64audio)
        m4a_file.write(audio_bin)
    # analysis = autochord.recognize("temp.m4a")
    os.system('ffmpeg -i temp.m4a temp.wav')
    analysis = autochord.recognize("temp.wav")
    response['chords'] = convert_chords(analysis)
    
    return JsonResponse(response)
# Create your views here.

@csrf_exempt
def getoverlay(request):
    if request.method != 'POST':
        return HttpResponse(status=404)
    response = {}
    data = json.loads(request.body)
    chord = data.get('chord')
    b64_frame = data.get('frame')
    # frame = cv2.imread("detection/images/guitar_4.png")
    if chord is None or b64_frame is None:
        return JsonResponse({'error': 'missing frame or chord'})
    if os.path.exists("overlay.png"):
        os.remove("overlay.png")
    if os.path.exists("in_file.png"):
        os.remove("in_file.png")
    with open("in_file.png", 'wb') as in_file:
        img_bin = base64.b64decode(b64_frame)
        in_file.write(img_bin)
    # process img
    frame = cv2.imread('in_file.png')
    chords = load_json("app/detection/chords.json")
    overlay = run(frame, chords[chord])
    if overlay is not None:
        cv2.imwrite('overlay.png', overlay)
        with open('overlay.png', 'rb') as out:
            b64_str = base64.b64encode(out.read())
            response['overlay'] = b64_str.decode('utf-8')
    else:
        response['overlay'] = ''
    return JsonResponse(response)

def convert_chords(chords):
  chords = [c[2] for c in chords]
  result = []
  for c in chords:
    parts = c.split(':')
    if len(parts) > 1: # valid chord
      if parts[1] == 'min':
        parts[1] = 'm'
      else:
        parts[1] = ''
      # check for conversions
      if parts[0] in conversions:
        result.append(conversions[parts[0]] + parts[1])
    result.append(''.join(parts))
  return result