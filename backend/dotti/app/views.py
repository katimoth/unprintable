from django.shortcuts import render
from django.http import JsonResponse, HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.db import connection
import json

def getsong(request):
    if request.method != 'GET':
        return HttpResponse(status=404)
    response = {}
    
    cursor = connection.cursor()
    #named table songs for now
    cursor.execute('SELECT * FROM songs')
    rows = cursor.fetchall()
    #need to change once tables are set up in db
    # response['name'] = result['name']
    # response['artist'] = result['artist']
    # response['bpm'] = result['bpm']
    # response['chords'] = result['chords']
    response['song'] = rows
    
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
# Create your views here.
#something 
# Create your views here.
