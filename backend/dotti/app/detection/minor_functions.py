# Avery Link (avlink)

# ========================================
# = Imports
# ========================================

import cv2
import numpy as np
import glob
import os
import json
from random import randint

# ========================================
# = Global Variables
# ========================================

DEBUGGING = False

# ========================================
# = Functions
# ========================================

def within_buffer(curr_dist, prev_dist, buffer):
    one = curr_dist
    two = prev_dist + buffer
    return one < two

def resize_fret(line, sides):
    x1, y1 = intersection(line, sides[0])
    x2, y2 = intersection(line, sides[1])
    return np.array([x1, y1, x2, y2])

def extrapolate_sides(lines):
    lengths = [line_length(i) for i in lines]
    top = top_outliers(lines, lengths)
    x1, y1, x2, y2 = np.split(top, 4, axis=1)
    m1, c1 = lstsq(x1, y1)
    m2, c2 = lstsq(x2, y2)
    
    min_x1, _, min_x2, _ = np.min(lines, axis=0)
    max_x1, _, max_x2, _ = np.max(lines, axis=0)

    min_y1 = int((min_x1 * m1 + c1)[0])
    min_y2 = int((min_x2 * m2 + c2)[0])
    max_y1 = int((max_x1 * m1 + c1)[0])
    max_y2 = int((max_x2 * m2 + c2)[0])

    one = np.array([min_x1, min_y1, max_x1, max_y1]).astype(int)
    two = np.array([min_x2, min_y2, max_x2, max_y2]).astype(int)

    return np.vstack([one, two])

def top_outliers(lines, test, rounds=2, mean_adj=0):
    mean = np.mean(test)
    mean -= mean*mean_adj
    zero_based = test - mean
    
    for _ in range(1, rounds):
        mean = np.mean([i for i in zero_based if i > 0])
        mean -= mean*mean_adj
        zero_based = zero_based - mean
    
    top = (zero_based > 0)

    return lines[top]

def outliers(lines, test, max_deviations):
    mean = np.mean(test)
    std_dev = np.std(test)
    zero_based = abs(test - mean)
    outliers = (zero_based < max_deviations * std_dev).reshape(len(test),)
    return lines[outliers]

def within_line(LINE, point, buffer):
    _, Y1, _, Y2 = LINE
    _, y = point
    y1 = min(Y1, Y2)-buffer
    y2 = max(Y1, Y2)+buffer
    
    return y1 <= y <= y2

def draw_chord(chord, lines, orig_img, radius=5, color=(0,0,255)):
    img = orig_img.copy()
    strings, bar = get_chord_info(chord, lines)
    for loc in strings:
        if loc is None:
            continue
        cv2.circle(img, loc, radius=radius, color=color, thickness=-1)
    if bar is not None:
        cv2.line(img, bar[0], bar[1], color, 3, cv2.LINE_AA)
    return img, strings

def get_chord_info(chord, lines):
    fingers, bar = chord
    strings = []
    for i in range(len(fingers)):
        f = fingers[i]
        if f is None:
            strings.append(None)
        else:
            strings.append(find_strings(lines, f)[i])
    if bar is not None:
        bar_strings = find_strings(lines, bar)
        bar = (bar_strings[0], bar_strings[-1])
    return strings, bar

def find_strings(frets, index, num_strings=6):
    x11, y11, x21, y21 = frets[index]
    x12, y12, x22, y22 = frets[index+1]

    x1_m, y1_m = midpointP(x11, y11, x12, y12)
    x2_m, y2_m = midpointP(x21, y21, x22, y22)

    u = unit_vector(x1_m, y1_m, x2_m, y2_m, num_strings)
    strings = []
    for d in range(num_strings):
        strings.append(add_distance(x1_m, y1_m, d, u))
    return strings

def add_distance(x1, y1, d, u):
    start = np.array([x1, y1])
    adding = np.multiply(u, d)
    x, y = np.add(start, adding)
    return (x, y)

def unit_vector(x1, y1, x2, y2, num_strings):
    v1 = np.array([x1, y1])
    v2 = np.array([x2, y2])
    v = abs(np.subtract(v1, v2))
    u = v / (num_strings-1)
    return np.rint(u).astype(int)

def load_json(filename):
    with open(filename, 'r') as file:
        data = json.load(file)
    return data

def rand_color():
    return (randint(0, 255), randint(0, 255), randint(0, 255))

def lstsq(x, y):
    ones = np.ones(len(x)).reshape(len(x), 1)
    A = np.hstack([x, ones])
    m, c = np.linalg.lstsq(A, y, rcond=None)[0]
    return m, c

def slope(line):
    line = fix_size(line.astype(np.int64))
    x1, y1, x2, y2 = line
    rise = y2-y1
    run = x2-x1
    if run == 0:
        return 1
    else:
        return rise / run

def angular_dist(m1, m2):
    t1 = np.arctan(m1)
    t2 = np.arctan(m2)
    one = np.degrees(abs(t1 - t2))
    two = np.degrees(np.pi - abs(t1 - t2))
    if one < two:
        return one
    else:
        return two

def intercept(line):
    m = slope(line)
    x, y, _, _ = fix_size(line)
    return y - (m * x)

def intersection(line1, line2):
    m1 = slope(line1)
    m2 = slope(line2)
    b1 = intercept(line1)
    b2 = intercept(line2)

    x = (b1-b2) / (m2-m1)
    y = m1 * x + b1
    return (x, y)

def fix_size(line):
    if line.shape == (1,4):
        return line.reshape(4,)
    return line

def midpointP(x1, y1, x2, y2):
    x = int((x1 + x2)/2)
    y = int((y1+y2)/2)
    return x, y

def midpointL(line):
    x1, y1, x2, y2 = line
    x = int((x1 + x2)/2)
    y = int((y1+y2)/2)
    return x, y

def distance(point, line):
    Lx, Ly = midpointL(fix_size(line))
    Px, Py = point
    return distance_helper(Lx, Ly, Px, Py)

def distance_helper(x1, y1, x2, y2):
    return np.sqrt(((x1-x2)**2) + ((y1-y2)**2))

def line_length(line):
    line = fix_size(line)
    x1, y1, x2, y2 = line
    return distance_helper(x1, y1, x2, y2)

def get_sides(lines, M):
    if within_error(M, 1, error=0.1) or within_error(M, 0, error=0.1):
        return sides_VH(lines)
    else:
        return sides_lstsq(lines)

def sides_VH(lines):
    maxs = np.max(lines, axis=0)
    mins = np.min(lines, axis=0)
    one = np.array([mins[0], maxs[3], maxs[0], mins[3]])
    two = np.array([mins[2], mins[1], maxs[2], maxs[1]])
    sides = np.vstack([one, two])
    return sides

'''
def sides_lstsq(lines):
    x1, y1, x2, y2 = np.split(lines, 4, axis=1)
    one = lstsq(x1, y1)
    two = lstsq(x2, y2)
    return np.vstack([one, two])

def lstsq(x, y):
    ones = np.ones(len(x)).reshape(len(x), 1)
    A = np.hstack([x, ones])
    m, c = np.linalg.lstsq(A, y, rcond=None)[0]
    Y = x * m + c
    x1, x2 = np.max(x), np.min(x)
    y1, y2 = np.max(Y), np.min(Y)
    return np.array([x1, y1, x2, y2]).astype(np.int64)
'''

def lstsq_line(x, y):
    m, c = lstsq(x, y)
    Y = x * m + c
    x1, x2 = np.max(x), np.min(x)
    y1, y2 = np.max(Y), np.min(Y)
    return np.array([x1, y1, x2, y2]).astype(int)

def sides_lstsq(lines):
    x1, y1, x2, y2 = np.split(lines, 4, axis=1)
    one = lstsq_line(x1, y1)
    two = lstsq_line(x2, y2)
    return np.vstack([one, two])

def within_error(a, b, error, debugging=False):
    return abs(a - b) <= error

def within_error_parallel(a, b, error=10):
    dist = angular_dist(a, b)
    if within_error(dist, 90, error=error):
        return True
    return within_error(dist, 0, error=error)

def remove_dir(directory):
    files = glob.glob(directory+"*")
    for file in files:
        os.remove(file)

def merge_lines(lines):
    return np.mean(lines, axis=0).reshape((lines.shape[1],)).astype(int)

def display_time(start, end):
    hours, rem = divmod(end-start, 3600)
    minutes, seconds = divmod(rem, 60) 
    time = "{:0>2}:{:0>2}:{:05.2f}".format(int(hours),int(minutes),seconds)
    print("Elapsed Time: ", time)
