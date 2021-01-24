extensions [ profiler ]

globals [ year day hour day_length world_diameter day_range speed velocity count_intruders hours_before_expulsion ]

breed [ defenders defender ]
breed [ intruders intruder ]

turtles-own [ activity ]

defenders-own [ chasee ]

intruders-own [ age chaser ]

patches-own [ world? food? nutrients depleted ]

to setup

  create-world

  set-globals

  create-defenders number_parties [
    set color blue
    set size 1
    set label-color blue - 2
    let start one-of patches with [ world? ] setxy [ pxcor ] of start [ pycor ] of start
    set hours_before_expulsion [ ]
    set activity "roaming"
    set chasee nobody
    set size world_diameter * 3
  ]

  set hour 1
  set day 1
  set year 1

end

to go

  tick-advance 1

  ifelse hour = 24 [
    set hour 1
    ifelse day = 365 [
      set day 1
    set year year + 1 ] [
      set day day + 1 ] ] [
    set hour hour + 1 ]

  ; stop the simulation if no defenders or fedefenders AND advance time
  if not any? defenders [ stop ]
  if not any? patches with [ pcolor = green ] [ stop ]

  if hour < day_length [
    if random-float 1 < freq_of_intrusion / 12 [ spawn-intruder ]
    repeat 60 [ ask turtles [ if random-float 1 < active / 100 [ move ] if breed = defenders [ detect-intruders ]
      ]
    ]

    ask turtles [
      if [ food? ] of patch-here [
        if [ nutrients ] of patch-here > 0 [
          ask patch-here [
            set nutrients nutrients - 1 ] ] ]
      if  [ nutrients ] of patch-here = 0 AND [ pcolor ] of patch-here != black [
        ask patch-here [
          set pcolor 37
        ]
      ]
    ]
  ]

  ask patches with [ food? ] [
    if depleted >= food_regrowth * 24 [
      set nutrients food_per_patch
      set depleted 0
      set pcolor green ]
    if nutrients <= 0 [ set depleted depleted + 1 ]
  ]

  ask intruders [ set age age + 1 ]

  update-plots

end

to create-world

  clear-all
  reset-ticks

  let world_radius ( sqrt ( home_range * 1000 / pi ) / 10 ) + ceiling ( speed / 60 )

  set world_diameter ( sqrt ( home_range * 1000 / pi ) / 10 ) * .02

  set-patch-size 1
  resize-world (0 - world_radius - 1) world_radius + 1 (0 - world_radius - 1) world_radius + 1
  set-patch-size 2600 / ( max-pxcor * 2 * 4 )
  ask patches [
  set pcolor black set world? ( distancexy 0 0 ) <= world_radius
  if world? [ set pcolor 37 ] ]

  while [ ( count patches with [ pcolor = 37 ] / 10 ) < home_range ] [
  ask max-one-of patches with [ not world? ] [ count neighbors4 with [ world? ] ] [ set world? TRUE set pcolor 37 ] ]

  while [ ( count patches with [ pcolor = 37 ] / 10 ) > home_range ] [
  ask max-one-of patches with [ world? ] [ count neighbors4 with [ not world? ] ] [ set world? FALSE set pcolor black ] ]

  ask patches [ set food? FALSE ]

  ask one-of patches with [ world? ] [ set food? TRUE ]

  repeat number_food_patches - 1 [ ask one-of patches with [ world? AND distance min-one-of patches with [ food? ] [ distance myself ] > world_radius / 2 ] [ set food? TRUE ] ]

  while [ count patches with [ food? ] < count patches with [ world? ] * ( food_density / 100 ) ] [
    ask one-of patches with [ food? ] [
      let far_patch max-one-of patches with [ world? AND not food? ] [ distance myself ]
      let food_dist [ distance myself ] of far_patch * ( ( 100 - food_clumpedness )  / 400 )
      ask min-one-of patches with [ not food? and world? AND distance myself > food_dist ] [ distance myself ] [ set food? TRUE ] ] ]

  ask patches with [ food? ] [
    set pcolor green
    set nutrients food_per_patch
  ]

end

to set-globals

  set day_length 12
  set day_range world_diameter * Defendibility_Index
  set speed (day_range / day_length) * ( 100 / active ) * 10
  set velocity day_range

end

to randhead

  ifelse random 2 = 0 [ set heading ( heading + ( angle / 2 ) - ( random angle ) ) ] [
    set heading ( heading - ( angle / 2 ) + ( random angle ) ) ]

end

to move

  ifelse activity = "chasing" [
    ifelse breed = intruders [ stop ] [
      chase-intruder ] ] [
    ifelse [ world? ] of patch-here [
      randhead forward speed / 60 ] [
      set heading towards patch 0 0 forward speed / 60 ] ]

end

to spawn-intruder

  create-intruders 1 [
    set size 1
    set label-color blue - 2
    let start one-of patches with [ world? AND [ not world? ] of one-of neighbors ] setxy [ pxcor ] of start [ pycor ] of start
    set color red
    set size world_diameter * 2.7
    update-plots
  ]

end

to detect-intruders
  if any? intruders in-radius ( detection_distance / 10 ) [
    set chasee min-one-of intruders in-radius ( detection_distance / 10 ) [ distance myself ]
    ask chasee [ set chaser myself set activity "chased" ]
    set activity "chasing" ]

end

to chase-intruder

  ifelse is-turtle? chasee [
    set heading towards chasee
    forward speed / 60

    ask chasee [ ifelse any? patches with [ not world? ] in-radius ( speed / 60 ) OR [ not world? ] of patch-here [
      ask chaser [ set activity "roaming" set chasee nobody ]
      set hours_before_expulsion lput [ age ] of self hours_before_expulsion die
      set count_intruders count_intruders - 1
      update-plots
      die ] [
      set heading [ heading ] of myself forward speed / 60 ] ] ] [

    set activity "roaming" set chasee nobody ]

end
@#$#@#$#@
GRAPHICS-WINDOW
385
10
1019
645
-1
-1
7.738095238095238
1
10
1
1
1
0
0
0
1
-42
42
-42
42
0
0
1
Hours
30.0

BUTTON
0
10
66
43
setup
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
0
130
55
163
Go
go
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

BUTTON
0
50
107
83
Go one hour
Go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
5
380
97
413
angle
angle
0
180
41.5
.5
1
NIL
HORIZONTAL

SLIDER
5
220
212
253
home_range
home_range
1
600
550.0
0.5
1
Hectares
HORIZONTAL

SLIDER
5
420
160
453
number_parties
number_parties
1
250
1.0
1
1
NIL
HORIZONTAL

SLIDER
5
300
197
333
detection_distance
detection_distance
0
1000
340.0
10
1
m
HORIZONTAL

BUTTON
0
90
85
123
Go one day
repeat 24 [go]
NIL
1
T
OBSERVER
NIL
D
NIL
NIL
1

MONITOR
1090
10
1147
55
NIL
hour
17
1
11

BUTTON
0
170
67
203
Profiler
Setup\nprofiler:start\nrepeat 2 [ go ]\nprofiler:stop\nprint profiler:report\nprofiler:reset\n;repeat 24000 [ go ]\n;profiler:start\n;repeat 2400 [ go ]\n;profiler:stop\n;print profiler:report\n;profiler:reset
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
5
340
177
373
active
active
0
100
12.0
1
1
% of day
HORIZONTAL

MONITOR
220
210
335
255
World dimater (km)
world_diameter
3
1
11

SLIDER
5
460
217
493
freq_of_intrusion
freq_of_intrusion
.1
24
0.3
.1
1
per day
HORIZONTAL

PLOT
1080
70
1400
210
intruders
hours
intruders
0.0
1.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plotxy ticks count intruders"

MONITOR
1185
10
1242
55
NIL
day
17
1
11

MONITOR
1275
15
1332
60
NIL
year
17
1
11

PLOT
1090
220
1310
365
Mean hours before expulsion
Time
Mean hours
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean hours_before_expulsion"

SLIDER
5
260
177
293
defendibility_index
defendibility_index
0.1
3
1.0
0.01
1
NIL
HORIZONTAL

MONITOR
210
260
287
305
Day Range
day_range
3
1
11

MONITOR
210
75
357
120
Boundary_length (km)
precision ( 2 * pi * ( world_diameter / 2 ) ) 3
17
1
11

MONITOR
180
410
270
455
N-adjusted D
( ( number_parties * day_range ) / \nsqrt ( ( 4 * ( Home_Range * 10 ) / pi ) ) ) * 100
2
1
11

MONITOR
210
315
352
360
Fractional Monitoring
number_parties *\n( ( detection_distance / 100 * velocity / 100 ) / (world_diameter ^ 2 ) )
7
1
11

SLIDER
10
505
222
538
food_density
food_density
0
100
10.0
1
1
% of patches
HORIZONTAL

SLIDER
10
545
192
578
food_clumpedness
food_clumpedness
1
100
100.0
1
1
%
HORIZONTAL

SLIDER
10
585
202
618
number_food_patches
number_food_patches
1
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
130
125
302
158
food_per_patch
food_per_patch
1
100
23.0
1
1
NIL
HORIZONTAL

SLIDER
130
165
307
198
food_regrowth
food_regrowth
1
100
50.0
1
1
days
HORIZONTAL

PLOT
1095
385
1305
505
Totoal nutrients
Time
Nutrients
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot sum [ nutrients ] of patches with [ food? ]"

PLOT
1120
525
1320
675
Patches with nutrients
Time
Patches
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count patches with [ nutrients > 0 ]"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

female
false
0
Circle -6459832 true false 74 14 152
Polygon -7500403 true true 135 60
Polygon -7500403 true true 195 90 195 90 150 120
Circle -11221820 true false 105 45 90
Rectangle -6459832 true false 135 165 165 270
Rectangle -6459832 true false 90 195 210 225

female_fetus
false
0
Circle -6459832 true false 74 134 152
Polygon -7500403 true true 135 60
Polygon -7500403 true true 195 90 195 90 150 120
Circle -11221820 true false 105 165 90
Rectangle -6459832 true false 135 30 165 135
Rectangle -6459832 true false 90 75 210 105

female_old
false
0
Circle -6459832 true false 74 14 152
Polygon -7500403 true true 135 60
Polygon -7500403 true true 195 90 195 90 150 120
Circle -11221820 true false 105 45 90
Rectangle -6459832 true false 135 165 165 270
Rectangle -6459832 true false 90 195 210 225
Polygon -7500403 true true 150 0 255 60 240 75 150 30 150 30
Polygon -7500403 true true 150 0 45 60 60 75 150 30 150 30

female_pop
false
0
Circle -2064490 true false 74 14 152
Polygon -7500403 true true 135 60
Polygon -7500403 true true 195 90 195 90 150 120
Circle -1184463 true false 105 45 90
Rectangle -2064490 true false 135 165 165 270
Rectangle -2064490 true false 90 195 210 225

female_pregnant
false
0
Circle -6459832 true false 74 14 152
Polygon -7500403 true true 135 60
Polygon -7500403 true true 195 90 195 90 150 120
Circle -11221820 true false 105 45 90
Rectangle -6459832 true false 135 165 165 270
Rectangle -6459832 true false 90 195 210 225
Circle -6459832 true false 60 165 90

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

male
false
0
Circle -13345367 true false 29 134 152
Polygon -7500403 true true 135 60
Polygon -7500403 true true 195 90 195 90 150 120
Circle -11221820 true false 60 165 90
Rectangle -1 true false 150 120 150 120
Polygon -13345367 true false 135 150 210 75 180 75 180 45 255 45 255 120 225 120 225 90 150 165

male_fetus
false
0
Circle -13345367 true false 29 14 152
Polygon -7500403 true true 135 60
Polygon -7500403 true true 195 90 195 90 150 120
Circle -11221820 true false 60 45 90
Rectangle -1 true false 150 120 150 120
Polygon -13345367 true false 135 150 210 225 180 225 180 255 255 255 255 180 225 180 225 210 150 135

male_old
false
0
Circle -13345367 true false 29 134 152
Polygon -7500403 true true 135 60
Polygon -7500403 true true 195 90 195 90 150 120
Circle -11221820 true false 60 165 90
Rectangle -1 true false 150 120 150 120
Polygon -13345367 true false 135 150 210 75 180 75 180 45 255 45 255 120 225 120 225 90 150 165
Polygon -7500403 true true 105 105 105 135 210 225 210 195 165 150
Polygon -7500403 true true 105 105 105 135 0 225 0 195 45 150

monster
false
0
Polygon -7500403 true true 75 150 90 195 210 195 225 150 255 120 255 45 180 0 120 0 45 45 45 120
Circle -16777216 true false 165 60 60
Circle -16777216 true false 75 60 60
Polygon -7500403 true true 225 150 285 195 285 285 255 300 255 210 180 165
Polygon -7500403 true true 75 150 15 195 15 285 45 300 45 210 120 165
Polygon -7500403 true true 210 210 225 285 195 285 165 165
Polygon -7500403 true true 90 210 75 285 105 285 135 165
Rectangle -7500403 true true 135 165 165 270

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="240000"/>
    <exitCondition>years_fixed = 5</exitCondition>
    <metric>( ( sum reduce sentence [ signal_genotype_maternal ] of turtles ) + ( sum reduce sentence [ signal_genotype_maternal ] of turtles ) ) / ( count turtles * 30 )</metric>
    <enumeratedValueSet variable="Steepness">
      <value value="0.8"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_males">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sight">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Conception_risk">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_females">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Angle">
      <value value="99"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Day_Range">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Consort_length">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Signal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world_size">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="encounters female defense" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2880"/>
    <metric>sum [ encounters ] of males</metric>
    <enumeratedValueSet variable="number_females">
      <value value="10"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Angle">
      <value value="240"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sight">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Day_range">
      <value value="2"/>
      <value value="7"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="240000"/>
    <exitCondition>years_fixed = 5</exitCondition>
    <metric>( ( sum reduce sentence [ signal_genotype_maternal ] of turtles ) + ( sum reduce sentence [ signal_genotype_maternal ] of turtles ) ) / ( count turtles * 30 )</metric>
    <enumeratedValueSet variable="Steepness">
      <value value="0.8"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_males">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sight">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Conception_risk">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_females">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Angle">
      <value value="99"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Day_Range">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Consort_length">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Signal?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world_size">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="encounters roving" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2880"/>
    <metric>sum [ encounters ] of males</metric>
    <enumeratedValueSet variable="number_females">
      <value value="10"/>
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Angle">
      <value value="240"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Sight">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_groups">
      <value value="1"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Day_range">
      <value value="2"/>
      <value value="7"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="encounters all" repetitions="25" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2880"/>
    <metric>sum [ encounters ] of males / count males</metric>
    <metric>( ( count males * count females ) - sum females_not_encountered_lengths ) / count males</metric>
    <enumeratedValueSet variable="Sight">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="world_size">
      <value value="2500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Active">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dispersion">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="female_defense?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_females">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Angle">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Day_Range">
      <value value="1"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="males_per_group">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_groups">
      <value value="4"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Mitani_Rodman" repetitions="50" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1440"/>
    <metric>mean hours_before_expulsion</metric>
    <metric>count intruders</metric>
    <enumeratedValueSet variable="Sight">
      <value value="50"/>
      <value value="100"/>
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Active">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Defendibility_Index">
      <value value="0.5"/>
      <value value="1"/>
      <value value="1.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Freq_of_intrusion">
      <value value="0.5"/>
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Angle">
      <value value="0.5"/>
      <value value="90"/>
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Home_Range">
      <value value="500"/>
      <value value="2000"/>
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_defenders">
      <value value="1"/>
      <value value="2"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
