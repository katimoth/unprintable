# Avery Link (avlink)

'''
HOW TO USE

run():
    * input frame and desired chord
    * if run returns None --> guitar not detected try again
    * else run returns transparent overlay

combine_overlay()
    * input frame and overlay gotten from run
    * returns image of frame with overlay
'''

# ========================================
# = Imports
# ========================================

import cv2
from time import time
from json import load
from app.detection.major_functions import ROI, find_frets, draw_overlay

# ========================================
# = Main
# ========================================

def run(frame, chord=None):
    roi = detect_guitar(frame)
    if roi is None:
        print('Not found')
        return None
    frame_alpha = cv2.cvtColor(frame, cv2.COLOR_RGB2RGBA)
    i
    placed = place_chord(roi, chord, frame_alpha)
    return placed.T

def combine_overlay(frame, overlay):
    frame_alpha = cv2.cvtColor(frame, cv2.COLOR_RGB2RGBA)
    return cv2.addWeighted(frame_alpha, 1, overlay, 1, 0)

# ========================================
# = Helper
# ========================================

def detect_guitar(frame):
    try:
        return ROI(frame)
    except:
        return None

def place_chord(roi, chord, frame):
    roi, top_line, M, top = roi
    frets = find_frets(roi, top_line, M, top)
    return draw_overlay(frame, frets, chord)

def load_json(filename):
    with open(filename, 'r') as file:
        data = load(file)
    return data

def display_time(start, end):
    hours, rem = divmod(end-start, 3600)
    minutes, seconds = divmod(rem, 60) 
    time = "{:0>2}:{:0>2}:{:05.2f}".format(int(hours),int(minutes),seconds)
    print("Elapsed Time: ", time)

# ========================================
# = Run Script
# ========================================

if __name__ == '__main__':
    start = time()
    chords = load_json("chords.json")
    frame = cv2.imread("images/guitar_4.jpg")
    overlay = run(frame, chords['C'])
    display_time(start, time())
    if overlay is not None:
        cv2.imwrite('overlay.png', overlay)
        cv2.imwrite('combined.png', combine_overlay(frame, overlay))

