class AdminMailer < ActionMailer::Base

  default :from => "The Puzzle School Admin <support@puzzleschool.com>", :host => ENV['HOST']

  ADMIN_EMAILS = ['services@puzzleschool.com']
  
  def notify(subject, message, extra = {})
    body = "#{message}\n\n\n#{extra.inject(""){|report, entry| report << "\n\n#{entry.first}\n#{entry.last.inspect}" }}"
    mail(
      :to => ADMIN_EMAILS,
      :subject => subject,
      :body => body
    )
  end
end