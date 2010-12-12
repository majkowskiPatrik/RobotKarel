# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'simarea.rb'

class Manager
  attr_reader :simareas

  def initialize
    @simareas = []
  end

  def create_new_game(name, width, height)
    p "create_new_game(#{name},#{width},#{height})"
    new_sim_area = SimArea.new(name, width, height)
    @simareas.push(new_sim_area)
  end
end
