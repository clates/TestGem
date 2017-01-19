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
  
  describe "PV-1022: Sign & Submit whole encounter form - Admission" do
    it 'PV-1022 | PV-1372: Sign complete encounter - admission' do
      testNoteBody = "This is a sample note body"
      @notes.openProgressNotes()
      @notes.createDefaultNote()

      @notes.openLinkTab()
      @notes.expandHospitalizations()
      @notes.selectHospitalAdmission("7A GEN MED", "03/25/2004 9:30 AM")

      @notes.openEncounterTab()
      @notes.createDefaultRelatedTo()
      @notes.createDefaultDiagnosis()
      @notes.createDefaultProcedure()

      @notes.openSignTab()
      expect(@notes.getSignClinicEventName()).to eq("7A GEN MED")
      expect(@notes.getSignClinicEventType()).to eq("Admission")
      expect(@notes.getSignClinicEventDateTime()).to eq("03/25/2004 9:30 AM")

      @notes.saveNote()

      puts("    -swap to blank patient to test that the note clears properly")
      @search.updatePatientContext("onehundredeight, patient")
      @notes.openProgressNotes()
      expect(@notes.getNoteBody()).not_to eq(testNoteBody)

      @search.updatePatientContext("seventyeight, patient")

      puts("    -swapping back to working patient and verifying that the note will resume properly")
      @notes.openProgressNotes()
      expect(@notes.getNoteBody()).to eq(testNoteBody)
      expect(@notes.linkTabIsDisabled()).to be_true
      expect(@notes.signSubmitButtonDisabled()).to be_false
      @notes.openSignTab()

      expect(@notes.getSignClinicEventName()).to eq("7A GEN MED")
      expect(@notes.getSignClinicEventType()).to eq("Admission")
      expect(@notes.getSignClinicEventDateTime()).to eq("03/25/2004 9:30 AM")


      @notes.clickSign()
      @notes.setEsig("CPRS1234")
      @notes.clickSignPopupSubmit()

      #wait for the note to be signed
      sleep(5) #TODO: Replace with actual logic. Not Sleeps.

      #Verify that the note is destroyed and a new note can be created
      @notes.openProgressNotes()
      expect(@notes.getNoteTitle()).to eq("")
      expect(@notes.getNoteBody()).to eq("")
    end
  end
end  