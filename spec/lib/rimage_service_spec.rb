require 'spec_helper'

describe RImageService do
  
  setup do
    #Handsoap::Service.logger = $stdout
    stub_request(:any, 'rimage')
  end
  
  it "a dvd should return the necessary values we need" do
    #Handsoap::Service.logger = $stdout
    Fabricate(:content, :destination_folder => 'Video_Cayden_Richard_20100805114425', :state => :pending, :content_type => "Video", :media => "Blue Ray")
    VCR.use_cassette('submit_dvd', :record => :new_episodes) do
      result = RImageService.submit_dvd('\Video\Video_Cayden_Richard_20100805114425')
      result[:error_message].should be_nil
      result[:error_code].should eql "0"
      result[:job_id].should eql "Video-Cayden-Richard-20100805114425-2"
      result[:error_code].should eql "0"
      result[:stage].should eql "WAITING_FOR_IMAGING"
      result[:state].should eql "SubmittedForImaging"
      result[:copies_requested].should eql "1"
      result[:percent_completed].should eql "0"
      result[:serial].should eql 1
    end
    
  end
  
  it "a blueray should return the necessary values we need" do
    Fabricate(:content, :destination_folder => 'Sig_ZanderCox001', :state => :pending, :content_type => "Photo", :media => "DVD")
    VCR.use_cassette('submit_blueray', :record => :new_episodes) do
      result = RImageService.submit_blueray('\Photo\Sig_ZanderCox001')
      result[:error_message].should be_nil
      result[:error_code].should eql "0"
      result[:job_id].should eql "Sig-ZanderCox001-1"
      result[:error_code].should eql "0"
      result[:stage].should eql "WAITING_FOR_IMAGING"
      result[:state].should eql "SubmittedForImaging"
      result[:copies_requested].should eql "1"
      result[:serial].should eql 1
    end
  end
  
  it "should be able to return a job status" do
    #Handsoap::Service.logger = $stdout
    VCR.use_cassette('job_status', :record => :new_episodes) do
      result = RImageService.job_status(1287436302) # job id from other vcr's
      result[:job_id].to_i.should eql 1287436302
      result[:error_code].should eql "0"
      result[:error_message].should be_nil
      result[:stage].should eql "WAITING_FOR_IMAGING"
      result[:state].should eql "SubmittedForImaging"
      result[:copies_requested].should eql "1"
    end
  end
  
  it "should be able to detect errors" do
    VCR.use_cassette('error_cancel', :record => :new_episodes) do
      result = RImageService.cancel_job(0)
      result[:error_code].should eql "50011"
      result[:error_message].should eql "CancelJob - job isn't found for 0"
    end
    
  end
  
  it "should be able to cancel a job" do
    VCR.use_cassette('cancel_job', :record => :new_episodes) do
      result = RImageService.cancel_job(1287436302)
      result[:error_message].should be_nil
      result[:error_code].should eql "0"
    end
  end
  
  it "should be able to cancel a job" do
    VCR.use_cassette('clear_finished_jobs', :record => :new_episodes) do
      result = RImageService.clear_finished_jobs
      result[:error_message].should be_nil
      result[:error_code].should eql "0"
    end
  end
  
  
  it "should be able to cancel multiple jobs" do
    #Handsoap::Service.logger = $stdout
    VCR.use_cassette('cancel_all_jobs', :record => :new_episodes) do
      result = RImageService.cancel_all_jobs
    end
  end
  
end