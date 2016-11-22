class SubscribersController < ApplicationController

  # POST /subscribers
  # POST /subscribers.json
  def create
    @subscriber = Subscriber.new(subscriber_params)

    respond_to do |format|
      if @subscriber.save
        format.html { redirect_to root_path, notice: "Thanks! We'll update you as things progress." }
        format.json { render :show, status: :created, location: @subscriber }
      else
        format.html { edirect_to root_path, notice: "There was an error saving your subscription. Please try again." }
        format.json { render json: @subscriber.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def subscriber_params
      params.require(:subscriber).permit(:name, :email, :notes)
    end
end
