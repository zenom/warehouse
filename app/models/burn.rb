class Burn < ActiveRecord::Base
  require 'rimage_service'
  serialize :directory_files
  include ActiveRecord::Transitions
  belongs_to :content
  
  # NOTE: These statuses might not be correct as they rely on the web interface to be up and working full time.
  # On a page reload it should grab the new status if the row displayed calls the `status` method from the content
  # model. Otherwise some of these could be in improper states.
  
  state_machine do
    state :waiting
    state :cancelled
    state :burning
    state :printing
    state :imaging 
    state :failed
    state :completed
    
    event :failed do
      transitions :to => :failed, :from => [:waiting, :burning, :printing, :failed, :imaging, :cancelled]
    end
    
    event :complete do
      transitions :to => :completed, :from => [:waiting, :burning, :printing, :completed, :imaging, :cancelled]
    end
    
    event :burn do
      transitions :to => :burning, :from => [:waiting, :printing, :imaging, :burning, :failed, :completed, :cancelled]
    end
    
    event :image do
      transitions :to => :imaging, :from => [:waiting, :imaging, :printing, :failed, :burning, :completed, :cancelled]
    end
    
    event :print do
      transitions :to => :printing, :from => [:waiting, :burning, :imaging, :printing, :failed, :completed, :cancelled]
    end
    
    event :wait do
      transitions :to => :waiting, :from => [:burning, :printing, :imaging, :waiting, :failed, :completed, :cancelled]
    end
    
    event :cancel do
      transitions :to => :cancelled, :from => [:waiting, :burning, :printing, :cancelled, :imaging, :failed, :completed]
    end
    
  end
  
  before_create :build_burn
  
  scope :completed, where(:state => :completed)
  
  def build_burn
    self.burn_date = DateTime.now
    @file_path = "#{self.content.folder.folder}\\#{self.content.destination_folder}"
    build_file_list
    
    #ap @file_path
    result = self.content.dvd? ? RImageService.submit_dvd(@file_path) : RImageService.submit_blueray(@file_path)

    if !result[:error_message].nil?
      self.message = result[:error_message]
      self.state = :failed
      self.content.message = self.message
    else
      self.content.message = nil
      self.content.state = :processing
      self.job_id = result[:job_id]
      Delayed::Job.enqueue(JobStatus.new(self.content.id), 0, Settings::POLLING_INTERVAL.seconds.from_now)
    end
    
  end
  
  private
    def build_file_list
      self.directory_files = Dir["#{@file_path}\\**\\*.*"]
    end
  
end