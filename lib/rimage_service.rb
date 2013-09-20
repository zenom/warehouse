require 'handsoap'

# SOAP Class to interface with our RImage Burner & Labeler.
class RImageService < Handsoap::Service
  endpoint :uri => "http://rimage:55555/RmJobService.svc", :version => 1
  on_create_document do |doc|
    envelope = doc.find('Envelope')
    envelope.set_attr("xmlns:rmj", "http://www.rimage.com/RmJobService")
    envelope.set_attr("xmlns:rim", "http://schemas.datacontract.org/2004/07/Rimage.Web.Service")
    envelope.set_attr("xmlns:arr", "http://schemas.microsoft.com/2003/10/Serialization/Arrays")
  end
  
  def on_response_document(doc)
    doc.add_namespace "s", "http://schemas.xmlsoap.org/soap/envelope/"
    doc.add_namespace "a", "http://schemas.datacontract.org/2004/07/Rimage.Web.Service"
  end
  
  # Get the status of an existing job from the RImage burner.
  # @param [String] - The job id for this request.
  # @return [Hash] Result of the request.
  def job_status(job_id)
    soap_action = "http://www.rimage.com/RmJobService/IRmJobService/GetJobStatus"
    response = invoke("rmj:GetJobStatus", :soap_action => soap_action) do |message|
      message.add "rmj:request" do |req|
        req.add "rim:CallerId", "Warehouse"
        req.add "rim:JobId", job_id
      end
    end
    parse_submit_job(response.document.xpath("//s:Body").first)
  end
  
  # Cancel an existing job on the RImage server.
  # @param [String] - The job id for this request.
  # @return [Hash] Result of the request.
  def cancel_job(job_id, caller="Warehouse")
    soap_action = "http://www.rimage.com/RmJobService/IRmJobService/CancelJob"
    response = invoke("rmj:CancelJob", :soap_action => soap_action) do |message|
      message.add "rmj:request" do |req|
        req.add "rim:CallerId", caller
        req.add "rim:JobId", job_id
      end
    end
    parse_submit_job(response.document.xpath("//s:Body").first)
  end
  
  # Clear all finished jobs on the server.
  # @return [Hash] Result of the request.
  def clear_finished_jobs
    soap_action = "http://www.rimage.com/RmJobService/IRmJobService/CleanupFinishedJobs"
    response = invoke("rmj:CleanupFinishedJobs", :soap_action => soap_action) do |message|
      message.add "rmj:request" do |req|
        req.add "rim:CallerId", "Warehouse"
      end
    end
    parse_submit_job(response.document.xpath("//s:Body").first)
  end
  
  # Cancel all jobs, not accessible via the web.
  # @return [Boolean, Hash] True if it worked, hash of errors if it had problems.
  def cancel_all_jobs
    errors = []
    job_list = get_all_jobs
    job_list.each do |job|
      res = cancel_job(job[:job_id], job[:caller_id])
      if !res[:error_message].nil? || res[:error_code] != "0"
        error = {
          :job_id => job[:job_id],
          :error_code => res[:error_code],
          :error_message => res[:error_message],
        }
        errors << error
      end
    end
    return errors.empty? ? true : errors
  end
  
  # Submit a DVD for burning.
  # @param [String] - Path to the watch folder.
  # @return [Hash] Result of the request.
  def submit_dvd(path)
    
    soap_action = "http://www.rimage.com/RmJobService/IRmJobService/SubmitJob"
    path = Settings::BASE_FOLDER_PATH + path
    @folder = path.split("\\").last
    response = invoke("rmj:SubmitJob", :soap_action => soap_action) do |message|
      message.add "rmj:request" do |req|
        req.add "rim:CallerId", "Warehouse"
        build_dvd(req, path)
      end
    end
    parse_submit_job(response.document.xpath("//s:Body").first)
  end
  
  # Submit a BlueRay for burning.
  # @param [String] - Path to the watch folder.
  # @return [Hash] Result of the request.
  def submit_blueray(path)
    soap_action = "http://www.rimage.com/RmJobService/IRmJobService/SubmitJob"
    path = Settings::BASE_FOLDER_PATH + path
    @folder = path.split("\\").last
    response = invoke("rmj:SubmitJob", :soap_action => soap_action) do |message|
      message.add "rmj:request" do |req|
        req.add "rim:CallerId", "Warehouse"
        build_dvd(req, path)
      end
    end
    parse_submit_job(response.document.xpath("//s:Body").first)
  end
  
  
  private 
    # Get a list of all the current jobs on the server.
    # @return [Hash] Result of all the jobs and their status.
    def get_all_jobs 
      soap_action = "http://www.rimage.com/RmJobService/IRmJobService/GetJobStatuses"
      response = invoke("rmj:GetJobStatuses", :soap_action => soap_action) do |message|
        message.add "rmj:request" do |req|
          req.add "rim:CallerId", "Warehouse"
        end
      end
      parse_job_list(response.document.xpath("//s:Body").first)
    end
    
    # Parse the jobs into a hash for reading.
    # @param [Object] - Parent node to start searching.
    # @return [Hash] Result of the request.
    def parse_job_list(node)
      list = []
      (node/"//a:JobStatus").each do |doc|
        job = {
          :caller_id => (doc/".//a:CallerId").to_s,
          :copies_completed => (doc/".//a:CopiesCompleted").to_s,
          :copies_requested => (doc/".//a:CopiesRequested").to_s,
          :error_code => (doc/".//a:ErrorCode").to_s,
          :error_message => (doc/".//a:ErrorMessage").to_s,
          :imaging_time => (doc/".//a:ImagingCompletedTime").to_s,
          :job_id => (doc/".//a:JobId").to_s,
          :percent_completed => (doc/".//a:PercentComplete").to_s,
          :completed_time => (doc/".//a:ProductionCompletedTime").to_s,
          :stage => (doc/".//a:Stage").to_s,
          :state => (doc/".//a:State").to_s,
        }
        list << job
      end
      list
    end
  
  
    # Parse a job response
    # @param [Object - Parent xml node to start searching.
    # @return [Hash] Result of the request.
    def parse_submit_job(node)
      {
        :job_id => (node/"//a:JobId").to_s,
        :error_code => (node/"//a:ErrorCode").to_s,
        :error_message => (node/"//a:ErrorMessage").to_s,
        :copies_requested => (node/"//a:CopiesRequested").to_s,
        :stage => (node/"//a:Stage").to_s,
        :state => (node/"//a:State").to_s,
        :percent_completed => (node/"//a:PercentComplete").to_s,
        :serial => @serial,
      }
    end
  
    # Build a dvd with dvd options for submitting
    # to the RImage server.
    # @param [Object] - The node to add this data too
    # @param [Path] - Path to the directory to burn.
    # @param [String] - Priority (Normal, Low, High)
    def build_dvd(node, path, priority="Normal")
      build_job(node, path, priority, "Dvdr")
    end
    
    # Build a blueray options for submitting
    # to the RImage server.
    # @param [Object] - The node to add this data too
    # @param [Path] - Path to the directory to burn.
    # @param [String] - Priority (Normal, Low, High)
    def build_blueray(node, path, priority="Normal")
      build_job(node, path, priority, "BdDl")
    end
    
    # Build the job parameters we neeed
    # to the RImage server.
    # @param [Object] - The node to add this data too
    # @param [Path] - Path to the directory to burn.
    # @param [String] - Priority (Normal, Low, High)
    # @param [String] - The type of build (BdDl / Dvdr / Cdr)
    def build_job(node, path, priority="Normal", type="BdDl")
      node.add "rim:Job" do |job|
        case type
        when "BdDl"
          blueray_imaging_options(job, path)
        when "Dvdr"
          dvd_imaging_options(job, path)
        end
        job.add "rim:JobId", create_job_id(path)
        job.add "rim:Priority", priority
        production_options(job, type, path)
        job.add "rim:Type", "ImageAndRecord"
      end
      node
    end
    
    # Create a job id based on the path, and the # of items
    # we have in the db. So the last number also shows how 
    # many times this item was burned.
    def create_job_id(path)
      folder = path.split("\\").last
      job_id = "#{folder}-#{Time.now.to_i}"
    end
    
    # [None,Ver102,Ver150,Ver200,Ver201,Ver250,Ver260]
    # [Tao,Sao,Raw,TaoSegmented,SaoSegmented,Skip]-
    # add the imaging options
    # [None,Cdr63,Cdr74,Cdr80,Dvdr,DvdrDl,Bd,BdDl]-
    
    # Build the imaging options for dvd.
    # @param [Object] - The node to add this data to.
    # @param [Path] - Path for the image.
    def dvd_imaging_options(node, path)
      imaging_options(node, path, "Dvdr")
    end
    
    # Build the imaging options for blueray.
    # @param [Object] - The node to add this data to.
    # @param [Path] - Path for the image.
    def blueray_imaging_options(node, path)
      imaging_options(node, path, "BdDl")
    end
    
    # Build the imaging options.
    # @param [Object] - The node to add this data to.
    # @param [Path] - Path for the image.
    # @param [String] - The type of image (Dvdr, BdDl)
    def imaging_options(node, path, image_type)
      destination_folder = path.split("\\").last
      image_path = "#{Settings::IMAGE_FOLDER_PATH}\\%s" % destination_folder
      node.add "rim:ImagingOptions" do |io|
        io.add "rim:AllowOverwrite", true
        io.add "rim:AllowSpanning", true
        io.add "rim:ImageFile" do |image|
          image.add "rim:ImageFilePath", image_path
          image.add "rim:SizeInMinutes", image_type
          #image.add "rim:Type", "Power" if image_type == "Dvdr" # skips imaging goes right to burning. Remove to create image
        end
        io.add "rim:ParentFolders" do |folders|
          folders.add "rim:ParentFolder" do |folder|
            folder.add "rim:ParentFolderPath", path
          end
        end
        
        if image_type == 'Dvdr'
          io.add "rim:IsoOptions" do |iso|
            iso.add "rim:Level", "Level2"
          end
        end
        
        io.add "rim:UdfOptions" do |udf|
          udf.add "rim:Version", "Ver150"
        end
        io.add "VolumeName", destination_folder
      end
    end
    
    # Build the production options.
    # @param [Object] - The node to add this data to.
    # @param [Type] - The type of image (Dvdr, BdDl)
    # @param [String] - The path to the watch folder.
    def production_options(node, type, path)
      node.add "rim:ProductionOptions" do |po|
        po.add "rim:Copies", "1"
        po.add "rim:FixateType", "Sao"
        build_label(po)
        po.add "rim:MediaType", type
        po.add "VolumeName", @folder
        po.add "rim:Merge" do |merge|
          merge.add "rim:MergeData" do |mergedata|
            
            mergedata.add "rim:FieldNames" do |fieldnames|
              fieldnames.add "arr:string", "description"
              fieldnames.add "arr:string", "barcode"
              fieldnames.add "arr:string", "barcodeurl"
              fieldnames.add "arr:string", "contenttype"
            end
            
            mergedata.add "rim:FieldValues" do |fieldvalues|
              fieldvalues.add "arr:ArrayOfstring" do |arrstring|
                arrstring.add "arr:string", path.split("\\").last
                arrstring.add "arr:string", serial_info[:serial]
                arrstring.add "arr:string", serial_info[:url]
                arrstring.add "arr:string", "Fake Type"
              end
            end
            
          end
        end  
      end
    end

    # Build the label information for the request.
    # @param [Object] - The node to add this data to.
    def build_label(node)
      node.add "rim:LabelFile" do |label|
        label.add "rim:LabelFilePath", '\\\\rimage\Rimage\Labels\belatorbackup1.btw'
        label.add "rim:LabelType", "Btw"
      end
    end
    
    # Build a hash of serial information.
    # @return [Hash] - Serial information.
    def serial_info
      # find all the content marked as completed and use that as a serial count
      @serial = Content.find_by_destination_folder(@folder).id
      {:url => "http://warehouse/#{@serial}", :serial => @serial}
    end
  
end