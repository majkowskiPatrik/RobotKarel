class TestController < ApplicationController
  def lol
    session["Timer"] = 1;
  end

  def lol2
    @i = session["Timer"];
  end

  def tick
    @i = session["Timer"];
    session["Timer"] = @i + 1;
    render :nothing => true
  end

end
