turtles-own [
  ;; this is used to mark turtles we have already visited
  explored?
  ;; turtles friends
  friends
]

globals [
  ;; number of turtles explored so far in the current component
  component-size
  ;; number of turtles in the giant component
  network-friends-component-size
  ;; node from where we started exploring the giant component
  giant-start-node
]

;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup Procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  ;; clean all
  clear-all
  make-turtles
  ;; at this stage, all the components will be of size 1, since there are no edges yet
  find-all-components
  reset-ticks
end

;; make person
to make-turtles
  create-turtles num-nodes [
    set size 3
    set shape "person"
  ]
  layout-circle turtles max-pxcor - 1
end

;;;;;;;;;;;;;;;;;;;;;;
;;; Main Procedure ;;;
;;;;;;;;;;;;;;;;;;;;;;

to go
  ;; stop if the below condition is true, as then we have a fully connected network (every two nodes are connected)
  if ( (2 * count links ) >= ( (count turtles) * (count turtles - 1) ) ) [
    display
    user-message "Network is fully connected. No more edges can be added."
    stop
  ]
  ask links [
    ;; ask each link to maybe remove, according to the remove-edge-probability slider
    if (random-float count links) < remove-edge-probability [ remove-edge ]
  ]
  ;; add edge between two people, according to the connection-probability slider
  if (random-float 1) < connection-probability [ add-edge ]
  find-all-components
  color-network-friends-component
  ;; recolor all edges
  ask links [ set color [color] of end1 ]
  ;; layout the turtles with a spring layout, but stop laying out when all nodes are in the giant component
  if not all? turtles [ color = red ] [ layout ]
  ;; update the plots
  update-plots
  ;; set the number of friends each person has
  ask turtles [ set friends count link-neighbors ]
  tick
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Network Exploration ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; to find all the connected components in the network, their sizes and starting turtles
to find-all-components
  set network-friends-component-size 0
  ask turtles [ set explored? false ]
  ;; keep exploring till all turtles get explored
  loop
  [
    ;; pick a node that has not yet been explored
    let start one-of turtles with [ not explored? ]
    if start = nobody [ stop ]
    ;; reset the number of turtles found to 0 this variable is updated each time we explore an unexplored node.
    set component-size 0
    ;; at this stage, we recolor everything to light gray
    ask start [ explore (gray + 2) ]
    ;; the explore procedure updates the component-size variable. So check, have we found a new giant component?
    if component-size > network-friends-component-size
    [
      set network-friends-component-size component-size
      set giant-start-node start
    ]
  ]
end

;; Finds all turtles reachable from this node (and recolors them)
to explore [new-color]
  if explored? [ stop ]
  set explored? true
  set component-size component-size + 1
  ;; color the node
  set color new-color
  ;; node procedure
  ask link-neighbors [ explore new-color ]
end

;; color the giant component red
to color-network-friends-component
  ask turtles [ set explored? false ]
  ask giant-start-node [ explore red ]
end

;;;;;;;;;;;;;;;;;;;;;;;
;;; Edge Operations ;;;
;;;;;;;;;;;;;;;;;;;;;;;

;; pick a random missing edge and create it
to add-edge
  let node1 one-of turtles
  let node2 one-of turtles
  ask node1 [
    ifelse link-neighbor? node2 or node1 = node2
    ;; if there's already an edge there, then go back and pick new turtles
    [ add-edge ]
    ;; else, go ahead and make it
    [ create-link-with node2 ]
    ;;  In this alternate version of add-edge, we tell NetLogo to explicitly go looking for a node that is not already connected to the first one (even if there are very few of those)
    ;[ create-link-with one-of other turtles with [ not link-neighbor? myself ] ]
  ]
end

;; turtle procedure
to remove-edge
  ;; node-A remains the same
  let node-A end1
  ;; as long as A is not connected to everybody
  if [ count link-neighbors ] of end1 < (count turtles - 1) [
    ;; remove the old edge
    die
  ]
end

;;;;;;;;;;;;;;
;;; Layout ;;;
;;;;;;;;;;;;;;

to layout
  if not layout? [ stop ]
  ;; the number 10 here is arbitrary; more repetitions slows down the model, but too few gives poor layouts
  repeat 10 [
    do-layout
    ;; so we get smooth animation
    display
  ]
end

to do-layout
  ;; the more turtles we have to fit into the same amount of space, the smaller the inputs to layout-spring we'll need to use
  ;; numbers here are arbitrarily chosen for pleasing appearance
  layout-spring (turtles with [any? link-neighbors]) links 0.4 spring-length repulsion-strength
end
@#$#@#$#@
GRAPHICS-WINDOW
408
10
934
537
-1
-1
5.7
1
10
1
1
1
0
0
0
1
-45
45
-45
45
1
1
1
ticks
30.0

BUTTON
26
37
180
70
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
27
112
180
145
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
222
36
376
69
num-nodes
num-nodes
2
500
81.0
1
1
NIL
HORIZONTAL

PLOT
943
347
1145
533
Growth of the network friends
Connections per node
Fraction in network
0.0
3.0
0.0
1.0
true
false
"" ""
PENS
"size" 1.0 0 -2674135 true "" "if not plot? [ stop ]\n;; We multiply by 2 because every edge should be counted twice while calculating,\n;; the average, since an edge connects two turtles.\n;; We divide by the node count to normalize the y axis to a 0 to 1 range.\nplotxy (2 * count links / count turtles)\n       (network-friends-component-size / count turtles)"
"transition" 1.0 0 -7500403 true "" "plot-pen-up\nplotxy 1 0\nplot-pen-down\nplotxy 1 1"

MONITOR
5
492
131
537
Network friends' size
network-friends-component-size
3
1
11

BUTTON
26
74
180
107
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SWITCH
84
278
200
311
layout?
layout?
0
1
-1000

BUTTON
83
239
319
272
redo layout
do-layout\ndisplay
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
222
73
376
106
connection-probability
connection-probability
0
1
1.0
0.01
1
NIL
HORIZONTAL

PLOT
943
32
1143
182
Degree Distribution
Degree
# of nodes
1.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "if not plot? [ stop ]\nlet max-degree max [count link-neighbors] of turtles\nplot-pen-reset  ;; erase what we plotted before\nset-plot-x-range 1 (max-degree + 1)  ;; + 1 to make room for the width of the last bar\nhistogram [count link-neighbors] of turtles"

SWITCH
204
278
319
311
plot?
plot?
0
1
-1000

PLOT
943
190
1143
340
Degree Distribution (log-log)
log(# of nodes)
log(degree)
0.0
1.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if not plot? [ stop ]\nlet max-degree max [count link-neighbors] of turtles\n;; for this plot, the axes are logarithmic, so we can't\n;; use \"histogram-from\"; we have to plot the points\n;; ourselves one at a time\nplot-pen-reset  ;; erase what we plotted before\n;; the way we create the network there is never a zero degree node,\n;; so start plotting at degree one\nlet degree 1\nwhile [degree <= max-degree] [\n  let matches turtles with [count link-neighbors = degree]\n  if any? matches\n    [ plotxy log degree 10\n             log (count matches) 10 ]\n  set degree degree + 1\n]"

MONITOR
4
441
200
486
Fiends of the most popular person
max [count link-neighbors] of turtles
17
1
11

MONITOR
204
441
402
486
Friends of the most unknow person
min [count link-neighbors] of turtles
17
1
11

SLIDER
222
111
376
144
remove-edge-probability
remove-edge-probability
0
1
0.0
0.01
1
NIL
HORIZONTAL

MONITOR
151
491
201
536
AVGf
sum [ count link-neighbors ] of turtles / num-nodes
3
1
11

MONITOR
205
491
255
536
AVGff
sum [ count link-neighbors ^ 2 ] of turtles / sum [ count link-neighbors ] of turtles
3
1
11

MONITOR
291
491
401
536
Total links
count links
17
1
11

SLIDER
203
316
319
349
spring-length
spring-length
2
20
20.0
1
1
NIL
HORIZONTAL

SLIDER
83
316
200
349
repulsion-strength
repulsion-strength
0
5
5.0
0.2
1
NIL
HORIZONTAL

TEXTBOX
183
212
230
230
Interface
10
0.0
1

TEXTBOX
80
12
135
30
Commands
10
0.0
1

TEXTBOX
278
14
324
32
Settings
10
0.0
1

TEXTBOX
1027
11
1052
37
Plots
10
0.0
1

TEXTBOX
182
413
236
431
Monitors
10
0.0
1

@#$#@#$#@
## WHAT IS IT?

This project is based on the article by Scott L. Feld and tries to reproduce the evolution of a network of friendships between people.

## HOW IT WORKS

Initially we have nodes but no connections (edges) between them. At each step, we randomly pick two nodes that weren't directly connected before, and add an edge between them, based on the connection probability chosen earlier. All possible connections to each other have exactly the same probability of occurring.

As the model runs, small chain-like "components" are formed, where members of each component are directly or indirectly connected to each other. If an edge is created between the nodes of two different components, these two components merge into one. The component with the most members at any given time is the "giant" component and is colored red. (If there is a tie for largest, we choose a random component to color.)

Furthermore, there is the possibility to remove connections between people randomly during each iteration, based on the remove-edge-probability that you can freely choose.

## HOW TO USE IT

The NUM-NODES slider controls the size of the network. Choose a size and press SETUP.

Pressing the GO ONCE button a new edge is added to the network, based on the probability set on the CONNECTION-PROBABILITY slider, furthermore on the basis of the probability set using the REMOVE-EDGE-PROBABILITY slider, previously created edges can be removed in each iteration. To continue quickly, press GO.

As the model runs, the nodes and edges try to position themselves in a layout that makes the network structure easily visible. The layout makes the model slower, though. To get results faster, turn off LAYOUT? switch.

The REDO LAYOUT button continuously executes the layout step procedure to improve the layout of the network.

The REPULSION -STRENGTH and SPRING-LENGTH sliders manage the distance between the nodes in the layout.

The monitors show the current size of the giant component, number of friends of the most famous person, number of friends of the most unknown person, total links, AVGf (average of friends) and AVGff (average of friends of friends).

The PLOT button? allows, if active, to update the graphs.

The graphs show how the size of the giant component changes over time and the distribution of links and nodes, also on a logarithmic scale.

## NETWORK CONCEPTS

Identification of the connected components is done using a standard search algorithm called "depth first search." "Depth first" means that the algorithm first goes deep into a branch of connections, tracing them out all the way to the end. For a given node it explores its neighbor's neighbors (and then their neighbors, etc) before moving on to its own next neighbor. The algorithm is recursive so eventually all reachable nodes from a particular starting node will be explored. Since we need to find every reachable node, and since it doesn't matter what order we find them in, another algorithm such as "breadth first search" would have worked equally well. We chose depth first search because it is the simplest to code.

## References

Project by Alex Citeroni (1052175) for the exam of Complex Systems and Network Science.
Email: alex.citeroni@studio.unibo.it



<!-- 2022 -->
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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
0
@#$#@#$#@
