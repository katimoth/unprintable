# Avery Link (avlink)

# ========================================
# = Imports
# ========================================

import time
import numpy as np
import cv2
from app.detection.minor_functions import *
from collections import defaultdict
from itertools import zip_longest

# ========================================
# = Global Variables
# ========================================

IMAGE_PATH = "images/guitar_4.png"

ID_COLOR_MIN = (0, 0, 247)
ID_COLOR_MAX = (170, 170, 255)
WRITE_IMAGES = False

# ========================================
# = Main
# ========================================

def main():
    start_time = time.time()
    img = cv2.imread(IMAGE_PATH)
    line, m, top = detect(img)
    display_time(start_time, time.time())

def detect(img):
    mask = cv2.inRange(img, ID_COLOR_MIN, ID_COLOR_MAX)
    for _ in range(3):
        mask = cv2.medianBlur(mask, 5)
    
    locs = np.array(np.nonzero(mask))
    #locs, mask = remove_bottom_outliers(locs.T, mask)
    #cv2.imwrite('mask.png', mask)
    mask = fill_in(locs, mask)
    rect = write_cnt(mask)
    main_line = find_middle(rect, img)
    main_line = main_line.reshape(4,)
    m = slope(main_line)
    top = midpointL(main_line)
    return main_line, m, top

# ========================================
# = Helper Functions
# ========================================

def remove_bottom_outliers(locs, mask, max_deviations=1):
    dists = np.array([distance_helper(0,0,point[0],point[1]) for point in locs])
    outliers_rm = top_outliers(locs, dists, rounds=1, mean_adj=0.5)
    mask = np.zeros_like(mask)
    mask[outliers_rm[:,0],outliers_rm[:,1]] = 255
    return outliers_rm, mask

def find_middle(rect, img):
    middle = (int(img.shape[0]/2), int(img.shape[1]/2))
    rect_sort = rect[rect[:, 0].argsort()]
    closer1 = abs(middle[0]-rect_sort[0,0]) < abs(middle[0]-rect_sort[-1,0])
    if closer1:
        line = np.array([rect_sort[0], rect_sort[1]]).reshape((1,4))
    else:
        line = np.array([rect_sort[-2], rect_sort[-1]]).reshape((1,4))

    return line

def fill_in(locs, mask):
    locs_x = np.unique(locs[0])
    locs_y = np.unique(locs[1])
    mins_x = [[i, find_min(i, locs, 0, 1)] for i in locs_x]
    mins_y = [[i, find_min(i, locs, 1, 0)] for i in locs_y]
    maxs_x = [[i, find_max(i, locs, 0, 1)] for i in locs_x]
    maxs_y = [[i, find_max(i, locs, 1, 0)] for i in locs_y]

    xs = {locs_x[i] : [maxs_x[i][1], mins_x[i][1]] for i in range(len(locs_x))}
    ys = {locs_y[i] : [maxs_y[i][1], mins_y[i][1]] for i in range(len(locs_y))}

    mask = fill(mask, xs, ys)
    return mask

def find_min(value, locs, row, other):
    indices = np.argwhere(locs[row]==value)
    return np.min(locs[other,indices])

def find_max(value, locs, row, other):
    indices = np.argwhere(locs[row]==value)
    return np.max(locs[other,indices])

def get_fill(ones, twos):
    ret_ones = defaultdict(list)
    ret_twos = defaultdict(list)
    for o, t in zip_longest(ones, twos, fillvalue=None):
        if o is not None:
            temp_t = ones[o]
            ret_ones[o] = [max(temp_t), min(temp_t)]
        if t is not None:
            temp_o = twos[t]
            ret_twos[t] = [max(temp_o), min(temp_o)]
    return ret_ones, ret_twos

def fill(arr, xs, ys):
    for x, y in zip_longest(xs, ys, fillvalue=None):
        if x is not None:
            y_max, y_min = xs[x]
            arr[x,y_min:y_max] = 255
        if y is not None:
            x_max, x_min = ys[y]
            arr[x_min:x_max,y] = 255
    return arr

def sort_lines(lines):
    x1 = lines[lines[:, 0].argsort()]
    y1 = lines[lines[:, 1].argsort()]
    x2 = lines[lines[:, 2].argsort()]
    y2 = lines[lines[:, 3].argsort()]
    return x1, y1, x2, y2

def write_cnt(img):
    contours = cv2.findContours(img, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)[0]
    img = cv2.cvtColor(img, cv2.COLOR_GRAY2BGR)
    for i in contours:
            epsilon = 0.05*cv2.arcLength(i, True)
            approx = cv2.approxPolyDP(i, epsilon, True)
            if len(approx) == 4:
                return approx.reshape((4,2))
    #

def find_lines(img):
    rho = 1             # 1
    theta = np.pi/180   # np.pi/180
    threshold = 50      # 50
    minLineLength = 50  # 50
    maxLineGap = 10     # 10

    edges = cv2.Canny(img, 75, 100)
    lines = cv2.HoughLinesP(edges, rho, theta, threshold, None, minLineLength, maxLineGap)
    return lines.reshape((lines.shape[0], lines.shape[2]))

def display_time(start, end):
    hours, rem = divmod(end-start, 3600)
    minutes, seconds = divmod(rem, 60) 
    time = "{:0>2}:{:0>2}:{:05.2f}".format(int(hours),int(minutes),seconds)
    print("Elapsed Time: ", time)

# ========================================
# = Run Script
# ========================================

if __name__ == "__main__":
    main()