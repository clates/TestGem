require "bundler/setup"
require "selenium-webdriver"
require "rspec"

require 'applet-test-helpers/utilities/general-utility'
require 'applet-test-helpers/utilities/element-utility'
require 'applet-test-helpers/pages/container'
require 'applet-test-helpers/pages/provider-login'
require 'applet-test-helpers/mongo/mongo-utility'
require 'search-page'
require 'coversheet-page'
require "./pages/responsiveDesign"
require_relative '../../config'
include RSpec::Expectations


describe "Application is viewable on ipad and iphone form factors - CNTR-7" do  

  before(:all) do
    GeneralUtility.setConfig($config)
    @wait = GeneralUtility.wait
    @driver = GeneralUtility.driver        
    @eu = ElementUtility.new
    @gu = GeneralUtility.new
    @login = ProviderLogin.new    
    @mongo = MongoUtility.new  
    @container = Container.new              
    @search = Search.new   
    @responsive = ResponsiveDesign.new
    @coversheet = Coversheet.new

    @mongo.removeCollection("contextCollection", "patientContext")

    @login.loginAsCprs1234()        

    @search.setPatientContext("ten, patient")

    loadcoversheetApplet()    
  end

  def setPatientContext(patient)
    #skip the whole block if the patient is already loaded
    if(@eu.element_present?(:id, "patient-context"))
      if(not @eu.get_element(:css, "#patient-context").text().downcase.start_with? patient.downcase)
        @wait.until{ @eu.get_element(:css, "#patient-search a") }
        @search.updatePatientContextByName(patient)

      end
    end
  end

  def loadcoversheetApplet()
  #skip the whole block if the cover sheet is already loaded
    if (@eu.element_present?(:css, "#portal-panel.ui-panel-closed"))
      @wait.until{ @eu.get_element(:id, "menu").displayed? }
      @eu.click(:id, "menu")
    end
    @wait.until{  @eu.get_element(:link_text, "Cover Sheet").displayed? }
    @eu.click(:link_text, "Cover Sheet")

end

  ###############################
  # Responsive Design
  ###############################

  it 'should display two columns on tablet (landscape) and desktop -CNTR-7' do    
    @driver.manage().window().maximize()
    expect(@responsive.desktopView).to be true
    expect(@responsive.fullScreenButtonDisplayed).to be true

    expect(@responsive.sectionListDisplay).to be true
    expect(@responsive.sectionDetailDisplay).to be true
    @gu.takeScreenShot('two-column-layout-desktop')
  end


  it 'should display one column on phone and portrait for tablet -CNTR-7' do    
    @gu.resizeWindow(768, 1080)
    expect(@responsive.phoneView).to be true
    expect(@responsive.backButtonDisplayed).to be false
    @gu.takeScreenShot('one-column-layout-for-phone')
  end


  it 'should display details in a single column after selecting any link -CNTR-7' do    
    @coversheet.expandAllergies()
    expect(@responsive.sectionDetailDisplay).to be true
    expect(@responsive.sectionListDisplay).to be false
    @gu.takeScreenShot('one-column-details-layout')
  end

  it 'should display list items in a single column after selecting back button -CNTR-7' do   
  expect(@responsive.backButtonDisplayed()).to be true
    @responsive.clickBackButton()
    expect(@responsive.sectionListDisplay).to be true
    expect(@responsive.sectionDetailDisplay).to be false

    @coversheet.expandOutpatientMedications()

    expect(@responsive.sectionDetailDisplay).to be true
    expect(@responsive.sectionListDisplay).to be false
    @gu.takeScreenShot('one-column-list-layout')
  end
end