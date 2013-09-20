class TranscodeController < ApplicationController
  def monitor
    @result = Transcode.create_from_params!(params)
    render :text => @result == false ? "ERROR": "OK"
  end

end
