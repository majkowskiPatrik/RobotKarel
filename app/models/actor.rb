# To change this template, choose Tools | Templates
# and open the template in the editor.
# Trida reprezentujici 2-prvkovy vektor
class Vector2
  attr_accessor :x,:y
  def initialize(x,y)
    @x = x
    @y = y
  end
  
  def +(other_vector)
    @x = @x + other_vector.x
    @y = @y + other_vector.y
    return self
  end

  def equals?(other_vector)
    return true if ((@x == other_vector.x) && (@y == other_vector.y))
    return false
  end

  def <=(other_vector)
    return true if ((@x <= other_vector.x) && (@y <= other_vector.y))
    return false
  end

  def to_s
    vf = Vector2Factory.new()
    return "left" if self.equals?(vf.left)
    return "right" if self.equals?(vf.right)
    return "up" if self.equals?(vf.up)
    return "down" if self.equals?(vf.down)
    return "unknown"
  end

end

class Vector2Factory
  def left
    return Vector2.new(-1,0)
  end
  
  def right
    return Vector2.new(1,0)
  end
  
  def up
    return Vector2.new(0,-1)
  end
  
  def down
    return Vector2.new(0,1)
  end
end

class ActorTypes
  ROBOT = 1
  EMPTY = 0
end

class Actor
  attr_reader :position,:name

  def initialize (name,position,simarea)
    @position = position
    @name = name
    @simarea = simarea
  end
end
