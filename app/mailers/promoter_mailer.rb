class PromoterMailer < ActionMailer::Base
  default :from => "MH admin <mobilizinghealth@gmail.com>"
  default :to => "David <david@mobilizinghealth.org>"

  def admin_notification(promoter)
    @promoter = promoter
    mail(:subject => "New promoter on site")
  end

  def registration_confirmation(promoter)
    @promoter = promoter
    mail(:to => "#{promoter.name} <#{promoter.email}>", :subject => "Registered")
  end
end
