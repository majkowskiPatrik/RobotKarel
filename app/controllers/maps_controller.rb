class MapsController < ApplicationController
  # GET /maps
  # GET /maps.xml
  def index
    @maps = Map.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /maps/1
  # GET /maps/1.xml
  def show
    @map = Map.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /maps/new
  # GET /maps/new.xml
  def new
    @map = Map.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /maps/1/edit
  def edit
    @map = Map.find(params[:id])
  end

  # POST /maps
  # POST /maps.xml
  def create
    valid = true
    @map = nil
    begin
      valid = false if params[:size] == ""
      size = params[:size].to_i
      valid = false if (size < 0) || (size > 30)
    rescue Exception => e
      valid = false
    end

    if valid
      @map = Map.new(params[:map])
      # prepare empty JSON data
      map = Array.new(params[:size].to_i) { Array.new(params[:size].to_i, []) }
      @map.data = map.to_json
      @map.save
    end

    respond_to do |format|
      if valid
        flash[:notice] = "Map successfully created"
        format.html { redirect_to :action => "edit", :id => @map.id }
      else
        flash[:notice] = "Cannot create map (wrong dimensions ?)"
        format.html { redirect_to :action => "index" }
      end
    end
  end

  # PUT /maps/1
  # PUT /maps/1.xml
  def update
    @map = Map.find(params[:id])

    respond_to do |format|
      if @map.update_attributes(params[:map])
        format.html { redirect_to(@map, :notice => 'Map was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /maps/1
  # DELETE /maps/1.xml
  def destroy_it
    @map = Map.find(params[:id])
    @map.destroy

    respond_to do |format|
      format.html { redirect_to(maps_url) }
    end
  end

  # GET maps/1/get_map
  def get_map
    @map = Map.find(params[:id])
    render :json => { :data => @map.data }
  end

  def save_map    
    @map = Map.find(params[:id])
    @map.data = params[:_json].to_json
    @map.save()
    render :text => "OK"
  end
  
end
