require "bundler/setup"
require "selenium-webdriver"
require "rspec"

require 'applet-test-helpers/utilities/general-utility'
require 'applet-test-helpers/utilities/element-utility'
require 'applet-test-helpers/pages/container'
require 'applet-test-helpers/pages/provider-login'
require 'search-page'
require_relative '../../config'
include RSpec::Expectations

describe "Story:PVA-1594:Pop-up with sensitive patient data displaying after session timeout" do
  before(:all) do
    GeneralUtility.setConfig($config)
    @wait = GeneralUtility.wait
    @eu = ElementUtility.new
    @gu = GeneralUtility.new
    @login = ProviderLogin.new
    @search = Search.new
    @container = Container.new
  end
  after(:each) do
    #Logout after each test.
    @login.logout
    GeneralUtility.driver.get(@gu.appUrl)
  end

  it "verifies that the initial-confirmation popup has closed in order to show the logout warning." do
    @login.loginAsCprs1234KeepPopupOpen()

    #Verify that the popup is open.
    expect(@eu.element_visible?(:id, "initial-confirmation-popup")).to eq(true)

    #Wait for 13 minutes. The popup should be closed at this point.
    waitForPopupCleaner

    ###verify here that popup window close and user stays on the same page
    expect(@eu.element_visible?(:id, "initial-confirmation-popup")).to eq(false)
  end

  it "verifies that the patient search popup has closed in order to show the logout warning." do
    @login.loginAsCprs1234

    #Perform a search and leave the popup window open
    @search.searchByPatient("ten, imagepatient")
    @search.selectPatientFromSearchResultsList("ten, imagepatient")

    #Verify that the popup is open.
    @wait.until{
      @eu.element_visible?(:id, "confirmation-popup")
    }
    expect(@eu.element_visible?(:id, "confirmation-popup")).to eq(true)

    #Wait for 13 minutes. The popup should be closed at this point.
    waitForPopupCleaner

    ###verify here that popup window close and user stays on the same page
    expect(@eu.element_visible?(:id, "confirmation-popup")).to eq(false)
  end

  it "verifies that the task list patient information popup has closed in order to show the logout warning." do

    #Login and navigate to the #task-list
    @login.loginAsCprs1234
    @eu.click(:id, "switch-view-mode-button")
    #Close the menu
    @eu.click(:id, "menu")
    @eu.click(:css, "#content-table > tbody > tr:first-of-type > td:first-of-type")

    #Verify that the popup is open.
    @wait.until{
      @eu.element_visible?(:id, "task-list-confirmation-popup")
    }
    expect(@eu.element_visible?(:id, "task-list-confirmation-popup")).to eq(true)

    #Wait for 13 minutes. The popup should be closed at this point.
    waitForPopupCleaner

    ###verify here that popup window close and user stays on the same page
    expect(@eu.element_visible?(:id, "task-list-confirmation-popup")).to eq(false)
  end

  def waitForPopupCleaner
    !11.downto(0) do |i|
      puts "Waiting #{i} more minutes..."
      sleep (60)
    end
  end
end
