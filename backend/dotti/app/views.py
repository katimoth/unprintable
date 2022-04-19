from django.shortcuts import render
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.db import connection
from app.models import PREDICTION_CLIENT
from app.utils import convert_chords
from app.predict import get_prediction
import autochord
import base64
import json
import os

def getsong(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    response = {}
    
    cursor = connection.cursor()
    #named table songs for now
    cursor.execute('SELECT * FROM songs ORDER BY name ASC')
    rows = cursor.fetchall()
    for i, row in enumerate(rows):
        song = list(row)
        try:
            song[3] = json.loads(song[3])
            rows[i] = song
        except json.JSONDecodeError:
            continue
        
    response['songs'] = rows
    
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
def findguitar(request):
    if request.method != 'POST':
        return HttpResponse(status=404)
    response = {}
    data = json.loads(request.body)
    imageb64 = data.get('image')
    bounding_box = {}
    prediction = get_prediction(PREDICTION_CLIENT, imageb64).payload
    if len(prediction) > 0 and prediction[0].image_object_detection.score >= 0.9:
        vertices = prediction[0].image_object_detection.bounding_box.normalized_vertices
        bounding_box = [
            {"x": vertices[0].x,
            "y": vertices[0].y},
            {"x": vertices[1].x,
            "y": vertices[1].y}
        ]
    response = {"bounding_box": bounding_box}

    return JsonResponse(response)

