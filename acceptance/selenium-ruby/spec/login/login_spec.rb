require "bundler/setup"
require "selenium-webdriver"
require "rspec"

require 'applet-test-helpers/utilities/general-utility'
require 'applet-test-helpers/utilities/element-utility'
require 'applet-test-helpers/pages/container'
require 'applet-test-helpers/pages/provider-login'
require 'applet-test-helpers/rest/patient-rest-client'
require 'applet-test-helpers/mongo/mongo-utility'
require 'search-page'
require_relative '../../config'
include RSpec::Expectations

describe "Auth Services Login" do

  before(:each) do
    GeneralUtility.setConfig($config)
    @wait = GeneralUtility.wait
    
    @login = ProviderLogin.new
    @gu = GeneralUtility.new

    @login.loginAsCprs1234()            
  end  
  
  it "Redirects and logs in at Washington" do    
    expect(GeneralUtility.driver.current_url).to start_with(@gu.baseUrl)
  end
end