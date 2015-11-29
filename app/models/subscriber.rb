class Subscriber < ActiveRecord::Base
  after_create :notify_admin

  private
  
  def notify_admin
    AdminMailer.notify("A new Puzzle School subscriber was created.", "New subscriber details:", {:subscriber => self}).deliver_later
  end

end
