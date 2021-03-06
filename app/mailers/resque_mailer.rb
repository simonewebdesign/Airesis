#encoding: utf-8
class ResqueMailer < ActionMailer::Base
  include Resque::Mailer
  default from: "Airesis <info@airesis.it>"

  layout 'maktoub/newsletter_mailer'
  
  def notification(alert_id)
    @alert = UserAlert.find(alert_id)
    to_id = @alert.notification.data['to_id']
    if to_id
      mail(:to => "discussion+#{to_id}@airesis.it", :bcc => @alert.user.email, :subject => @alert.notification.notification_type.email_subject)
    else
      mail(:to => @alert.user.email, :subject => @alert.notification.notification_type.email_subject)
    end
  end
  
  def admin_message(msg)
    @msg = msg
    mail(:to => 'coorasse+daily@gmail.com', :subject => APP_SHORT_NAME + " - Messaggio di amministrazione")
  end


  def info_message(msg)
    mail(:to => 'coorasse+info@gmail.com', :subject => APP_SHORT_NAME + " - Messaggio di informazione")
  end

  #invia un invito ad iscriversi al gruppo
  def invite(group_invitation_id)
    @group_invitation = GroupInvitation.find(group_invitation_id)
    @group_invitation_email = @group_invitation.group_invitation_email
    @group = @group_invitation_email.group
    mail(:to => @group_invitation_email.email, :subject => "Invito ad iscriversi a #{@group.name}")
  end

  def user_message(subject,body,from_id,to_id)
    @body = body
    @from = User.find(from_id)
    @to = User.find(to_id)
    mail(to: @to.email, from: "Airesis <noreply@airesis.it>", reply_to: @from.email, subject: subject)
  end


  def publish(newsletter_name, params)
    receiver = params['receiver']
    if receiver == 'all'
      @users = User.all
    elsif receiver == 'not_confirmed'
      @users = User.unconfirmed.all
    elsif receiver == 'test'
      @users = User.all(limit: 1)
    elsif receiver == 'admin'
      @users = User.find_all_by_login('admin')
    elsif receiver == 'portavoce'
      raise Exception
    end
    @users.each do |user|
      mail_fields = {
        subject: params['subject'],
        to: user.email
      }
      @name = user.fullname

      mail(mail_fields) do |format|
        format.html { render("maktoub/newsletters/#{newsletter_name}") }
      end
    end
  end
end
