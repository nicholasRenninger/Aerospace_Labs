Upon Running rocket_tracker_gui.m:

- Select the video file that you
  wish to process
-----------------------------------
- Press the "Grab Position"
  button in order to enable a
  cursor to select the water
  rocket position in the current
  frame. The button can be
  pressed multiple times on a
  single frame, but only the most
  recent selection will be saved.
-----------------------------------
- Press the "Next Frame" button
  in order to move on to the
  next frame.
-----------------------------------
- It should be noted that each
  time the "Next Frame" button is
  pressed, the most recent x- and
  y-positions (in pixels) are saved
  to the .mat file specified in the
  "Save-file Name" field.
-----------------------------------
- When the last image in the folder
  is processed, a status message
  will appear at the bottom of the
  GUI stating this. It is now safe
  to close the GUI and all data
  can be found in the .mat file

OTHER USAGE NOTES:
- The GUI automatically concatenates x- and y-position data points to the
  .mat file specified in the "Save-file name" field (if it exists). So if
  multiple runs are being done, be sure to change the file name from the
  default to avoid giving yourself more work!