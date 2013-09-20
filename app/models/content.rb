class Content < ActiveRecord::Base
  include ActiveRecord::Transitions
  has_many :burns, :dependent => :destroy
  belongs_to :folder
  

  scoped_search :on => [:cadre_title, :destination_folder]

  # for pagination
  cattr_reader :per_page
  @@per_page = 10
  
  state_machine do
    state :pending # when its found
    state :processing # when its processing
    state :cancelled # when the hash stopped changing and we an continue
    state :complete # when it is completed
    state :archived # just added this not sure if we need it for something
    state :failed # for failed items.
    
    # mark it completed
    event :completed do
      transitions :to => :complete, :from => [:processing], :on_transition => :do_completion
    end
    
    # mark it as processing 
    event :process do
      transitions :to => :processing, :from => [:pending, :failed, :complete, :cancelled], :on_transition => :do_processing
    end
    
    event :queue_up do
      transitions :to => :pending, :from => [:failed, :processing]
    end
    
    event :archive do
      transitions :to => :archived, :from => [:complete], :on_transition => :do_archived
    end
    
    event :cancel do
      transitions :to => :cancelled, :from => [:processing], :on_transition => :do_cancel
    end
    
    event :fail do
      transitions :to => :failed, :from => [:processing, :pending, :cancelled, :failed, :complete], :on_transition => :do_failed
    end
    
  end
  
  scope :completed, where(:state => :complete)
  scope :failed, where(:state => :failed)# show burns that have failed
  scope :pending, where(:state => :pending)
  scope :archived, where(:state => :archived)
  scope :cancelled, where(:state => :cancelled)
  scope :processing, where(:state => :processing)

  before_create :get_cadre_data
  
  # do we have items processing already?
  def self.has_processing?
    Content.processing.count > 0 ? true : false
  end
  
  # Last burn for this set.
  def last_burn
    self.burns.last
  end
  
  # Is this a dvd disc.
  def dvd?
    self.media == "DVD"
  end
  
  # Is this a blue ray disc.
  def blueray?
    self.media == "Blue Ray"
  end
  
  # This is used because it needs to be able to handle failures.
  # otherwise it was always setting to processing. This way we 
  # can faiures in the content itself.
  def process_video
    burn_job = self.burns.create
    self.process! unless burn_job.failed? 
    self.fail! if burn_job.failed?
  end
  
  # Check the RImage server for a job status.
  def status
    job_status = RImageService.job_status(self.last_burn.job_id)[:stage] unless self.last_burn.nil?
    case job_status.downcase
    when /cancelled/; self.cancel!; self.last_burn.cancel!; "Cancelled"
    when /recording/; self.last_burn.burn!; "Recording"
    when /waiting_for_imaging/; "Waiting"
    when /imaging/; self.last_burn.image!; "Imaging"
    when /printing/; self.last_burn.print!; "Printing"
    when /done/; self.completed!; self.last_burn.complete!; "Completed"
    else "Working"
    end
  end
  

  private
    # Run this when an entry is cancelled.
    def do_cancel
      self.message = nil
      RImageService.cancel_job(self.last_burn.job_id) unless self.last_burn.nil?
      Notifier.cancelled(self, nil).deliver
    end
  
    # Run this when an entry is completed.
    def do_completion
      self.message = nil
      folder = self.folder.folder + '\\' + self.destination_folder
      Delayed::Job.enqueue(MoveDirectory.new(folder))
      Notifier.burn_completed(self, nil).deliver
    end
  
    def do_processing
      self.message = nil
      # generate the data and send it to soap function
      Notifier.burn_processing(self, nil).deliver
    end
    
    def do_archived
      self.message = nil
      self.archived_date = DateTime.now
      Notifier.archived(self, nil).deliver
    end
  
    def do_failed
      Notifier.burn_failed(self, nil).deliver
    end
  
    def get_cadre_data
      pgsql_connection
      # here we get the cadre data and populate title, maybe add performers to a separate performer model.
      if self.content_type == 'Photo'
        query = "SELECT title FROM cms.pictures WHERE directory LIKE '%#{self.destination_folder}' LIMIT 1"
      elsif self.content_type == 'Video'
        query = "SELECT title FROM cms.video WHERE directory LIKE '%#{self.destination_folder}' LIMIT 1"
      elsif self.content_type == 'Live'
        query = "SELECT title FROM cms.live_shows WHERE archived_dir = '#{self.destination_folder}' LIMIT 1"
      else #DVD
        query = "SELECT title FROM cms.video WHERE directory LIKE '%#{self.destination_folder}' LIMIT 1"
      end
      result = @conn.exec(query)
      content = result.find.first
      self.cadre_title = content.nil? ? "Unknown Title" : content['title']
    end
    
    def pgsql_connection
      @conn = PGconn.connect('localhost', 5432, '', '', 'site_management', 'minerva', '#')
    end
  
end
