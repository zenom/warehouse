class HistoryController < ApplicationController
  #before_filter :load_details, :only => [:index]
  before_filter :find_content, :only => [:re_process_video, :cancel_processing, :archive, :clear_failed, :update_status, :details]
  before_filter :load_completed_only, :only => [:load_completed, :index]
  before_filter :load_pending_only, :only => [:load_pending, :index]
  before_filter :load_failures_only, :only => [:load_failures, :index]
  before_filter :load_processing_only, :only => [:load_processing, :index]
  before_filter :load_archived_only, :only => [:load_archived, :index]
  before_filter :load_cancels_only, :only => [:load_cancelled, :index]
  
  after_filter :load_completed_only, :only => [:archive]
  after_filter :load_pending_only, :only => [:clear_failed]
  after_filter :load_failures_only, :only => [:re_process_video]
  after_filter :load_processing_only, :only => [:re_process_video]
  after_filter :load_archived_only, :only => [:archive]
  after_filter :load_cancels_only, :only => [:cancel_processing]
  
  
  def index
  end
  
  def archive
    @content.archive!
  end
  
  def destroy
    @content = Content.find(params[:id])
    @content.destroy
  end

  def re_process_video
    @content.process_video
  end
  
  def cancel_processing
    @content.cancel!
    @content.last_burn.cancel!
  end
  
  def update_status
    RImageService.job_status(@content.last_burn.job_id)
  end
  
  def clear_failed
    @content.queue_up!
    @old_burns = @content.burns.find_all_by_state(:failed)
    Burn.destroy(@old_burns)
    RImageService.clear_finished_jobs
  end
  
  def load_completed
    render :partial => "history/completed"
  end
  
  def load_processing
    render :partial => "history/processing"
  end
  
  def load_failures
    render :partial => "history/failures"
  end
  
  def load_pending
    render :partial => "history/pending"
  end

  def load_archived
    render :partial => "history/archived"
  end
  
  def load_cancelled
    render :partial => "history/cancelled"
  end
  
  def search_completed
    @completed = Content.completed.search_for(params[:q]).paginate :page => params[:page], :per_page => 10
    ap @completed
    render :partial => "history/completed"
  end
  
  def search_archived
    @archived = Content.archived.search_for(params[:q]).paginate :page => params[:page], :per_page => 10
    render :partial => "history/archived"
  end
  
  def details

  end
  
  private
    def find_content
      @content = Content.find(params[:history_id])
    end
    
    def load_all
      load_completed_only
      load_pending_only
      load_failures_only
      load_processing_only
      load_archived_only
      load_cancels_only
    end
    
    def load_completed_only
      @completed = Content.completed.paginate :page => params[:page], :per_page => 10
    end
    
    def load_pending_only
      @pending = Content.pending
    end
    
    def load_failures_only
      @failures = Content.failed
    end
    
    def load_processing_only
      @processing = Content.processing
    end
    
    def load_archived_only
      @archived = Content.archived.paginate :page => params[:page], :per_page => 10
    end
    
    def load_cancels_only
      @cancels = Content.cancelled
    end
    
    
end
