# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'actor.rb'
require 'robot.rb'

class SimArea
  attr_reader :name,:dimensions,:actors

  def initialize (name, dimensions)
    @name = name
    @dimensions = dimensions
    @actors = []
  end

  # Vlozi noveho aktera do simulace, pokud jiz na actorove pozici neco je, nic nevlozi a vraci false
  def add_actor (actor)
    if (get_field(actor.position) == nil)
      @actors.push(actor)
      return true
    else
      return false
    end
  end

  # Metoda vraci true/false podle toho, zda je mozno na uvedenou pozici posunout Actora
  def valid_move?(vector)
    # Osetreni uteceni z hraci plochy
    return false if ((vector.x < 0) || (vector.y < 0))
    return false if vector.x > @dimensions.x
    return false if vector.y > @dimensions.y

    # Kolize s ostatnimi actory
    return false if (get_field(vector) != nil)
    
    return true
  end

  # Vraci objekt na policku (nil pokud tam nic neni)
  def get_field(vector)
    @actors.each do |actor|
      return actor if actor.position.equals?(vector)
    end

    return nil
  end

end
