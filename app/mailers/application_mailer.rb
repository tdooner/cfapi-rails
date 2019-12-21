class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@brigade.network'
  layout 'mailer'
end
