xml.instruct!
xml.tag!("xrds:XRDS", "xmlns:xrds" => "xri://$xrds",
                       "xmlns" => "xri://$xrd*($v*2.0)" ) do
  xml.XRD do
    xml.Service :priority => "0" do
      xml.Type(OpenID::OPENID_2_0_TYPE)
      xml.Type(OpenID::OPENID_1_0_TYPE)
      xml.Type(OpenID::SREG_URI)

      xml.URI(openid_server_url)
    end
  end
end
