; docformat = 'rst'

;+
;
; 3D Earth-Moon system simulation, animation and visualization using IDL
; Graphics Object Classes. The visualized celestial bodies are textured.
; The visualized celestial bodies are textured.
;
; :Examples:
;   Run simulation and save visualization as video to file::
;
;      IDL> IDLViz,/VIDEO
;
; :Author:
;   KrizTioaN (christiaanboersma@hotmail.com)
;
; :Copyright:
;   BSD-3 licensed
;
; :History:
;   Changes::
;
;     07-17-2021
;     Initial commit. Christiaan Boersma.
;-


;+
; Visualize Earth-Moon system simulation in 3D-space.
;
;
; :Keywords:
;   FILENAME: in, optional, type=str
;     PNG-filename to write to, defaults to 'IDLViz.png'.
;   VIEW: in, optional, type=bool
;     View model with XOBJVIEW.
;   ANIMATION: in, optional, type=bool
;     Animate the simulation for 1401 time steps.
;   VIDEO: in, optional, type=bool
;     Save the visualization as video to 'IDLViz.mp4'.
;
; :Categories:
;   VISUALIZATION
;-
PRO IDLViz,FILENAME=FILENAME,VIEW=VIEW,ANIMATION=ANIMATION,VIDEO=VIDEO

  MESH_OBJ,4,vertex,poly,REPLICATE(0.10, 101, 101)

  vector = FINDGEN(101)/100.
  texure_coordinates = FLTARR(2, 101, 101)
  texure_coordinates[0, *, *] = vector # REPLICATE(1., 101)
  texure_coordinates[1, *, *] = REPLICATE(1., 101) # vector

  grView = OBJ_NEW('IDLgrView', PROJECTION=2, VIEWPLANE_RECT=[-0.5, -0.5, 1, 1], ZCLIP=[0.5, -0.5], EYE=100, /DOUBLE)


  ;;xtitle = OBJ_NEW('IDLgrText', 'x-axis')
  ;;ytitle = OBJ_NEW('IDLgrText', 'y-axis')
  ;;ztitle = OBJ_NEW('IDLgrText', 'z-axis')


  grEarthModel = OBJ_NEW('IDLgrModel')

  grEarth = OBJ_NEW('IDLgrPolygon', DATA=vertex, POLYGONS=poly, SHADING=1, ALPHA_CHANNEL=1.0)

  READ_JPEG,'maps/map_earth.jpg',map_texture

  grMapEarth = OBJ_NEW('IDLgrImage', map_texture, INTERLEAVE=0)

  grEarth->SetProperty,TEXTURE_COORD=texure_coordinates,TEXTURE_MAP=grMapEarth,COLOR=[255, 255, 255],/TEXTURE_INTERP

  grEarthModel->Add,grEarth

  grEarthModel->Rotate,[1,0,0],270

  grEarthModel->Rotate,[0,0,1],23.5

  grView->Add,grEarthModel



  T3D,/RESET,SCALE=[1, 1, 1] / 3.0

  grMoonModel = OBJ_NEW('IDLgrModel')

  grMoonModelContainer = OBJ_NEW('IDLgrModel')

  ;;xaxis = OBJ_NEW('IDLgrAxis', DIRECTION=0, RANGE=[-0.5, 0.5], TITLE=xtitle, COLOR=[255,255,255])
  ;;yaxis = OBJ_NEW('IDLgrAxis', DIRECTION=1, RANGE=[-0.5, 0.5], TITLE=ytitle, COLOR=[255,255,255])
  ;;zaxis = OBJ_NEW('IDLgrAxis', DIRECTION=2, RANGE=[-0.5, 0.5], TITLE=ztitle, COLOR=[255,255,255])

  ;;grMoonModelContainer->Add,xaxis
  ;;grMoonModelContainer->Add,yaxis
  ;;grMoonModelContainer->Add,zaxis

  grMoonModelContainer->Rotate,[1,0,0],30

  grMoon = OBJ_NEW('IDLgrPolygon', DATA=VERT_T3D(vertex), POLYGONS=poly, SHADING=1, ALPHA_CHANNEL=1.0)

  READ_JPEG,'maps/map_moon.jpg',map_moon

  grMapMoon = OBJ_NEW('IDLgrImage', map_moon, INTERLEAVE=0)

  grMoon->SetProperty,TEXTURE_COORD=texure_coordinates,TEXTURE_MAP=grMapMoon,COLOR=[255, 255, 255],/TEXTURE_INTERP

  grMoonModel->Add,grMoon

  grMoonModel->Rotate,[1,0,0],270

  grMoonModel->Rotate,[0,0,1],1.5

  grMoonModelContainer->Add,grMoonModel

  grMoonModelContainer->Translate,-0.3, 0, 0.3

  grView->Add,grMoonModelContainer



  grModel = OBJ_NEW('IDLgrModel')

  READ_JPEG,'maps/stars.jpg',stars

  grStars = OBJ_NEW('IDLgrImage', stars, INTERLEAVE=0, LOCATION=[-0.5,-0.5,-0.49], DIMENSIONS=[1,1], DEPTH_TEST_DISABLE=2)

  grModel->Add,grStars



  grAmbient = OBJ_NEW('IDLgrLight', COLOR=[255,255,255], INTENSITY=0.50)

  grModel->Add,grAmbient

  grDirectional = OBJ_NEW('IDLgrLight', TYPE=2, COLOR=[255,255,100], DIRECTION=[0,0,0], LOCATION=[-1,0,0])

  grModel->Add,grDirectional

  grView->Add,grModel



  grBuffer = OBJ_NEW('IDLgrBuffer', DIMENSIONS=400*[1, 1], RESOLUTION=2.54/[300, 300])

  grBuffer->Draw,grView

  grImage = grBuffer->Read()

  grImage->GetProperty,DATA=image

  IF NOT KEYWORD_SET(FILENAME) THEN FILENAME = 'IDLViz.png'

  WRITE_PNG,FILENAME,image



  IF KEYWORD_SET(VIEW) THEN XOBJVIEW,grModel,/MODAL



  IF KEYWORD_SET(ANIMATION) OR KEYWORD_SET(VIDEO) THEN BEGIN

     IF KEYWORD_SET(ANIMATION) THEN grWindow = OBJ_NEW('IDLgrWindow', DIMENSIONS=[900, 900])

     IF KEYWORD_SET(VIDEO) THEN BEGIN

        video = IDLffVideoWrite('IDLViz.mp4')

        stream = video.addVideoStream(400, 400, 60, BIT_RATE=1024*8)

     ENDIF

     FOR i = 0L, 1401 DO BEGIN

        grEarthModel->Rotate,[0,0,1],-23.5

        grEarthModel->Rotate,[0,1,0],3.6

        grEarthModel->Rotate,[0,0,1],23.5

        grMoonModel->Rotate,[0,0,1],-1.5

        grMoonModel->Rotate,[0,1,0],3.6 / 28.0

        grMoonModel->Rotate,[0,0,1],1.5

        grMoonModelContainer->Rotate,[1,0,0],-30

        grMoonModelContainer->Rotate,[0,1,0],3.6 / 28.0

        grMoonModelContainer->Rotate,[1,0,0],30

        IF KEYWORD_SET(ANIMATION) THEN grWindow->Draw,grView

        IF KEYWORD_SET(VIDEO) THEN BEGIN

           grBuffer->Draw,grView

           grImage = grBuffer->Read()

           grImage->GetProperty,DATA=image

           timecode = video->Put(stream, REVERSE(image, SIZE(image, /N_DIMENSIONS)))

        ENDIF

     ENDFOR

     IF KEYWORD_SET(ANIMATION) THEN OBJ_DESTROY,grWindow

     IF KEYWORD_SET(VIDEO) THEN OBJ_DESTROY,video

  ENDIF

  ;OBJ_DESTROY,[xtitle, ytitle, ztitle]

  OBJ_DESTROY,[grView, grBuffer, grImage]

END
