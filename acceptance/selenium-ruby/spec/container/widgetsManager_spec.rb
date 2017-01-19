require "bundler/setup"
require "selenium-webdriver"
require "rspec"

require 'applet-test-helpers/utilities/general-utility'
require 'applet-test-helpers/utilities/element-utility'
require 'applet-test-helpers/pages/container'
require 'applet-test-helpers/pages/provider-login'
require 'applet-test-helpers/mongo/mongo-utility'
require 'search-page'
require 'applet-test-helpers/pages/orders-viewer'
require_relative '../../config'
include RSpec::Expectations

describe "When staff view and patient view" do

  before(:all) do
    GeneralUtility.setConfig($config)
    @wait = GeneralUtility.wait
    @eu = ElementUtility.new
    @gu = GeneralUtility.new
    @login = ProviderLogin.new    
    @mongo = MongoUtility.new  
    @container = Container.new              
    @search = Search.new   
    @ordersViewer = OrdersViewer.new

    @mongo.removeCollection("contextCollection", "patientContext")
    @login.loginAsCprs1234()          
  end

  describe "on Patient View" do
    it 'should open orders widget' do      
      @search.updatePatientContext('ten, patient')
      @wait.until { @eu.element_present?(:css, "#patient-context") }

      @ordersViewer.openOrdersViewer()
      expect(@ordersViewer.getPanelDisplayState()).to eq("open")
      expect(@eu.element_present?(:css, "#order-viewer.ui-panel-open")).to eq(true)
    end
  end

  describe "switch from Patient View to Staff View - should hide orders widget" do
    it 'should hide orders widget' do      
      @container.switchView()
      expect(@ordersViewer.getPanelDisplayState()).to eq("closed")
    end
  end

  describe "back on Patient View" do
    it 'should not display the orders widget' do     
      @container.switchView()
      expect(@ordersViewer.getPanelDisplayState()).to eq("closed")
    end
  end
end
