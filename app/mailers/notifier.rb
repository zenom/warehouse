class Notifier < ActionMailer::Base
  default :from => "warehouse@belator.com"
  
  def burn_completed(content, recipient)
    @content      = content
    mail(:to => "andy@zenjavi.com", :subject => "BURN COMPLETED: #{content.destination_folder}")
  end
  
  def burn_failed(content, recipient)
    @content      = content
    mail(:to => "andy@zenjavi.com", :subject => "JOB FAILED: #{content.destination_folder}")
  end
  
  def burn_processing(content, recipient)
    mail(:to => "andy@zenjavi.com", :subject => "PROCESSING: #{content.destination_folder}")
  end
  
  def archived(content, recipient)
    mail(:to => "andy@zenjavi.com", :subject => "CONTENT ARCHIVED: #{content.destination_folder}")
  end
  
  def cancelled(content, recipient)
    mail(:to => "andy@zenjavi.com", :subject => "JOB CANCELLED: #{content.destination_folder}")
  end
  
  def transcode_started(directory, type)
    mail(:to => "andy@zenjavi.com", :subject => "Transcode Started: #{directory} - #{type}")
  end
  
  def transcode_completed(directory, type)
    mail(:to => "andy@zenjavi.com", :subject => "Transcode Completed: #{directory} - #{type}")
  end
  
  def transcode_failed(directory, type)
    mail(:to => "andy@zenjavi.com", :subject => "Transcode Failed: #{directory} - #{type}")
  end
  
end
