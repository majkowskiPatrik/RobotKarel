# To change this template, choose Tools | Templates
# and open the template in the editor.

class Robot < Actor
  attr_accessor :direction

  def initialize (name, position, direction, simarea)
    @direction = direction
    super(name,position,simarea)
  end

  # Posunuti robota ve smeru jeho pohybu - elementarni prikaz
  def move
    new_position = @position + @direction
    if (@simarea.valid_move?(new_position))
      @position = new_position
      return true
    else
      return false
    end
  end
  
  # Dotaz na moznost pohybu ve smeru - elementarni prikaz
  def move_possible
    new_position = @position + @direction
    return @simarea.valid_move?(new_position)
  end

  # Otoceni robota o 90 stupnu doleva - elementarni prikaz
  def turn_right
    vf = Vector2Factory.new
    if @direction.equals?(vf.right) # stary smer doprava
      @direction = vf.down # novy smer dolu
    elsif @direction.equals?(vf.down) # stary smer dolu
      @direction = vf.left # novy smer doleva
    elsif @direction.equals?(vf.left) # stary smer doleva
      @direction = vf.up # novy smer nahoru
    elsif @direction.equals?(vf.up) # stary smer nahoru
      @direction = vf.right # novy smer doprava
    end
  end

  # Program pro daneho robota - vznika skladanim elementarnich prikazu
  # Pozdeji bude moznost konfigurace uzivatelem a vykonavani EVALem
  def program
    turn_right
    move
  end

end
