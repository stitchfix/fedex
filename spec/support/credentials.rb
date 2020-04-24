def fedex_credentials
  @fedex_credentials ||= credentials["development"]
end

def fedex_production_credentials
  @fedex_production_credentials ||= credentials["production"]
end

private

def credentials
  @credentials ||=
      begin
        YAML.load_file("#{File.dirname(__FILE__)}/../config/fedex_credentials.yml")
      rescue
        # Use example credentials if just testing with the prerecorded VCR requests
        YAML.load_file("#{File.dirname(__FILE__)}/../config/fedex_credentials.example.yml")
      end
end
