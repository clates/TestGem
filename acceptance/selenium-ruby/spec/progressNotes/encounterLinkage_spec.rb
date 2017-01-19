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



describe "PV-162: Link progress note to clinical encounter" do

  before(:all) do
    GeneralUtility.setConfig($config)
    @driver = GeneralUtility.driver
    @wait = GeneralUtility.wait
    @search = Search.new
    @container = Container.new
    @orders = OrdersViewer.new
    @gu = GeneralUtility.new
    @eu = ElementUtility.new
    @mongo = MongoUtility.new
    @notes = ProgressNotes.new
    login = ProviderLogin.new
    @mongo.removeCollection("note-writer", "clinical-events")    

    login.loginAsCprs1234()


    @patient_name = 'ten, patient'
    puts 'Searching for patient', @patient_name

    @search.clickPopupWindowOkButton()
    @search.updatePatientContext("twenty, outpatient")
    # @search.updatePatientContext("ten, patient")
     @notes.openProgressNotes()

  end
  
  
  describe "PV-162: Link progress note to clinical encounter" do

    it 'should display a message when no appointments or hospitalizations exist' do
      # @search.updatePatientContext("twenty, outpatient")

      # @notes.openProgressNotes()
      # @notes.createDefaultNote()
      # @notes.openLinkTab()

      @notes.setNoteTitle("C&P D")
      puts @notes.consultPopupIsVisible()
      @notes.selectNoteTitle("C&P DIABETES MELLITUS")
      puts @notes.consultPopupIsVisible()
      @wait.until{ expect(@notes.consultPopupIsVisible()).to be_falsey }
      @notes.setNoteBody("This is a test")

      # expect(@notes.newVisitIsCollapsed()).to be false
      # @notes.openSwitchUserFolderIcon()
      @notes.openLinkTab()
      @container.waitForLoader
      @notes.expandHospitalizations()
      expect(@eu.get_element(:css, "#hospital-appointment-list li:nth-of-type(1)").text()).to eq("No Hospital Events Found")

      @notes.expandAppointments()
      expect(@eu.get_element(:css, "#clinic-appointment-list li:nth-of-type(1)").text()).to eq("No Clinic Events Found")

    end
    
    it 'should allow linking to an existing hospital admission: PV-482, PV-659 ' do
      @search.updatePatientContext("ten, patient")
      @notes.openProgressNotes()
      @notes.setNoteTitle("C&P D")
      puts @notes.consultPopupIsVisible()
      @notes.selectNoteTitle("C&P DIABETES MELLITUS")
      puts @notes.consultPopupIsVisible()
      @wait.until{ expect(@notes.consultPopupIsVisible()).to be_falsey }
      @notes.setNoteBody("This is a test")
      @notes.openLinkTab()
      @container.waitForLoader
      @notes.expandHospitalizations()

      admissions = @notes.getHospitalAdmissionDatesList()
      expect(admissions.length).to be > 0

      #Verify the consults are sorted in reverse-chronological order
      previousItem = admissions[0].text()[0..10]
      previousDate = parseDate(previousItem)
      for i in (1...admissions.length)
        nextItem = admissions[i].text()[0..10]
        nextDate = parseDate(nextItem)
        expect(previousDate).to be >= nextDate
        previousDate = nextDate
      end

      expect(@eu.get_element(:css, "#hospital-appointment-list li:nth-of-type(1) a h3").text()).to eq("7A GEN MED")

      @notes.selectHospitalAdmission("7A GEN MED", "03/25/2004 8:31 AM")
      expect(@notes.encounterTabIsDisabled()).to be false
    end

   it 'should allow linking to a new visit: PV-656, PV-660, PV-657' do
     @notes.openSwitchUserFolderIcon()
     @container.waitForLoader
     @notes.openSwitchUserFolderIcon()
     @notes.openProgressNotes()

     @notes.setNoteTitle("C&P D")
     puts @notes.consultPopupIsVisible()
     @notes.selectNoteTitle("C&P DIABETES MELLITUS")
     puts @notes.consultPopupIsVisible()

     @wait.until{ expect(@notes.consultPopupIsVisible()).to be_falsey }
     @notes.setNoteBody("This is a test")


     @notes.openLinkTab()
     @container.waitForLoader
     @notes.collapsedHospitalization()
     @notes.expandNewVisit()

     eventTime = @notes.getTimeOfVisit()

     @eu.click(:css, '#select-time')
     @wait.until{ @eu.element_present?(:css, '#time-picker-popup #set-btn') }
     @eu.click(:css, '#time-picker-popup a')

     #Verify that canceling the time popup doesn't populate the field
     expect(@notes.getTimeOfVisit()).to eq(eventTime)

     eventDate = @notes.getDateOfVisit()
     @eu.click(:css, '#select-date')
     @wait.until{ @eu.element_present?(:css, '#date-picker-popup #set-btn') }
     @eu.click(:css, '#date-picker-popup a')

     #verify that canceling the date popup doesn't populate the field
     expect(@notes.getDateOfVisit()).to eq(eventDate)

     @notes.setCurrentTime()
     @notes.setCurrentDate()

     expect(@notes.getDateOfVisit()).to eq(Time.new().strftime("%m/%d/%Y"))

     @notes.setLocation("car")
     expect(@eu.get_element(:css, "#select-location li:nth-of-type(1) a").text()).to eq("CARDIOLOGY")
     expect(@notes.encounterTabIsDisabled()).to be true

     @notes.selectLocationAtRow(1)
     expect(@notes.getSelectedLocation()).to eq("CARDIOLOGY")
     expect(@notes.encounterTabIsDisabled()).to be false #verify that only selecting a location enables the tab

     expect(@notes.historicalVisitIsChecked()).to be false
     @notes.setHistoricalVisit()
     expect(@notes.historicalVisitIsChecked()).to be true

     @notes.openEncounterTab()
     expect(@notes.linkTabIsDisabled()).to be true

    end


    it 'should enable encounter tab only after a link and disable the link tab upon selecting encounter tab: PV-836' do
      @notes.openSwitchUserFolderIcon()
      @container.waitForLoader()
      @notes.openSwitchUserFolderIcon()
      @notes.openProgressNotes()
      # openNoteTab()
      @notes.setNoteTitle("C&P DIAB")
       puts @notes.consultPopupIsVisible()
      @notes.selectNoteTitle("C&P DIABETES MELLITUS")
       puts @notes.consultPopupIsVisible()
      @wait.until{ expect(@notes.consultPopupIsVisible()).to be_falsey }
      @notes.setNoteBody("This is a sample note body")
      # @notes.createDefaultNote()
      @notes.openLinkTab()

      # expect(@notes.encounterTabIsDisabled()).to be true
      @notes.createDefaultNewVisit()

      expect(@notes.encounterTabIsDisabled()).to be false
      @notes.openEncounterTab()

      expect(@notes.linkTabIsDisabled()).to be true
    end

    it 'should have the admission linked for an inpatient: PV-818' do
      @search.updatePatientContext("zzzretfourseventytwo, patient")

      @notes.openProgressNotes()
       # @notes.createDefaultNote()
      # openNoteTab()
      @notes.setNoteTitle("C&P DIAB")
       puts @notes.consultPopupIsVisible()
      @notes.selectNoteTitle("C&P DIABETES MELLITUS")
       puts @notes.consultPopupIsVisible()
      @wait.until{ expect(@notes.consultPopupIsVisible()).to be_falsey }
      @notes.setNoteBody("This is a sample note body")
      @notes.openLinkTab()

      expect(@eu.element_present?(:css, "#link-appointment-section div:nth-of-type(2) li:nth-of-type(1).ui-btn-active")).to be true
      expect(@eu.element_present?(:css, "#link-appointment-section div:nth-of-type(2) h3.ui-collapsible-heading-collapsed")).to be false
      expect(@notes.encounterTabIsDisabled()).to be false
      expect(@notes.signTabIsDisabled()).to be false

      @notes.openEncounterTab()
      # @notes.createDefaultDiagnosis()

        @notes.expandDiagnosis()
       @notes.searchForDiagnosis("249")

      @eu.click(:css, "#diagnoses-popup a:first-of-type")

      #TODO: fix this bug
      # expect(@notes.signTabIsDisabled()).to be true
    end

   end
  
  def parseDate(dateString)
    return Time.new(dateString[6..9], dateString[0..1], dateString[3..4] )
  end
  
end  
