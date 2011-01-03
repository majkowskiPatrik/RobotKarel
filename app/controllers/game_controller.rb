require 'manager.rb'

class GameController < ApplicationController
  def index
    if session[:manager].nil?
      session[:manager] = Manager.new()
      flash[:notice] = "Založen nový Manager"
    end
    manager = session[:manager]
    @simareas = manager.simareas
  end

  def create
    if session[:manager].create_new_game(params[:sim_name],Vector2.new(Integer(params[:sim_width]),Integer(params[:sim_height])))
      flash[:notice] = "Simulace úspěšně vytvořena"
    else
      flash[:error] = "Nelze vytvořit simulaci"
    end
    redirect_to :controller => 'game', :action => 'index'
  end

  def destroy
    session[:manager].destroy_game_by_index(Integer(params[:index]))
    flash[:notice] = "LOL"
    redirect_to :controller => 'game', :action => 'index'
  end

  def connect
    session[:active_sim] = session[:manager].simareas[Integer(params[:index])]
    redirect_to :controller => 'game', :action => 'main_screen'
  end

  def main_screen

  end

  def destroy_manager
    session[:manager] = nil
    redirect_to :controller => 'game', :action => 'index'
  end

  def render_simarea
    @simarea = session[:active_sim]
    render :layout => false
  end

  def create_actor
    simarea = session[:active_sim]
    vector_factory = Vector2Factory.new

    if simarea.add_actor(Robot.new(params[:name], Vector2.new(Integer(params[:posx]), Integer(params[:posy])), vector_factory.down, simarea))
      flash[:notice] = "Aktér úspešně založen"
    else
      flash[:error] = "Nelze založit aktéra - pole je buďto zabrané, nebo neexistuje"
    end
    redirect_to :controller => 'game', :action => 'main_screen'
  end

  def move_actors
    simarea = session[:active_sim]

    simarea.actors.each do |actor|
      actor.program
    end

    render :nothing => true
  end

end
