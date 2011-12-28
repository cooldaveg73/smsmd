class PromoterMailer < ActionMailer::Base
  default :from => "MH admin <mobilizinghealth@gmail.com>"

  def admin_notification(promoter, user)
    @promoter = promoter
    mail(:subject => "New promoter on site", :to => user.email)
  end

  def promoter_notification(promoter)
    @promoter = promoter
    mail(:to => "#{promoter.name} <#{promoter.email}>", 
      :subject => "New Project for Mobilizing Health")
  end

  def registration_confirmation(promoter, user, temp_pass)
    @temp_pass = temp_pass
    @promoter = promoter
    @user = user
    mail(:to => "#{promoter.name} <#{promoter.email}>", 
      :subject => "Registered for a new project with Mobilizing Health")
  end
end
