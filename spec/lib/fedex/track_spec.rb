require 'spec_helper'

module Fedex
  describe TrackingInformation do
    let(:fedex) { Shipment.new(fedex_credentials) }

    context "shipments with tracking number", :vcr, :focus do
      let(:options) do
        { :package_id             => "123456789012",
          :package_type           => "TRACKING_NUMBER_OR_DOORTAG",
          :include_detailed_scans => true
        }
      end

      let(:uuid) { fedex.track(options).first.unique_tracking_number }

      it "returns an array of tracking information results" do
        results = fedex.track(options)
        results.should_not be_empty
      end

      it "returns events with tracking information" do
        tracking_info = fedex.track(options.merge(:uuid => uuid)).first

        tracking_info.events.should_not be_empty
      end

      it "fails if using an invalid package type" do
        fail_options = options

        fail_options[:package_type] = "UNKNOWN_PACKAGE"

        lambda { fedex.track(options) }.should raise_error
      end

      it "allows short hand tracking number queries" do
        shorthand_options = { :tracking_number => options[:package_id] }

        tracking_info = fedex.track(shorthand_options).first

        tracking_info.tracking_number.should == options[:package_id]
      end

      it "reports the status of the package" do
        tracking_info = fedex.track(options.merge(:uuid => uuid)).first

        tracking_info.status.should == "Shipment cancelled by sender"
      end

      # The following tests require constructed responses
      unless real_credentials?
        it "does not raise an exception when an event's address is missing" do
          # In the past, if an address block was missing in one of the Fedex tracking events, a
          # "NoMethodError: undefined method `[]' for nil:NilClass" exception would be raised.
          tracking_info = fedex.track(options).first
          tracking_info.should_not be nil
        end

        it "raises an invalid tracking number exception" do
          expect{ fedex.track(options).first }.to raise_error(Fedex::InvalidTrackingNumberError)
        end

        it "raises a no-information-available exception" do
          expect{ fedex.track(options).first }.to raise_error(Fedex::NoTrackingInformationAvailable)
        end

        it "raises a unable-to-process-request exception" do
          expect{ fedex.track(options).first }.to raise_error(Fedex::FedexUnableToProcessRequest)
        end
      end
    end
  end
end
