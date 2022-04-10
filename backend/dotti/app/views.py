from django.shortcuts import render
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.db import connection
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
    #need to change once tables are set up in db
    # response['name'] = result['name']
    # response['artist'] = result['artist']
    # response['bpm'] = result['bpm']
    # response['chords'] = result['chords']
    for i, row in enumerate(rows):
        song = list(row)
        song[3] = json.loads(song[3])
        rows[i] = song
        
    response['songs'] = rows
    
    return JsonResponse(response)

@csrf_exempt
def postaccuracy(request):
    if request.method != 'POST':
        return HttpResponse(status=404)
    json_data = json.loads(request.body)
    #need to get accuracy info from json data (not sure what the info includes yet)
    cursor = connection.cursor()
    #need to add accuracy info into the corresponding table of the db
    #cursor.execute(...)
    return JsonResponse({})

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
    response['chords'] = analysis
    
    return JsonResponse(response)
# Create your views here.
