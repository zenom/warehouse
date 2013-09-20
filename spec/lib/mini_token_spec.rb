require 'spec_helper'

describe "MiniToken" do
  
  it "should generate a token" do
    MiniToken.output(9).size.should eql 9
  end
  
end