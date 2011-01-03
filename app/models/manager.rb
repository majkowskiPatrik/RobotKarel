# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'simarea.rb'

class Manager
  attr_reader :simareas

  def initialize
    @simareas = []
  end

  # Vytvori novou simulaci, vraci true pri uspechu
  def create_new_game(name, dimensions)
    max_dimensions = Vector2.new(20,20)
    return false unless dimensions <= max_dimensions
    
    new_sim_area = SimArea.new(name, dimensions)
    @simareas.push(new_sim_area)
    return true
  end

  def destroy_game_by_index(index)
    @simareas.delete_at(index)
  end
end
