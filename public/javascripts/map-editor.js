// requires canvas.js
var tool = "eraser";
var saved = true;

var selected_col;
var selected_row;

function canvasClickHandler(e) {
      // convert to relative position on canvas
      var x = e.pageX - this.offsetLeft;
      var y = e.pageY - this.offsetTop;

      // determine col, row
      col = Math.floor(x / CELL_SIZE);
      row = Math.floor(y / CELL_SIZE);

      if ((row < map.length) && (col < map[0].length)) {
        if (tool == "eraser") map[row][col] = [];
        if (tool == "wall") map[row][col] = [ "wall" ];
        saved = false;
        drawMap();
      }
}

function save_map() {
    if (!saved) {
        var mapJSON = JSON.stringify(map);
        alert(mapJSON);
        $.ajax({
            url: "/maps/"+map_id+"/save_map",
            data: mapJSON,
            type: "POST",
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            success: function() {
                alert("Map saved");
            }
        });
        saved = true;
    }
}

$(document).ready(function() {
    // click on canvas handler
    $("#canvas").click(canvasClickHandler);

    $(window).unload(save_map);

    $("#canvas").contextMenu('toolSelectMenu', {
      bindings: {
        'wall': function(t) {
            tool = "wall";
        },
        'eraser': function(t) {
            tool = "eraser";
        },
        'save' : function(t) {
            save_map();
        }
      },

      onContextMenu: function(e) {
        var x = e.pageX - $("#canvas").offset().left;
        var y = e.pageY - $("#canvas").offset().top;
        // determine col, row
        selected_col = Math.floor(x / CELL_SIZE);
        selected_row = Math.floor(y / CELL_SIZE);

        return true;
      }
    });
    initCanvas();
});