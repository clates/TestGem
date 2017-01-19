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
require 'applet-test-helpers/pages/orders-viewer'
require_relative '../../config'
include RSpec::Expectations

describe "Wrapper Tests" do

  before(:all) do
    GeneralUtility.setConfig($config)
    @driver = GeneralUtility.driver
    @wait = GeneralUtility.wait
    @search = Search.new
    @container = Container.new
    @orders = OrdersViewer.new
    @gu = GeneralUtility.new
    @eu = ElementUtility.new
    login = ProviderLogin.new
    login.loginAsCprs1234()
  end
  

  describe "About Button: PV-2025" do
    it 'should display an About pop-up - PV-2026' do      
      
    @wait.until{expect(@eu.get_element(:css, "#portal-about-btn"))}
    @eu.click(:css, "#portal-about-btn")
    @wait.until{ @eu.get_element(:css, "#portal-about-popup-popup.ui-popup-active").displayed? }
    @gu.customWait {
        @eu.get_element(:css, "#portal-about-popup > div.ui-header.ui-bar-b > h3.ui-title").text.eql? "About"
     }
    expect(@eu.get_element(:css, "#portal-about-popup > div.ui-header.ui-bar-b > h3.ui-title").text).to eq "About"
    expect(@eu.get_element(:css, "#portal-about-popup ul li:nth-child(1) .fieldname").text).to eq "Title"
    expect(@eu.get_element(:css, "#portal-about-popup ul li:nth-child(1) .fieldvalue").text).to eq "Container"
    expect(@eu.get_element(:css, "#portal-about-popup ul li:nth-child(2) .fieldname").text).to eq "Version"
    expect(@eu.get_element(:css, "#portal-about-popup ul li:nth-child(2) .fieldvalue").text).to eq "1.1.6"
    expect(@eu.get_element(:css, "p.ui-li-desc").text).to eq "Compiled App\nAdditional Information"

    @eu.click(:css, "#portal-about-popup a:first-of-type")
    end   
    
  end

end



