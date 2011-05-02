var selected_row = null;
var selected_col = null;
var selected_actor = null;

var actors = [];
var initialState = [];
var idCounter = 0; // unique ID of the actor in current simulation

var sim_id;
var saved = true;

var MARKERS_MAX = 4; // maximum number of markers on one location

function placeActor(templateID, act_id, name, source_code, static_code, direction, row, col) {
    // add new actor to actor list
    var actor = {};
    actor.template_id = templateID;
    actor.id = act_id; // Unique ID of this actor in this simulation
    actor.name = name;
    actor.source_code = source_code;
    actor.static_code = static_code;
    actors.push(actor);

    // save actor position, direction and ID on the map
    var actorState = {};
    actorState.row = row;
    actorState.col = col;
    actorState.direction = direction;
    actorState.id = actor.id;
    actorState.type = "actor";
    initialState.push(actorState);

    // add actor to currently rendered map
    var actorMapDef = {};


    actorMapDef.type = "actor";
    actorMapDef.direction = actorState.direction;
    actorMapDef.name = actor.name;
    actorMapDef.id = actor.id;
    var pos_row = row;
    var pos_col = col;

    map[pos_row][pos_col].push(actorMapDef);

    saved = false;
}

function placeMarker(row,col) {
    // check for marker count
    var count = 0;
    for (var i = 0 ; i < map[row][col].length ; i++) {
        var mapDef = map[row][col][i];
        if (mapDef.type == "marker") count++;
    }

    if (count == MARKERS_MAX) {
        alert("Sorry, maximum number of markers on one location is: " + MARKERS_MAX);
        return;
    }
    
    // save marker position on the map
    var actorState = {};
    actorState.row = row;
    actorState.col = col;
    actorState.type = "marker";
    initialState.push(actorState);

    // add marker to currently rendered map
    var actorMapDef = {};
    actorMapDef.type = "marker";
    var pos_row = row;
    var pos_col = col;
    map[pos_row][pos_col].push(actorMapDef);

    saved = false;
}

function removeActor(row, col) {
    var index = getIndexOfItem("actor", map[row][col]);
    if (index == null) return; // this shouldn't ever happen

    var id = map[row][col][index].id;
    map[row][col].splice(index, 1); // remove actors mapDef object

    var target;
    for (target = 0 ; target < actors.length ; target++) {
        if (actors[target].id == id) break;
    }

    actors.splice(target, 1); // remove actor object

    for (target = 0 ; target < initialState.length ; target++) {
        if (initialState[target].id == id) break;
    }

    initialState.splice(target, 1); // remove actor from simulation

    saved = false;
}

function removeMarker(row, col) {
    var index = null;
    for (var i = 0 ; i < initialState.length ; i++) {
        if ((initialState[i].type == "marker") && (initialState[i].row == row) && (initialState[i].col == col)) {
            // find index of record in initialState
            index = i;
            break;
        }
    }

    if (index != null) {
        initialState.splice(index, 1);  // remove record from initialState
    }

    map[row][col].splice(getIndexOfItem("marker", map[row][col]), 1);   // remove MapDef object from map

    saved = false;
}

function getActor(row,col) {
    var actorID;
    var actor = {};
    for (var i = 0 ; i < initialState.length ; i++) {
        if ((initialState[i].row == row)&&(initialState[i].col == col)) {
            actorID = initialState[i].id;
            actor.direction = initialState[i].direction;
            actor.row = initialState[i].row;
            actor.col = initialState[i].col;
        }
    }

    
    for (var i = 0 ; i < actors.length ; i++) {
        if (actors[i].id == actorID) {
            actor.id = actorID;
            actor.name = actors[i].name;
            actor.source_code = actors[i].source_code;
            actor.static_code = actors[i].static_code;
        }
    }
    return actor;
}

function save() {
    if (!saved) {
        var data = {};
        var act_save = actors;
        // Replace newlines with br tags because they doesn't get transferred properly by AJAX call'
        for (var i = 0 ; i < act_save.length ; i++) {
            act_save[i].source_code = act_save[i].source_code.replace(/\n/g,"<br />").replace(/\u000d/g,"");
            act_save[i].static_code = act_save[i].static_code.replace(/\n/g,"<br />").replace(/\u000d/g,"");
        }
        data.actors = act_save;
        data.initialState = initialState;
        $.ajax({
                url: "/simulations/"+sim_id+"/save_sim",
                data: JSON.stringify(data),
                type: "POST",
                dataType: "json",
                contentType: "application/json; charset=utf-8"
        });
        alert("Data saved");
        saved = true;
    }
}

function load_map_for_sim() {
  $.ajax({
            url: "/simulations/"+sim_id+"/get_map",
            success: function(data){
                map = JSON.parse(data.data);
                initMap();
                drawMap();
                load_initial_state();
            }
  });
}

function load_initial_state() {
   $.ajax({
            url: "/simulations/"+sim_id+"/get_initial_state",
            success: function(data){                
                var decoded = JSON.parse(data.data);
                if (decoded.actors != undefined) {
                    var dec_actors = JSON.parse(decoded.actors);
                    var dec_initial_state = JSON.parse(decoded.initial_state);

                    // create array of actors indexed by his own ID for easy access
                    var actorsArr = [];
                    for (var i = 0 ; i < dec_actors.length ; i++) {
                        var act = dec_actors[i];
                        actorsArr[act.id] = act;
                    }

                    var id_max = 0;
                    for (var j = 0 ; j < dec_initial_state.length ; j++) {
                        var ist = dec_initial_state[j];
                        if (ist.type == "actor") {
                            placeActor(actorsArr[ist.id].template_id, ist.id, actorsArr[ist.id].name, actorsArr[ist.id].source_code, actorsArr[ist.id].static_code, ist.direction, ist.row, ist.col);
                            if (Number(ist.id) > id_max) {
                                id_max = Number(ist.id);
                            }
                        } else if (ist.type = "marker") {
                            placeMarker(ist.row, ist.col);
                        }
                    }

                    // initialize ID counter to correct value, so unique IDs are generated
                    idCounter = id_max + 1;
                    
                }
                drawMap();
                saved = true;
            }
  });
}

function updateSourcePreview(actor_id) {
    $("#src_preview_textarea").val("Retrieving from server...");
    $("#sta_preview_textarea").val("Retrieving from server...");
    $("#actor_description").val("Retrieving from server...");

    $.ajax({
            url: "/actors/"+actor_id+"/get_properties",
            success: function(data){
                var props = JSON.parse(data.data);
                $("#src_preview_textarea").val(props.source_code);
                $("#sta_preview_textarea").val(props.static_code);
                $("#actor_description").val(props.description);
            }
        });
}

$(document).ready(function() {   
    $("#place_btn").click(function (e) {
        placeActor($("#actor_id").val(), idCounter, $("#actor_name").val(), $("#src_preview_textarea").val(), $("#sta_preview_textarea").val(), $("#actor_direction").val(), selected_row, selected_col);
        idCounter++;
        drawMap();
        $.modal.close();
    });

    $("#edit_btn").click(function (e) {
        //edit button has been clicked
        // modify actorDef
        for (var i = 0 ; i < actors.length ; i++) {
            if (actors[i].id == selected_actor.id) {
                // after actor by ID has been found, save modified data
                actors[i].name = $("#edit_actor_name").val();
                actors[i].source_code = $("#src_edit_textarea").val();
                actors[i].static_code = $("#sta_edit_textarea").val();
                break;
            }
        }
        // modify initialState
        for (var i = 0 ; i < initialState.length ; i++) {
            if (initialState[i].id == selected_actor.id) {
                initialState[i].direction = $("#edit_actor_direction").val();
                break;
            }
        }

        // modify actorMapDef, so it gets rendered        
        var actorMapDef = map[selected_actor.row][selected_actor.col];
        actorMapDef[getIndexOfItem("actor", actorMapDef)].direction = $("#edit_actor_direction").val();

        saved = false;

        drawMap();
        $.modal.close();
    });

    $("#actor_id").change(function() { updateSourcePreview($("#actor_id").val()); });

    $(window).unload(save);

    $("#canvas").contextMenu('placeActorMenu', {
      bindings: {
        'place': function(t) {
            // user has clicked on Place action
            // set generic name
            $("#actor_name").val("Actor "+idCounter);
            // display dialog
            $("#actor-prop-content").modal();
            updateSourcePreview($("#actor_id").val());
        },
        'place_marker' : function(t) {
            placeMarker(selected_row, selected_col);
            drawMap();
        },
        'remove' : function(t) {
            // user has clicked on Remove action
            removeActor(selected_row, selected_col);
            // immediately refresh map
            drawMap();
        },
        'remove_marker' : function (t) {
            removeMarker(selected_row, selected_col);
            drawMap();
        },
        'edit' : function(t) {
            selected_actor = getActor(selected_row, selected_col);
            $("#edit_actor_name").val(selected_actor.name);
            $("#edit_actor_direction").val(selected_actor.direction);
            $("#src_edit_textarea").val(selected_actor.source_code);
            $("#sta_edit_textarea").val(selected_actor.static_code);          
            $("#actor-edit-content").modal();
        },
        'save' : function(t) {
            if (saved) alert("No changes to save");
            save();
        }
      },

      onContextMenu: function(e) {
        // this function gets called before menu is displayed
        // we are using it for 2 purposes:
        // 1. determine where user has clicked (into variables selected_row,
        // selected_col)
        // 2. disable showing of context menu when it is not possible to do so
        // (right clicking on a wall)

        var x = e.pageX - $("#canvas").offset().left;
        var y = e.pageY - $("#canvas").offset().top;
        // determine col, row
        selected_col = Math.floor(x / CELL_SIZE);
        selected_row = Math.floor(y / CELL_SIZE);
        
        if (map[selected_row][selected_col].length == 0) {
            // empty field, actor can be placed here
            return true;
        }
        else {
            // field contains one or more objects, this menu is only valid for an actor or marker
            if ((getIndexOfItem("actor", map[selected_row][selected_col]) != null) || (getIndexOfItem("marker", map[selected_row][selected_col]) != null))  return true;
            return false; // no actor or marker found, menu will not be shown
        }
      },
      onShowMenu: function(e, menu) {
          // this function also gets called before a menu is displayed, the
          // clicked position is determined, it has the purpose of modifiying
          // displayed options:
          // if empty field is clicked - display options to put actor
          // if field with actor is clicked - display only option to remove
          var isActor = (getIndexOfItem("actor", map[selected_row][selected_col]) != null);
          var isMarker = (getIndexOfItem("marker", map[selected_row][selected_col]) != null);
          
          if (!isActor && !isMarker) {
              // empty field selected
              $('#remove', menu).remove(); // remove option to remove actor
              $('#remove_marker', menu).remove();
              $('#edit', menu).remove();
          } else if (isActor && !isMarker) {
              $('#place', menu).remove();
              $('#remove_marker', menu).remove();
          } else if (!isActor && isMarker) {
              $('#remove', menu).remove();
              $('#edit', menu).remove();
          } else if (isActor && isMarker) {
              $('#place', menu).remove();
          }

          return menu;
      }

    });
    
    initCanvas();

});