require "bundler/setup"
require "selenium-webdriver"
require "rspec"

require 'applet-test-helpers/utilities/general-utility'
require 'applet-test-helpers/utilities/element-utility'
require 'applet-test-helpers/pages/container'
require 'applet-test-helpers/pages/provider-login'
require 'applet-test-helpers/mongo/mongo-utility'
require 'search-page'
require_relative '../../config'
require_relative "../../pages/patientInfo"
include RSpec::Expectations

describe "Container Tests" do
  before(:all) do
    GeneralUtility.setConfig($config)
    @wait = GeneralUtility.wait
    @eu = ElementUtility.new
    @gu = GeneralUtility.new
    @login = ProviderLogin.new
    @search = Search.new    
    @mongo = MongoUtility.new  
    @container = Container.new
    @mongo.removeCollection("contextCollection", "patientContext")    

    @login.loginAsCprs1234KeepPopupOpen()
  end

  describe "No patient in context: PV-1532" do
    it 'should show No Patient in Context message if no patient in context' do    
      @gu.customWait {
        expect(@eu.get_element(:css, "#patient-context .ui-btn-text").text).to eq("No Patient Selected")
      }

    end
  end

  describe "Wrapper sub-header: PV-1443" do
    it 'should list applets within the context menu - PV-1536' do 
      @gu.customWait {        
        expect(@eu.get_element(:css, "#portal-about-btn").text).to eq("About")
      }
    end
  end

  describe "Container Footer: PV-1444" do
    it 'should contain the app name and version: PV-1534' do      
      @wait.until{ @eu.get_element(:css, "#app-name > h1:not(:empty)") }
      expect(@eu.get_element(:css, "#app-name > h1").text).to eq("Container - v1.1.6")
    end

    it 'should display the logged in user: PV-1535' do      
      @wait.until{
        @eu.get_element(:css, "#portal-infobar-footer .user-context > span").text == "Logged in as: PROGRAMMER, ONE - WASHINGTON"

      }
      expect(@eu.get_element(:css, "#portal-infobar-footer .user-context > span").text).to eq("Logged in as: PROGRAMMER, ONE - WASHINGTON")
    end
  end

  describe "Container Header: PV-1442" do
    it 'should display the patient info button for admitted patients: PV-1602' do      
      @search.updatePatientContextByName('ten, patient')
      
      @wait.until{@eu.element_present?(:css, "#patient-context")}

      expect(@eu.element_present?(:css, "#patient-context .icon-9")).to be true
      expect(@eu.get_element(:css, "#patient-status").text).to eq("H")
    end

    it 'should contain the patient name, DOB and SSN and outpatient icon: PV-1601' do    
    @container.waitForLoader
    @search.clickPopupWindowOkButton()
    @search.updatePatientContextByName('ten, outpatient')

      today = Time.now # month is 1 to 12 in Ruby
      age = today.year - 1945
      if(today.month < 3 || (today.month === 3 && today.day < 9))
        age -= 1
      end

      @wait.until{@eu.element_present?(:css, "#patient-status")}
      expect(@eu.element_present?(:css, "#patient-context .icon-9")).to be true
      expect(@eu.get_element(:css, "#patient-status").text).to eq("")
      expect(@eu.get_element(:css, "#patient-context").text).to eq("TEN, OUTPATIENT\n03/09/1945 (#{age.to_s}) M\n666-00-0610")
    end

    it 'should display limited content in pop-up for outpatients: PV-1602' do      
      @search.clickPopupWindowOkButton()
      @search.updatePatientContextByName('ten, outpatient')
      @wait.until{ @eu.element_present?(:css, '#patient-context .icon-9') }
      @eu.get_element(:css, '#patient-context a').click

      info = PatientInfo.new
      expect(info.getPopupTitle()).to eq('Patient Info')

       #Verify data values
      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(1) .fieldvalue").text).to eq('W')
      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(2) .fieldvalue").text).to eq('No Data Found')
      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(3) .fieldvalue").text).to eq('0')
      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(4) .fieldvalue").text).to eq('No Data Found')
      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(5) .fieldvalue").text).to eq('5000000118')

      #Verify labels
      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(1) .fieldname").text).to eq('CWAD')
      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(2) .fieldname").text).to eq('Service Connected')
      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(3) .fieldname").text).to eq('% Service Connected')
      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(4) .fieldname").text).to eq('Sensitive')
      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(5) .fieldname").text).to eq('Internal Control Number')
    end

    it 'should display full patient details for inpatients in the popup: PV-1602' do      
      @search.clickPopupWindowOkButton()
      @search.updatePatientContextByName('ten, inpatient')

      @wait.until{ @eu.element_present?(:css, '#patient-context .icon-9') }
      @eu.click(:css, '#patient-context a')

      @wait.until{ @eu.element_present?(:css, '#subject-info-window-popup.ui-popup-active') }
      info = PatientInfo.new
      expect(info.getPopupTitle()).to eq('Patient Info')

      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(1) .fieldname").text).to eq('Admitted')
      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(1) .fieldvalue").text).to eq('01/05/2009 08:15:10')

      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(2) .fieldname").text).to eq('Location Identifier')
      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(2) .fieldvalue").text).to eq('158')

      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(3) .fieldname").text).to eq('Location Name')
      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(3) .fieldvalue").text).to eq('7A GEN MED')

      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(4) .fieldname").text).to eq('Room / Bed')
      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(4) .fieldvalue").text).to eq('726')

      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(5) .fieldname").text).to eq('CWAD')
      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(5) .fieldvalue").text).to eq('No Data Found')

      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(6) .fieldname").text).to eq('Service Connected')
      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(6) .fieldvalue").text).to eq('No Data Found')

      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(7) .fieldname").text).to eq('% Service Connected')
      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(7) .fieldvalue").text).to eq('0')

      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(8) .fieldname").text).to eq('Sensitive')
      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(8) .fieldvalue").text).to eq('No Data Found')

      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(9) .fieldname").text).to eq('Internal Control Number')
      expect(@eu.get_element(:css, "#subject-info-window li:nth-child(9) .fieldvalue").text).to eq('5000000219')
    end

    it 'should allow the user to logout: PV-1533' do      
      @search.clickPopupWindowOkButton()

      @eu.click(:css, "#portal-logout-btn")

      puts "    -redirects to Launchpad with AuthorizationServices 4.0.3"
    end
  end
end