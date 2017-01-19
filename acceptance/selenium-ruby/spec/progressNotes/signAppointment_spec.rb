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

describe "Progress Notes" do

  before(:all) do
    GeneralUtility.setConfig($config)
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
  end

  before(:each) do
    GeneralUtility.driver.get($acp_url + "/" + $acp_app)
    puts("    -setting test patient (seventyeight, patient)...")
    @search.updatePatientContext("seventyeight, patient")
  end


  describe "PV-1022: Sign & Submit whole encounter form - appointment" do
    it 'PV-1324 | PV-1373: Sign and submit whole encounter form - appointment' do
      testNoteBody = "This is a sample note body"

      puts("    -opening progress notes...")
      @notes.openProgressNotes()

      puts("    -creating default note...")
      @notes.createDefaultNote()

      @notes.openLinkTab()
      puts("    -expanding appointments and selecting Cardiology appointment...")
      @notes.expandAppointments()
      @notes.selectClinicAppointment("CARDIOLOGY", "05/12/2014 2:57 PM")

      puts("    -opening encounter tab, link and sign tabs should be disabled")
      @notes.openEncounterTab()
      expect(@notes.linkTabIsDisabled()).to be_true()
      expect(@notes.signTabIsDisabled()).to be_true()

      puts("    -setting default \"related to\" information")
      @notes.createDefaultRelatedTo()

      puts("    -setting a default diagnosis and procedure, sign tab should then be enabled")
      @notes.createDefaultDiagnosis()
      @notes.createDefaultProcedure()

      expect(@notes.signTabIsDisabled()).to be_false()

      puts("    -opening sign tab and saving note...")
      @notes.openSignTab()

       #TODO: Need to update when appointments are available
#      expect(@notes.getSignClinicEventName()).to eq("GEN MED")
#      expect(@notes.getSignClinicEventType()).to eq("Appointment")
#      expect(@notes.getSignClinicEventDateTime()).to eq("07/18/1995 12:00 AM")

      @notes.saveNote()

      puts("    -swapping to new patient (onehundredeight, patient)...")
      @search.updatePatientContext("onehundredeight, patient")

      puts("    -checking that the previous note information was cleared")
      @notes.openProgressNotes()
      expect(@notes.getNoteBody()).not_to eq(testNoteBody)

      puts("    -swapping back to previous patient (seventyeight, patient)")
      @search.updatePatientContext("seventyeight, patient")

      puts("    -checking that the previous note information was loaded, link tab should be disabled, sign tab should be enabled")
      @notes.openProgressNotes()
      expect(@notes.getNoteBody()).to eq(testNoteBody)
      expect(@notes.linkTabIsDisabled()).to be_true
      expect(@notes.signSubmitButtonDisabled()).to be_false

      puts("    -opening sign tab and signing note...")
      @notes.openSignTab()

      #TODO: Need to update when appointments are available
#      expect(@notes.getSignClinicEventName()).to eq("GEN MED")
#      expect(@notes.getSignClinicEventType()).to eq("Appointment")
#      expect(@notes.getSignClinicEventDateTime()).to eq("07/18/1995 12:00 AM")

      #TODO: Verify that invalid pw and esig is handled

      @notes.clickSign()
      @notes.setEsig("CPRS1234")
      @notes.clickSignPopupSubmit()


      #wait for the note to be signed
      sleep(5) #TODO: Replace with actual logic, not sleeps.
      #Verify that the note is destroyed and a new note can be created
      @notes.openProgressNotes()
      expect(@notes.getNoteTitle()).to eq("")
      expect(@notes.getNoteBody()).to eq("")
    end
  end
end