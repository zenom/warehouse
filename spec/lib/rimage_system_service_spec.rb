require 'spec_helper'

describe RImageSystemService do
  
  setup do
    stub_request(:any, 'rimage')
  end
  
  it "should do this" do
    VCR.use_cassette('get_systems', :record => :new_episodes) do
      result = RImageSystemService.get_systems
      result[:printer_serial].to_s.should eql "Printer - USB001, HID-0: EVEREST CDPR24 V0.13 SN-023A1200"
      result[:model].should eql "Rimage 3400"
      result[:serial].strip.should eql "Autoloader 1: RIMAGE 3400 5.005A SN-5001396"
    end
  end
end