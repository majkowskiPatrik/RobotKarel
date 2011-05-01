require 'json'

class SimulationsController < ApplicationController
  # GET /simulations
  # GET /simulations.xml
  def index
    @simulations = Simulation.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @simulations }
    end
  end

  # GET /simulations/1
  # GET /simulations/1.xml
  def show
    @simulation = Simulation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @simulation }
    end
  end

  # GET /simulations/new
  # GET /simulations/new.xml
  def new
    @simulation = Simulation.new
    @maps = Map.all

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @simulation }
    end
  end

  # GET /simulations/1/edit
  def edit
    @simulation = Simulation.find(params[:id])
    @maps = Map.all
  end

  # POST /simulations
  # POST /simulations.xml
  def create
    @simulation = Simulation.new(params[:simulation])
    @simulation.map_json = Map.find_by_id(params[:map][:map_id]).data

    if @simulation.save
      if (params[:place_actors].nil?)
        redirect_to(@simulation, :notice => 'Simulation was successfully created.')
      else
        @actors = Actor.find(:all);
        render :action => "place_actors", :params => {:id => @simulation.id},  :locals => { :actors => @actors }
      end
    else
      render :action => "new"
    end
  end

  def place_actors
    @actors = Actor.find(:all)
    @simulation = Simulation.find_by_id(params[:id])
  end

  def get_map
    map_json = Simulation.find_by_id(params[:simulation_id]).map_json
    respond_to do |format|
      format.json {
        render :json => { :data => map_json }
      }
    end
  end

  def get_actors
    simulation = Simulation.find_by_id(params[:id])
    actors_json = simulation.actors_json

    respond_to do |format|
      format.json {
        render :json => { :data => actors_json }
      }
    end
  end

  def get_initial_state
    simulation = Simulation.find_by_id(params[:id])
    data = {}
    data_json = nil;

    if (!simulation.nil? && simulation.initialized?)
      data["actors"] = simulation.actors_json
      data["initial_state"] = simulation.simulation_steps[0].data_json
    end

    data_json = data.to_json

    respond_to do |format|
      format.json {
        render :json => { :data => data_json }
      }
    end
  end

  def save_sim
    # Find appropriate simulation
    simulation = Simulation.find_by_id(params[:id]);
    if !simulation.nil?
      # Clear any existing steps
      simulation.simulation_steps = [];

      params[:actors].each do |actor|
        # Convert br tags into actual newlines - newline character is not being sent via AJAX
        actor[:source_code].gsub!("<br />", "\r\n")
        actor[:static_code].gsub!("<br />", "\r\n")
      end

      # Save actor data to DB
      simulation.actors_json = params[:actors].to_json

      # Create first simulation step
      simulation_step = SimulationStep.new
      simulation_step.step_no = 0;
      # Use data supplied by user as a first step
      simulation_step.data_json = params[:initialState].to_json

      simulation.simulation_steps = []
      simulation.simulation_steps << simulation_step

      simulation.save()
    end
    render :nothing => true
  end


  # PUT /simulations/1
  # PUT /simulations/1.xml
  def update
    @simulation = Simulation.find(params[:id])

    respond_to do |format|
      if @simulation.update_attributes(params[:simulation])
        format.html { redirect_to(@simulation, :notice => 'Simulation was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @simulation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /simulations/1
  # DELETE /simulations/1.xml
  def destroy_it
    @simulation = Simulation.find(params[:id])
    @simulation.destroy

    respond_to do |format|
      format.html { redirect_to(simulations_url) }
      format.xml  { head :ok }
    end
  end

  def simulate
    # Get simulation from DB
    @simulation = Simulation.find_by_id(params[:id])
    @simulations = Simulation.all

    unless (@simulation.initialized?)
      flash[:notice] = "Cannot simulate unitialized simulation!"
      render :action => "index", :locals => { :simulations => @simulations }
    end

    @simulation.simulate(JSON.parse(@simulation.actors_json), JSON.parse(@simulation.simulation_steps.first.data_json), JSON.parse(@simulation.map_json), Integer(params[:count]))
    render :text => "OK"
  end

  def get_story
    story = []
    simulation_steps = Simulation.find_by_id(params[:id]).simulation_steps
    simulation_steps.each do |ss|
      story << JSON.parse(ss.data_json)
    end

    story_json = story.to_json

    respond_to do |format|
      format.json {
        render :json => { :data => story_json }
      }
    end
  end

  def watch
    @simulation = Simulation.find_by_id(params[:id]) 
    unless (@simulation.initialized?)
      flash[:notice] = "Cannot simulate unitialized simulation!"
      redirect_to :action => "index"
    end
    
  end


end
