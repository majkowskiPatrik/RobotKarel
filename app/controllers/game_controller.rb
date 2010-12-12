require 'manager.rb'

class GameController < ApplicationController
  def index
    if session[:manager].nil?
      session[:manager] = Manager.new()
    end
    manager = session[:manager]
    @simareas = manager.simareas
  end

  def create
    session[:manager].create_new_game(params[:sim_name],Integer(params[:sim_width]),Integer(params[:sim_height]))
    redirect_to :controller => 'game', :action => 'index'
  end

  def connect
    session[:active_sim] = session[:manager].simareas[Integer(params[:id])]
    redirect_to :controller => 'game', :action => 'main_screen'
  end

  def main_screen

  end

  def render_simarea
    @simarea = session[:active_sim]


  end

end
