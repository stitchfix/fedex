module Fedex
  class TrackingInformation
    class Event
      attr_reader :description, :type, :occured_at, :city, :state, :postal_code,
                  :country, :residential, :exception_code, :exception_description

      def initialize(details = {})
        @description           = details[:event_description]
        @type                  = details[:event_type]
        @occured_at            = Time.parse(details[:timestamp])
        # Address may not exist, so we use #dig as it will extract a deeply-nested key or return nil if any intermediate
        # step is nil. There are cases when :address is not nil but city or state/province code is nil (like a "shipping
        # details sent" event) so there is precedent for some of these fields to be nil.  See the WSDL provided by
        # Fedex for more information: https://www.fedex.com/us/developer/downloads/wsdl/2019/standard/TrackService.zip
        # (via: https://www.fedex.com/en-us/developer/web-services/process.html#documentation)
        @city                  = details.dig(:address, :city)
        @state                 = details.dig(:address, :state_or_province_code)
        @postal_code           = details.dig(:address, :postal_code)
        @country               = details.dig(:address, :country_code)
        @residential           = details.dig(:address, :residential) == "true"
        @exception_code        = details[:status_exception_code]
        @exception_description = details[:status_exception_description]
      end
    end
  end
end
