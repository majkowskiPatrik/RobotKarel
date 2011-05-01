var story = null;
var currentStep = 0;
var actorsLast = [];
var actors = null;
var selected_col;
var selected_row;
var autoplay = false;

function load_map_for_sim() {
  $.ajax({
            url: "/simulations/"+sim_id+"/get_map",
            success: function(data){
                map = JSON.parse(data.data);
                load_story();
            }
  });
}

function load_story() {
    $.ajax({
            url: "/simulations/"+sim_id+"/get_story",
            success: function(data){
                story = JSON.parse(data.data);
                $("#step_end").val(story.length-1);
                load_actors();
            }
      });
}

function load_actors() {
    $.ajax({
            url: "/simulations/"+sim_id+"/get_actors",
            success: function(data){
                actors = JSON.parse(data.data);
                initMap();
                renderSimulation();
            }
        });
}

function getActorByID(id) {
    for (var i = 0 ; i < actors.length ; i++) {
        if (actors[i].id == id) return actors[i];
    }
    return null;
}

function renderStep(stepNo) {
    var storyStep = story[stepNo];

    // remove actors from last step
    for (var i = 0 ; i < actorsLast.length ; i++) {
        var mapField = map[actorsLast[i].row][actorsLast[i].col];
        mapField.splice(getIndexOfItem("actor", mapField),1);
    }

    actorsLast = [];

    // place all actors on the map
    for (var j = 0 ; j < storyStep.length ; j++) {
        var actorMapDef = {};
        actorMapDef.type = storyStep[j].type;
        if (actorMapDef.type == "actor") {
            actorMapDef.direction = storyStep[j].direction;
            actorMapDef.id = storyStep[j].id;
        }
 
        map[storyStep[j].row][storyStep[j].col].push(actorMapDef);

        var actorLast = {};
        actorLast.row = storyStep[j].row;
        actorLast.col = storyStep[j].col;

        actorsLast.push(actorLast);
    }

    renderMessages(story[stepNo+1]);
    
}

function renderMessages(storyStep) {
    // clear textarea before writing to it
    $("#messages_textarea").val("");
    for (var i = 0 ; i < storyStep.length ; i++) {
        if (storyStep[i].messages != null) {
            $("#messages_textarea").val($("#messages_textarea").val() + "Actor " + getActorByID(storyStep[i].id).name + " : " + "\n");
            for (var j = 0 ; j < storyStep[i].messages.length ; j++) {
                $("#messages_textarea").val($("#messages_textarea").val() + storyStep[i].messages[j] + "\n");
            }
            $("#messages_textarea").val($("#messages_textarea").val() + "\n");
        }
    }
}

function advanceSimulationUp() {
    if (currentStep < story.length-1) {
        currentStep++;
        renderSimulation();
    }
}

function advanceSimulationDown() {
    if (currentStep > 0) {
        currentStep--;
        renderSimulation();
    }
}

function rewindSimulation() {
    var newStep = parseInt($("#step_ctrl").val());
    if ((newStep >= 0) && (newStep < story.length-1)) {
        currentStep = newStep;
        renderSimulation();
    }
}

function renderSimulation() {
    $("#step_ctrl").val(currentStep);
    renderStep(currentStep);
    drawMap();
}

function simulate() {
    var stepCount = parseInt($("#step_count").val())

    if (isNaN(stepCount)) {
        alert("Number of steps must be a number");
        return;
    }

    if ((stepCount < 1) || (stepCount > 500)) {
        alert("Number of steps must be in interval 2..500");
        return;
    }

    $("#simulate_label").html("Please wait...");

    $.ajax({
        url: "/simulations/"+sim_id+"/"+stepCount+"/simulate",
        success: function(d){
            load_story();
            $("#simulate_label").html("Simulating finished, you can close this dialog");
            currentStep = 0;
            $("#step_ctrl").val("0");
            rewindSimulation();
        }
    });
}

$(document).ready(function() {
    initCanvas();
     $("#canvas").contextMenu('contextMenu', {

      bindings: {
        'show_source': function(t) {
            var id = map[selected_row][selected_col][getIndexOfItem("actor", map[selected_row][selected_col])].id;
            var actor = getActorByID(id);
            $("#src_label").html("Source code for : "+actor.name);
            $("#src_textarea").val(actor.source_code);
            $("#source-show-content").modal();
        },

        'show_static': function(t) {
            var id = map[selected_row][selected_col][getIndexOfItem("actor", map[selected_row][selected_col])].id;
            var actor = getActorByID(id);
            $("#src_label").html("Static source code for : "+actor.name);
            $("#src_textarea").val(actor.static_code);
            $("#source-show-content").modal();
        }
      },

      onContextMenu: function(e) {
        var x = e.pageX - $("#canvas").offset().left;
        var y = e.pageY - $("#canvas").offset().top;

        // determine col, row
        selected_col = Math.floor(x / CELL_SIZE);
        selected_row = Math.floor(y / CELL_SIZE);
        
        if (getIndexOfItem("actor", map[selected_row][selected_col]) != null) return true
        else return false;
      }

    });

    $("#btn_step_up").click(advanceSimulationUp);
    $("#btn_step_down").click(advanceSimulationDown);
    $("#step_ctrl").change(rewindSimulation);
    $("#btn_simulate").click(function () {
        $("#simulate_label").html("Enter number of steps you want to simulate");
        $("#simulate-content").modal(
        {
            containerCss: {
                width: 400,
                height: 100
            }
        }
        );
    });
    
    $("#btn_simulate_confirm").click(simulate);

    $("#chk_autoplay").change(function() {
        if ($('#chk_autoplay').attr('checked') == true) {
            $(document).everyTime(1000, 'autoplay', function(i) {
                    advanceSimulationUp();
            });
        } else {
            $(document).stopTime();
        }
    });
});
