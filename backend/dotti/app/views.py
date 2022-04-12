from django.shortcuts import render
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.db import connection
from app.models import CHORDS, OVERLAY_CACHE
from app.detection.detect_guitar import run
from app.utils import convert_chords
from PIL import Image
import autochord
import cv2
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

def clearcache(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    response = {}
    num_chords = len(OVERLAY_CACHE)
    OVERLAY_CACHE.clear()
    if os.path.exists("in_file.png"):
        os.remove("in_file.png")
    response['message'] = f'{num_chords} chords cleared'
    
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
    detected = data.get('detected')
    chord = data.get('chord')
    b64_frame = data.get('frame')
    # frame = cv2.imread("detection/images/guitar_4.png")
    if chord is None or detected is None or (b64_frame is None and detected == '0'):
        return JsonResponse({'error': 'missing params'})
    # check cache
    if chord in OVERLAY_CACHE:
        return JsonResponse({'overlay': OVERLAY_CACHE[chord]})
    # if os.path.exists("overlay.jpg"):
    #     os.remove("overlay.jpg")
    # convert input img to jpeg
    if detected == '0':
        with open("in_file.png", 'wb') as in_file:
            img_bin = base64.b64decode(b64_frame)
            in_file.write(img_bin)
    if detected == '1' and not os.path.exists('in_file.png'):
        return JsonResponse({'error': 'No previous detection found. Try setting detected to False.'})
    # process img
    frame = cv2.imread('in_file.png')
    overlay = run(frame, CHORDS[chord])
    if overlay is not None:
        cv2.imwrite('overlay.png', overlay)
        im1 = Image.open('overlay.png')
        im1.save('overlay.jpg')
        with open('overlay.jpg', 'rb') as out:
            b64_str = base64.b64encode(out.read())
            decoded = b64_str.decode('utf-8')
            response['overlay'] = decoded
            OVERLAY_CACHE[chord] = decoded
    else:
        response['overlay'] = 'could not find an overlay'
    return JsonResponse(response)
