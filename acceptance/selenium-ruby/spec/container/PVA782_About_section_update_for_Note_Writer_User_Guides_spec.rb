require "bundler/setup"
require "selenium-webdriver"
require "rspec"

require 'applet-test-helpers/utilities/general-utility'
require 'applet-test-helpers/utilities/element-utility'
require 'applet-test-helpers/pages/container'
require 'applet-test-helpers/pages/provider-login'
require 'applet-test-helpers/mongo/mongo-utility'
require_relative '../../config'
include RSpec::Expectations


describe "Story:PVA-782:'About'section update for Note Writer User Guide" do

  before(:all) do
    GeneralUtility.setConfig($config)
    @wait = GeneralUtility.wait
    @eu = ElementUtility.new
    @gu = GeneralUtility.new
    @login = ProviderLogin.new    
    @mongo = MongoUtility.new  
    @container = Container.new              

   @mongo.removeCollection("contextCollection", "patientContext")    

    @login.loginAsCprs1234KeepPopupOpen()
  end

  it 'Should allow to click on About button ' do
    @wait.until{expect(@eu.get_element(:css, "#portal-about-btn"))}
    @eu.click(:css, "#portal-about-btn")
    @wait.until{ @eu.get_element(:css, "#portal-about-popup-popup.ui-popup-active").displayed? }
    expect(@eu.get_element(:css, "#portal-about-popup > div.ui-header.ui-bar-b > h3.ui-title").text). to eq("About")
    @eu.click(:css, ".ui-listview p a")
    @eu.click(:css, "#user-guide-panel >div >ul> li:nth-of-type(6) a")
  end

it 'Verify that Save and Delete text is available in Note Writer User Guides' do    
  expect(@eu.get_element(:css, ".ui-content>div> h4:nth-of-type(6)").text).to include('Save and Delete Buttons')  
  expect(@eu.get_element(:css, ".ui-content>div>ul:nth-of-type(6) li:nth-of-type(1)").text).to include ('Save button allows an in progress note to be saved')  
  expect(@eu.get_element(:css, ".ui-content>div>ul:nth-of-type(6) li:nth-of-type(2)").text).to include('Delete button allows a in progress note to be deleted (once signed the note cannot be deleted)')

end

end



