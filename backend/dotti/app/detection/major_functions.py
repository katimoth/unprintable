# Avery Link (avlink)

# ========================================
# = Imports
# ========================================

import cv2
import numpy as np
from app.detection.minor_functions import *
from app.detection.detect_id import WRITE_IMAGES, detect

# ========================================
# = Global Variables
# ========================================

PRINT_FUNC_NAMES = False
DEBUGGING = False
REMOVING = False
DEBUG_ISOLATE_FRETS = False

# ========================================
# = Functions
# ========================================

def draw_dots(img_orig, lines, text=None, color=(0,0,255), radius=10):
    if lines is None: return img_orig
    img = img_orig.copy()
    lines = lines.astype(np.int64)
    if type(color) == list:
        i = 0
        for line in lines:
            x1, y1, x2, y2 = line
            cv2.circle(img, (x1,y1), radius=radius, color=color[i], thickness=-1)
            i += 1
            cv2.circle(img, (x2,y2), radius=radius, color=color[i], thickness=-1)
            i += 1
    else:
        for line in lines:
            x1, y1, x2, y2 = line
            cv2.circle(img, (x1,y1), radius=radius, color=color, thickness=-1)
            cv2.circle(img, (x2,y2), radius=radius, color=color, thickness=-1)
    if text is not None:
        cv2.putText(img, str(text), (5, 20), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0,0,0), 1, cv2.LINE_AA)
    return img

def draw_lines(img_orig, lines, color=(0,0,255), text=None, thickness=10):
    if lines is None: return img_orig
    img = img_orig.copy()
    lines = lines.astype(np.int64)
    if type(color) == list:
        if text is not None:
            for line, c, t in zip(lines, color, text):
                x1, y1, x2, y2 = line
                img = cv2.line(img, (x1, y1), (x2, y2), c, thickness, cv2.LINE_AA)
                img = cv2.putText(img, str(t), (x2, y2+50), cv2.FONT_HERSHEY_SIMPLEX, 1.5, c, 8, cv2.LINE_AA) # (x1-10, y1+25)
        else:
            for line, c in zip(lines, color):
                x1, y1, x2, y2 = line
                cv2.line(img, (x1, y1), (x2, y2), c, thickness, cv2.LINE_AA)
    else:
        for line in lines:
            x1, y1, x2, y2 = line
            cv2.line(img, (x1, y1), (x2, y2), color, thickness, cv2.LINE_AA)
    return img

def draw_overlay(frame, frets, chord, radius=30, color=(0,0,255, 255)):
    img = np.zeros_like(frame)
    strings, bar = get_chord_info(chord, frets)
    for loc in strings:
        if loc is None:
            continue
        cv2.circle(img, loc, radius=radius, color=color, thickness=-1)
    if bar is not None:
        cv2.line(img, bar[0], bar[1], color, radius*2, cv2.LINE_AA)
    
    return img

def within_range(lines, LINE, buffer=100):
    ret = []
    for line in lines:
        if within_line(LINE, midpointL(line), buffer):
            ret.append(line)
    return np.array(ret)

def ROI(img, buffer=275):
    main_line, _, _ = detect(img)
    _, y1, _, y2 = main_line
    roi = img[y1-buffer:y2+buffer,:].copy()
    _, m, top = detect(roi)
    roi_all = np.zeros_like(img)
    roi_all[y1-buffer:y2+buffer,:] = roi
    return roi_all, main_line, m, top

def draw_all_chords(chords, lines, img):
    print(img.shape)
    for c in chords:
        name = c + ".png"
        chord_img, strings = draw_chord(chords[c], lines, img)
        text_img = cv2.putText(chord_img.copy(), str(strings), (5,20), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0,0,0), 1, cv2.LINE_AA)
        cv2.putText(text_img, str(chords[c]), (5, text_img.shape[0]-10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0,0,0), 1, cv2.LINE_AA)
        cv2.imwrite("chords/"+name, text_img)

def draw_all_strings(lines, img):
    for i in range(len(lines)-1):
        strings = find_strings(lines, i)
        draw_dots_lines = []
        for x, y in strings:
            draw_dots_lines.append(x)
            draw_dots_lines.append(y)
        draw_dots_lines = np.array(draw_dots_lines).reshape((3,4))
        name = "stringDots/string_dots_" + str(i) + ".png"
        cv2.imwrite(name, draw_dots(img, draw_dots_lines, text=strings))

def draw_chords(song, chords, lines, img):
    for chord in song["chords"]:
        chord_img = draw_chord(chords[chord[0]], lines, img)
        name = "chords/" + chord[0] + ".png"
        cv2.imwrite(name, chord_img)

def find_frets(img, LINE, M, TOP):
    lines = find_lines(img)
    frets = isolate_frets(lines, img, TOP, LINE, M=M)
    return frets

def order_lines(lines, img, top):
    dists = []
    for line in lines:
        dists.append(int(distance(top, line)))
    dists = np.array(dists).reshape((len(dists), 1))
    lines_dist = np.hstack([lines, dists])
    lines_dist = lines_dist[lines_dist[:, -1].argsort()]
    return lines_dist

def find_lines(img):
    rho = 1
    theta = np.pi/180
    threshold = 50
    minLineLength = 100
    maxLineGap = 50

    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    edges = cv2.Canny(gray, 50, 200, apertureSize=3, L2gradient=True)
    lines = cv2.HoughLinesP(edges, rho, theta, threshold, None, minLineLength, maxLineGap)
    return lines.reshape((lines.shape[0], lines.shape[2]))

def find_parallel(lines, M, error):
    check_x = []
    for line in lines:
        x1, _, x2, _ = line
        if within_error(x1, x2, error):
            check_x.append(line)
    parallel = []
    for line in check_x:
        m = slope(line)
        if within_error_parallel(abs(m), abs(M), 12):
            parallel.append(line)
            line = "{:.3f}".format(round(m,3)) + '\t' + str(line) + '\n'
        else:
            line = "{:.3f}".format(round(m,3)) + '\t' + str(line) + '\n'
    if not parallel:
        raise Exception("No parallel lines")
    return np.array(parallel)

def isolate_frets(lines, img, TOP, LINE, M=1):
    within = within_range(lines, LINE)
    parallel = find_parallel(within, M, 125) # ERROR BUFFER
    outliers_rm = remove_outliers(parallel)
    neighbors_rm1 = remove_neighbors(outliers_rm, TOP, img, 50) # NEIGHBOR LIMIT
    neighbors_rm2 = remove_neighbors(neighbors_rm1, TOP, img, 100)
    resized, sides = resize_frets(neighbors_rm2, img)
    missed_found = find_missed(resized, img, TOP, sides, 50)    
    return missed_found

def find_missed(lines, img, top, sides, buffer):
    ordered = order_lines(lines, img, top)[:,:-1]
    prev_line = ordered[0]
    prev_dist = distance(top, prev_line)
    new_lines = [prev_line]
    prev_mid = midpointL(prev_line)
    buffer = 25
    for curr_line in ordered[1:]:
        curr_dist = distance(prev_mid, curr_line)
        if not within_buffer(curr_dist, prev_dist, buffer):
            estimated_line = resize_fret(merge_lines((np.vstack([prev_line, curr_line]))), sides).astype(int)
            new_lines.append(estimated_line)
            prev_dist = distance(top, estimated_line)
            prev_line = estimated_line
        else:
            prev_dist = curr_dist
            prev_line = curr_line
        prev_mid = midpointL(prev_line)
        new_lines.append(curr_line)
    return np.vstack(new_lines)

def resize_frets(lines, img):
    sides = extrapolate_sides(lines)
    resized = []
    for line in lines:
        resized.append(resize_fret(line, sides))
    return np.array(resized).astype(int), sides

def remove_neighbors(lines, top, img, error):
    neighbor_removed = lines.copy()
    i = 0
    name = "removing/"+ str(i).zfill(2) + "_" + str(neighbor_removed.shape[0]) + ".png"
    if REMOVING:
        cv2.imwrite(name, draw_lines(img, neighbor_removed))
    for line in neighbor_removed:
        i += 1
        neighbor_removed = find_neighbors(neighbor_removed, line, top, error)
        name = "removing/"+ str(i).zfill(2) + "_" + str(neighbor_removed.shape[0]) + ".png"
        if REMOVING:
            cv2.imwrite(name, draw_lines(img, neighbor_removed))
    return neighbor_removed

def find_neighbors(lines, line, top, error):
    d = distance(top, line)
    all_d = np.array([distance(top, i) for i in lines])
    neighbors = within_error(all_d, d, error)
    new_line = remake_fret(lines[neighbors])
    if new_line is not None:
        lines = np.delete(lines, neighbors, axis=0)
        lines = np.vstack((lines, new_line))
    return lines

def remake_fret(lines):
    if lines.shape[0] == 0:
        return None
    if lines.shape[0] == 1:
        return fix_size(lines)
    merged = merge_lines(lines)
    return merged

def remove_outliers(lines):
    midPos = np.array([midpointL(i) for i in lines])[:,1].reshape((len(lines), 1))
    midPos_rm = outliers(lines, midPos, 1)
    
    return midPos_rm
