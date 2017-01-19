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


describe "Orders-Viewer-Widget" do

  before(:all) do
    GeneralUtility.setConfig($config)
    @wait = GeneralUtility.wait
    @search = Search.new
    @container = Container.new
    @orders = OrdersViewer.new
    @gu = GeneralUtility.new
    @eu = ElementUtility.new
    login = ProviderLogin.new
    login.loginAsCprs1234()
    
  end
  
  before(:each) do
    GeneralUtility.driver.get(@gu.appUrl)
    @container.confirmPopWindowOkButton
    @search.updatePatientContext("ten, patient")
  end
  

  it 'expect display orders tab in the page'do
		expect(@orders.getOrdersTabText()).to eq("Orders")
	end


	it 'expect open Orders to view Orders Viewer' do
		@orders.openOrdersViewer()
		expect(@orders.getPanelDisplayState()).to eq("open")
		expect(@orders.getPanelDisplayState()).not_to eq("closed")
    @wait.until{@orders.displayOrdersDetailTitle() == "Orders Viewer"}
		expect(@orders.displayOrdersDetailTitle()).to eq("Orders Viewer")
	end


end

