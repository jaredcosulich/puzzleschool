class WelcomeController < ApplicationController
  
  def index
    @subscriber = Subscriber.new
  end
  
end