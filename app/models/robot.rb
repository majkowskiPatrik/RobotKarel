# To change this template, choose Tools | Templates
# and open the template in the editor.

class Vectors
  UP = 8;
  DOWN = 2;
  LEFT = 4;
  RIGHT = 6;
end

class Robot < Actor
  def initialize (x,y, vector)
    @movement_vector = vector;
    super(x,y);
  end


end
