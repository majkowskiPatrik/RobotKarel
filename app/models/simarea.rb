# To change this template, choose Tools | Templates
# and open the template in the editor.

class SimArea
  attr_reader :name,:width,:height,:actors

  def initialize (name, width, height)
    @name = name;
    @width = width;
    @height = height;
    @actors = [];
    p "Zalozena SimArea, name:#{name}"
  end

  def add_actor (actor)
    @actors.push(actor);
  end


end
