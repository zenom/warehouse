require 'config/environment'
require 'lib/settings'
desc "Find new content in the watch folder."
task :find_content do
  Folder.find_new_content
end