require "bundler/setup"
require "selenium-webdriver"
require "rspec"

require 'applet-test-helpers/utilities/general-utility'
require 'applet-test-helpers/utilities/element-utility'
require 'applet-test-helpers/pages/container'
require 'applet-test-helpers/pages/provider-login'
require 'applet-test-helpers/rest/patient-rest-client'
require 'applet-test-helpers/mongo/mongo-utility'
require 'applet-test-helpers/utilities/verification-utility'
require 'search-page'
require 'applet-test-helpers/pages/orders-viewer'
require_relative '../../config'
include RSpec::Expectations


describe "Orders-Viewer-Widget" do

  before(:all) do
    GeneralUtility.setConfig($config)
    @wait = GeneralUtility.wait
    @search = Search.new
    @container = Container.new
    @orders = OrdersViewer.new
    @gu = GeneralUtility.new
    @eu = ElementUtility.new
    @vu = VerificationUtility.new
    login = ProviderLogin.new
    login.loginAsCprs1234()
  end  

  it 'PVA-360: PVA v.3.0.3 Unreleased Radiology, new Med, Refill Med and Imaging orders not displaying in Orders Viewer' do    
    @patient_name = 'ten, patient'    
    @search.updatePatientContextByName(@patient_name)
    @container.waitForLoader
    
    @eu.click('css', '#orders-viewer-btn')    
    @container.waitForLoader
    @wait.until {
      @eu.get_element(:css, '.ov-group-panel:first-child .ov-group-status').displayed?
    }
      expect(@vu.checkText(:css, '.ov-group-panel:first-child .ov-group-status', "InPt 3 / OutPt 2")).to eq(true)

  end
end