/* Constants */
var WIDTH;          // width of the canvas (determined from object)
var HEIGHT;         // height of the canvas  (determined from object)
var OFFSET = 5;     // offset of the canvas content (horizontal + vertical)
var CELL_SIZE;

var ctx;                // canvas 2D context
var map;                // positions of all non-actors (walls etc.)

var map_id = null;             // ID of the map (will be set after loading)

/*
 * Draw a grid on the canvas
 */
function drawGrid() {
  var rows = map.length;
  var cols = map[0].length;

  rows++;
  cols++;

  for (var row = 0 ; row < rows ; row++) {
    line(OFFSET, OFFSET + row * CELL_SIZE, cols * CELL_SIZE - OFFSET, OFFSET + row * CELL_SIZE);
  }

  for (var col = 0 ; col < cols ; col++) {
    line(OFFSET + col * CELL_SIZE, OFFSET, OFFSET + col * CELL_SIZE, rows * CELL_SIZE - OFFSET);
  }
}

function drawActor(actorMapDef, row, col) {
    setCellColor(col, row, "brown");
    if (actorMapDef.direction == "up") {
        line(OFFSET + col * CELL_SIZE + (CELL_SIZE / 2), OFFSET + row * CELL_SIZE , OFFSET + col * CELL_SIZE + (CELL_SIZE / 2), OFFSET + row * CELL_SIZE + 5)
    }
    if (actorMapDef.direction == "down") {
        line(OFFSET + col * CELL_SIZE + (CELL_SIZE / 2), OFFSET + row * CELL_SIZE + CELL_SIZE , OFFSET + col * CELL_SIZE + (CELL_SIZE / 2), OFFSET + row * CELL_SIZE + CELL_SIZE - 5)
    }
    if (actorMapDef.direction == "left") {
        line(OFFSET + col * CELL_SIZE, OFFSET + row * CELL_SIZE + (CELL_SIZE / 2) , OFFSET + col * CELL_SIZE + 5, OFFSET + row * CELL_SIZE + (CELL_SIZE / 2))
    }
    if (actorMapDef.direction == "right") {
        line(OFFSET + col * CELL_SIZE + CELL_SIZE, OFFSET + row * CELL_SIZE + (CELL_SIZE / 2) , OFFSET + col * CELL_SIZE + CELL_SIZE - 5, OFFSET + row * CELL_SIZE + (CELL_SIZE / 2))
    }
}

function drawMarkers(row, col, count) {
    //OFFSET + x * CELL_SIZE + 1, OFFSET + y * CELL_SIZE + 1 , CELL_SIZE - 2, CELL_SIZE - 2
    ctx.fillStyle = "black";
    for (var i = 0 ; i <= (count-1) ; i++) {
        circle(OFFSET + col * CELL_SIZE + 5 + i*6, OFFSET + row * CELL_SIZE + 5, 3);
    }
}

/*
 * Render all map elements
 * map object is 2D array - each field can be:
 *  - undefined -> empty field
 *  - "wall" -> wall object
 *  - "spawn" -> actor spawn location
 */
function drawMap() {
    clear();
    drawGrid();
    for (var row = 0 ; row < map.length ; row++) {
        for (var col = 0 ; col < map[0].length ; col++) {
            var value = map[row][col];
            var isWall = false;
            var isActor = false;
            var markerCount = 0;
            var actorIndex;

            for (var i = 0 ; i < value.length ; i++) {
                if (value[i] == "wall") { isWall = true; }
                if (value[i] == "spawn") { isSpawn = true; }
                if (value[i].type != undefined) { 
                    if (value[i].type == "actor") {
                        isActor = true;
                        actorIndex = i;
                    } else if (value[i].type == "marker") {
                        markerCount++;
                    }
                }
            }
            setCellColor(col,row,"white");

            if (isWall) { setCellColor(col,row,"red"); continue; }
            if (isActor) { drawActor(value[actorIndex], row, col); }

            // Render markers if there are any
            if (markerCount > 0) {
                drawMarkers(row, col, markerCount);
            }
        }
    }
}

// This function returns at which index the object with given type is located
// returns null if not found
function getIndexOfItem(type, arr) {
    for (var i = 0 ; i < arr.length ; i++) {
        if (arr[i].type == type) return i;
    }
    return null;
}

/*
 * Initialize canvas with ID "canvas" and set global variables
 */
function initCanvas() {
    ctx = $('#canvas')[0].getContext("2d");
    WIDTH = $("#canvas").width();
    HEIGHT = $("#canvas").height();
}

/*
 * Initialize simulation global variable from parameters object
 *  parameters.x_size - number of columns in simulation
 *  parameters.y_size - number of rows in simulation
 */
function initMap() {
  /* Determine cell width and height for future use */
  CELL_SIZE = (Math.min(WIDTH,HEIGHT) - (OFFSET * 2)) / Math.min(map.length, map[0].length);
}

function clear() {
  ctx.clearRect(0, 0, WIDTH, HEIGHT);
}

function circle(x,y,r) {
  ctx.beginPath();
  ctx.arc(x, y, r, 0, Math.PI*2, true);
  ctx.closePath();
  ctx.fill();
}

/*
 * Set color of some cell using logical coordinates
 * @param x - column
 * @param y - row
 * @param color - color of the cell
 */
function setCellColor(x,y,color) {
  ctx.fillStyle = color;
  ctx.beginPath();
  ctx.rect(OFFSET + x * CELL_SIZE + 1, OFFSET + y * CELL_SIZE + 1 , CELL_SIZE - 2, CELL_SIZE - 2);
  ctx.closePath();
  ctx.fill();
}

function rect(x,y,w,h) {
  ctx.beginPath();
  ctx.rect(x,y,w,h);
  ctx.closePath();
  ctx.fill();
}

function line(x,y,x2,y2) {
  ctx.beginPath();
  ctx.moveTo(x, y);
  ctx.lineTo(x2, y2);
  ctx.closePath();
  ctx.stroke();
}

function load_map(callback) {
  $.ajax({
            url: "/maps/"+map_id+"/get_map",
            success: function(data){
                map = JSON.parse(data.data);
                initMap();
                drawMap();
                if (callback != undefined) callback();
            }
  });
}