# check the job status periodically
require 'lib/settings'
class JobStatus < Struct.new(:content_id)
  def perform
    content = Content.find(content_id)
    content.status
    return unless content.processing?
    Delayed::Job.enqueue(JobStatus.new(content.id), 0,  Settings::POLLING_INTERVAL.seconds.from_now)
  end
end