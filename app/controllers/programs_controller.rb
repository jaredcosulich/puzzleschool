class ProgramsController < ApplicationController

  def show
    render params[:id]
  end

end
