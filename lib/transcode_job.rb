# check the job status periodically
require 'lib/settings'
class TranscodeJob < Struct.new(:directory, :type)
  def perform
    transcode = Transcode.find_by_directory(directory)
    Notifier.transcode_failed(directory, type).deliver unless transcode.nil?
  end
end