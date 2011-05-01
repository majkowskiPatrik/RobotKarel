class Evaluator
  def initialize(source_code, static_code, actor)
    @source_code = source_code
    @static_code = static_code
    @actor = actor
  end

  def evaluate
    begin
      eval(@source_code)
    rescue Exception => e
      log("cannot evaluate source code because : " + e.message)
    end
  end

  def evaluate_static
    begin
      eval(@static_code)
    rescue Exception => e
      log("cannot evaluate static code because : " + e.message)
    end
  end

  def get_directions
    return @actor.get_directions
  end

  def set_direction(direction_name)
    return @actor.set_direction(direction_name)
  end

  def get_position
    return @actor.get_position
  end

  def get_direction
    return @actor.get_direction
  end

  def move_possible?
    return @actor.move_possible?
  end

  def marker_present?
    return @actor.marker_present?
  end

  def pickup_marker
    return @actor.pickup_marker
  end

  def drop_marker
    return @actor.drop_marker
  end

  def log(message)
    return @actor.log(message)
  end

  def move
    return @actor.move
  end

end

class ActorImpl
  attr_reader :id, :name
  attr_accessor :marker, :position, :direction

  def initialize(position, direction, id, name, source_code, static_code, simulation)
    @position = position
    @direction = direction
    @id = id
    @name = name
    @evaluator = Evaluator.new(source_code, static_code, self)
    @simulation = simulation
    @messages = []
    @marker = nil
    @state = {}
    @state["move"] = false
    @state["pickup"] = false
    @state["drop"] = false
  end

  def set_state(name, value)
    @state[name] = value
  end

  def get_state(name)
    value = @state[name]
    @state[name] = false
    return value
  end

  def move
    if move_possible?
      set_state("move", true)
    end
  end

  def evaluate
    @evaluator.evaluate
  end

  def evaluate_static
    @evaluator.evaluate_static
  end

  # This method returns an array of directions that actor can move
  def get_directions
    possible_directions = [];
    ["left", "right", "up", "down"].each do |direction|
      test_direction = Vector2.new({:direction => direction});
      if @simulation.move_possible?(self.position, test_direction) == true
        possible_directions.push(direction);
      end
    end
    return possible_directions
  end

  # This method is used by user to set direction of this Actor
  def set_direction(direction_name)
    if (direction_name == "up") || (direction_name == "down") || (direction_name == "left") || (direction_name == "right")
      new_direction = Vector2.new({:direction => direction_name});
      @direction = new_direction
    end
  end

  def get_position
    return self.position
  end

  def get_direction
    return self.direction
  end

  def move_possible?
    value = @simulation.move_possible?(@position, @direction)
    if value == true
      return true
    else
      #log(value)
      return false
    end
  end

  def marker_present?
    return @simulation.marker_present?(@position)
  end

  def pickup_marker
    if @marker.nil? && marker_present?
      set_state("pickup", true)
    end
  end

  def drop_marker
    if !@marker.nil?
      set_state("drop", true)
    end
  end

  def log(message)
    @messages << message
  end

  def get_log
    retval = @messages
    @messages = []
    return nil if (retval == [])
    return retval
  end
end

class MarkerImpl
  attr_reader :position
  attr_accessor :actor

  def initialize(position)
    @position = position
    @actor = nil
  end

  def move
    p "marker move, actor: " + @actor.to_s
    if !@actor.nil?
      @position = @actor.position
    end
  end
end

class Vector2
  attr_reader :x,:y

  def initialize(hash)
    if hash.nil?
      @x = 0
      @y = 0
    end

    if (!(hash[:x].nil?) && !(hash[:y].nil?))
      @x = hash[:x]
      @y = hash[:y]
      return
    end

    if !(hash[:direction].nil?)
      if (hash[:direction] == "left")
        @x = 0
        @y = -1
      elsif (hash[:direction] == "up")
        @x = -1
        @y = 0
      elsif (hash[:direction] == "right")
        @x = 0
        @y = 1
      elsif (hash[:direction] == "down")
        @x = 1
        @y = 0
      else
        @x = 0
        @y = 0
      end
      return
    end
  end

  def +(other_vector)
    return Vector2.new({:x => @x + other_vector.x, :y => @y + other_vector.y })
  end

  def -(other_vector)
    return Vector2.new({:x => @x - other_vector.x, :y => @y - other_vector.y })
  end

  def to_s
    return "left" if (@x == 0) && (@y == -1)
    return "up" if (@x == -1) && (@y == 0)
    return "right" if (@x == 0) && (@y == 1)
    return "down" if (@x == 1) && (@y == 0)
  end

  def zero?
    return true if (@x == 0) && (@y == 0)
    return false
  end

  def equals?(other_vector)
    return true if (@x == other_vector.x) && (@y == other_vector.y)
    return false
  end

  def get_inverse
    return Vector2.new({:direction => "right"}) if (@x == 0) && (@y == -1)
    return Vector2.new({:direction => "down"}) if (@x == -1) && (@y == 0)
    return Vector2.new({:direction => "left"}) if (@x == 0) && (@y == 1)
    return Vector2.new({:direction => "up"}) if (@x == 1) && (@y == 0)
  end
end

class Simulation < ActiveRecord::Base
  has_many :simulation_steps
  validates :name, :presence => true

  def initialized?
    return !self.simulation_steps.empty?
  end

  # Function returns true if next move is possible, reason why it is not possible otherwise
  def move_possible?(position, direction)
    new_position = position + direction
    return "collision with map edge" if (new_position.x < 0 || new_position.y < 0 || new_position.x >= @map[0].length || new_position.y >= @map.length)
    return "collision with wall" if (@map[new_position.x][new_position.y]).include?("wall")
    @actor_impls.each do |actor|
      if !actor.nil?
        if actor.position.equals?(new_position)
          return "collision with another actor named: " + actor.name
        end
      end
    end
    return true
  end

  
  def marker_present?(position)
    return false if get_markers_at(position) == []
    return true
  end

  # Gets markers from simulation at given position
  # Returns - Array of MarkerImpl objects
  #         - Empty array if no marker is present
  def get_markers_at(position)
    array = []
    @marker_impls.each do |marker|
      if (marker.position.equals?(position) && marker.actor.nil?)
        # Only add those markers that are not being carried by Actor
        array.push(marker)
      end
    end
    return array
  end

  # Removes marker from given position
  # Returns deleted marker on success, nil otherwise
  def delete_marker_at(position)
    markers = get_markers_at(position)
    if markers != []
      @marker_impls.delete(markers[0])
      return markers[0]
    else
      return nil
    end
  end

  # Puts a marker at given position
  # Returns inserted marker on success, nil otherwise
  def put_marker_at(position, marker)
    markers = get_markers_at(position)
    if (markers.length <= 4)
      @marker_impls.push(marker)
      return marker
    else
      return nil
    end
  end

  def transform(actor_impls, marker_impls)
    output = []

    # Transform all actors
    actor_impls.each do |actor_impl|
      if !actor_impl.nil?
        # Skip any holes
        actor_def = {}
        # Save actor data
        actor_def["row"] = actor_impl.position.x
        actor_def["col"] = actor_impl.position.y
        actor_def["direction"] = actor_impl.direction.to_s
        actor_def["id"] = actor_impl.id
        actor_def["type"] = "actor";

        msgs = actor_impl.get_log()

        if (!msgs.nil?)
          # Save messages if any
          actor_def["messages"] = msgs
        end

        output.push(actor_def)
      end
    end

    # Transform all markers
    marker_impls.each do |marker_impl|
      marker_def = {}
      marker_def["row"] = marker_impl.position.x
      marker_def["col"] = marker_impl.position.y
      marker_def["type"] = "marker";
      output.push(marker_def)
    end

    return output
  end

  # Main function which handles evaluating actions of actors and saves it to database
  # actors - ActorDef structure
  # initial_state - ActorMapDef structure of the starting state
  # map - Map structure of the map to simulate on
  # count - number of steps to generate
  # start - number of step to start from (0 - indicates complete generation)
  def simulate(actors, initial_state, map, count)
    unless self.initialized?
      return false
    end
    @map = map
    # Map is now created, first index is row, second col

    @actor_impls = [];
    @marker_impls = [];

    # Set actor's position according to supplied initial_state
    actors.each do |actor_def| 
      initial_state.each do |actor_map_def|
        if (actor_def["id"] == actor_map_def["id"])
          @actor_impls[actor_def["id"]] = ActorImpl.new(Vector2.new({:x => actor_map_def["row"], :y => actor_map_def["col"]}), Vector2.new({:direction => actor_map_def["direction"]}), actor_def["id"], actor_def["name"], actor_def["source_code"], actor_def["static_code"], self)
        end
      end
      # One-time evaluate static code
      @actor_impls[actor_def["id"]].evaluate_static()
    end

    # Place all markers on the map
    initial_state.each do |marker_map_def|
      if marker_map_def["type"] == "marker"
        @marker_impls << MarkerImpl.new(Vector2.new(:x => marker_map_def["row"], :y => marker_map_def["col"]))
      end
    end

    # Remove all steps prior to simulating
    simulation_steps.each do |step|
        step.destroy()
    end



    # Create a new step containing initial_state
    step = SimulationStep.new()
    step.step_no = 0
    step.data_json = initial_state.to_json
    simulation_steps << step

    # Main simulation loop
    stepcounter = 1
    
    count.times do
      @actor_impls.each do |actor_impl|
        if !actor_impl.nil?
          # Skip any "holes" - non contingent actor ids
          
          # Save old position of an actor
          old_position = actor_impl.position

          # Evaluate source code
          actor_impl.evaluate
          
          # Pickup marker if required
          if actor_impl.get_state("pickup")
            actor_impl.marker = get_markers_at(old_position)[0]
            actor_impl.marker.actor = actor_impl
          end
          
          # Drop marker if required
          if actor_impl.get_state("drop")
            actor_impl.marker.actor = nil
            actor_impl.marker = nil
          end
          
          # Handle movement
          if actor_impl.get_state("move")
            actor_impl.position = old_position + actor_impl.direction
            # Move any marker that this actor could be carrying
            if !actor_impl.marker.nil?
              actor_impl.marker.move
            end
          end


        end
      end
      simulation_step = SimulationStep.new()
      simulation_step.step_no = stepcounter
      simulation_step.data_json = transform(@actor_impls, @marker_impls).to_json
      simulation_steps << simulation_step
      stepcounter += 1
    end
    self.save()
  end

end
