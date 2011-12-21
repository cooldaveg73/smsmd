class PromoterMailer < ActionMailer::Base
  default :from => "MH admin <mobilizinghealth@gmail.com>"

  def admin_notification(promoter, user)
    @promoter = promoter
    mail(:subject => "New promoter on site", :to => user.email)
  end

  def promoter_notification(promoter)
    @promoter = promoter

  end

  def registration_confirmation(promoter)
    @promoter = promoter
    mail(:to => "#{promoter.name} <#{promoter.email}>", :subject => "Registered")
  end
end
