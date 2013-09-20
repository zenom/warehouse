require 'handsoap'

class RImageSystemService < Handsoap::Service
  endpoint :uri => "http://rimage:55555/RmSystemService.svc", :version => 1
  on_create_document do |doc|
    envelope = doc.find('Envelope')
    envelope.set_attr("xmlns:rms", "http://www.rimage.com/RmSystemService")
    envelope.set_attr("xmlns:rim", "http://schemas.datacontract.org/2004/07/Rimage.Web.Service")
  end
  
  def on_response_document(doc)
    doc.add_namespace "a", "http://schemas.datacontract.org/2004/07/Rimage.Web.Service"
  end
  
  def get_systems
    soap_action = "http://www.rimage.com/RmSystemService/IRmSystemService/GetSystems"
    response = invoke("rms:GetSystems", :soap_action => soap_action) do |message|
      message.add "rms:request" do |req|
        req.add "rim:CallerId", "123123123"
      end
    end
    parse_model_data((response/"//a:HostSystem").first)
  end
  
  
  
  def parse_model_data(node)
    {
      :printer_serial => (node/"//a:Printer/a:SerialNumber").to_s,
      :serial => (node/"//a:Autoloader/a:SerialNumber").to_s,
      :model => (node/"//a:Autoloader/a:Model").to_s,
    }
  end
  
end