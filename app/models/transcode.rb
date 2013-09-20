class Transcode < ActiveRecord::Base
  
  class << self
    def create_from_params! params
      directory = params[:directory]
      directory = File.dirname(directory.split("WATCHES")[1])
      if Transcode.exists?(:directory => directory)
        # handle incrementing the count
        @trans = Transcode.find_by_directory(directory)
        @trans.increment!(:series_count)
        
        if @trans.series_count == @trans.series_total:
          @trans.destroy
          # send email
          Notifier.transcode_completed(@trans.directory).deliver
        end
        
      else
        # add a new one.
        t = self.new
        t.directory = directory
        t.series_total = params.key?(:total) ? params[:total].to_i : 16
        t.started = Time.now
        t.type = params.key?(:type) ? params[:type] : 'video'
        t.completed = false
        if t.save!
          # trigger delayed job to check in 6 hours if this directory has completed
          Notifier.transcode_started(directory, type).deliver
          Delayed::Job.enqueue(TranscodeJob.new(directory, type), 0, 6.hours.from_now)
        else 
          return false
        end
      end
      
    end
  end
  
end
