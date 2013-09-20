class Folder < ActiveRecord::Base
  has_many :contents
  
  validates :folder , :presence => true
  validates :title, :presence => true
  validates :media, :presence => true
  validates :content_type, :presence => true
  
  
  
  class << self
    
    # finds new content in the watch folders
    def find_new_content
      Folder.all.each do |folder|
        dir = "#{Settings::BASE_FOLDER_PATH}#{folder.folder}"
        ap dir
        # break out of the loop if the directory doesnt exist.
        next unless File.directory? dir
        
        top_level_dirs = Dir["#{dir}/*/"]
      
        puts "Checking #{dir}...."
        top_level_dirs.each do |directory|
          add_content(directory, folder)
        end
        
      end # end folder
    end # end def
    
    
    private
      def add_content(directory, folder)
        content_dir =  File.basename(directory)
        
        if Content.exists?(:destination_folder => content_dir)
          content = Content.find_by_destination_folder(content_dir)
          
          if content.directory_hash != directory_hash(directory)
            content.update_attribute(:directory_hash, directory_hash(directory))
          else
            # need to do this so we can switch states on error.
            content.process_video if content.pending?
          end
          
        else
          content = Content.new :destination_folder => content_dir, :found_date => DateTime.now, :folder_id => folder.id,
            :directory_hash => directory_hash(directory), :content_type => folder.content_type, :media => folder.media
          content.save!
        end
        
      end
      
      def directory_hash(directory)
        Digest::SHA1.hexdigest Dir["#{directory}/**/*"].to_s
      end
    
  end


  
  
  
end
