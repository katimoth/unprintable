from app.models import CONVERSIONS

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
      if parts[0] in CONVERSIONS:
        result.append(CONVERSIONS[parts[0]] + parts[1])
    result.append(''.join(parts))
  return result
      


# if __name__ == '__main__':
#   print(convert_chords([[0.0, 0.37151927437641724, "N"], [0.0, 0.37151927437641724, "D#:min"], [0.37151927437641724, 3.1114739229024946, "G#:maj"]]))
