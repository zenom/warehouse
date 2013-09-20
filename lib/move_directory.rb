# check the job status periodically
require 'lib/settings'
class MoveDirectory < Struct.new(:from)
  def perform
    folder = from.split("\\").last
    start_folder = Settings::BASE_FOLDER_PATH + from
    destination_folder = Settings::DESTINATION_FOLDER_PATH + '\\' + folder
    
    ap start_folder
    ap destination_folder
    #FileUtils.mv(from, destination_folder)
  end
end