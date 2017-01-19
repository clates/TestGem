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
  end
  
  before(:each) do
    @driver.get($acp_url + "/" + $acp_app)
    puts("    -setting test patient (seventyeight, patient)...")
    @search.updatePatientContext("seventyeight, patient")
  end

  describe "PV-1022: Sign & Submit whole encounter form - New Visit" do

    it 'PV-1325, PV-1270, PV-973, PV-864 | PV-1374, PV-1371, PV-991: Save and sign whole encounter - new visit' do
      puts("    -creating default note body...")
      testNoteBody = "This is a sample note body"
      @notes.openProgressNotes()
      @notes.createDefaultNote()
      
      puts("    -opening link tab and creating a default visit...")
      @notes.openLinkTab()
      @notes.createDefaultNewVisit()

      puts("    -opening encounter tab and entering basic visit details...")
      @notes.openEncounterTab()
      @notes.createDefaultVisitType()
      
      #adding basic modifiers to the visit
      puts("    -adding basic modifiers...")
      @driver.find_element(:css, "#pn-visit-type-section fieldset:last-of-type .relative-wrapper:nth-of-type(2) button").click() #open modifiers panel
      @wait.until{ @eu.element_present?(:css, "#visit-section-modifiers .ui-checkbox") } #wait for panel to open
      @driver.find_element(:css, "#visit-section-modifiers fieldset div:first-of-type label").click() #click on first modifier
      @notes.closeVisitTypeModifierPopup()
      @wait.until{ @eu.element_present?(:css, "#pn-visit-type-section fieldset:last-of-type > .relative-wrapper:nth-of-type(2) .ui-li-desc") }
      
      puts("    -saving note...")
      @notes.saveNote()

      puts("    -switching to new patient and verifying note content is cleared...")
      @search.updatePatientContext("onehundredeight, patient")
      @notes.openProgressNotes()
      expect(@notes.getNoteBody()).not_to eq(testNoteBody)
      
      puts("    -switching to old patient and verifying original note content is persisted...")
      @search.setPatientContext("seventyeight, patient")
      @notes.openProgressNotes()
      expect(@notes.getNoteBody()).to eq(testNoteBody)
      
      puts("    -entering in remaining information...")
      @notes.openEncounterTab()
      @notes.createDefaultRelatedTo()
      @notes.createDefaultDiagnosis()
      @notes.createDefaultProcedure()

      puts("    -verifying the display of all note content in the sign tab...")
      @notes.openSignTab()

      expect(@notes.getSignNoteTitle()).to eq("C&P DIABETES MELLITUS")
      expect(@notes.getSignNoteBody()).to eq(testNoteBody)
        
      expect(@driver.find_element(:css, "#sign-section ul:nth-of-type(1) li:nth-of-type(1)").text).to eq("Clinic Event")
      expect(@notes.getSignClinicEventName()).to eq("CARDIOLOGY")
      expect(@notes.getSignClinicEventType()).to eq("Appointment")
      
      expect(@driver.find_element(:css, "#sign-section ul:nth-of-type(2) li:nth-of-type(1)").text).to eq("Visit Type")
      expect(@notes.getSignVisitType()).to eq("***CONSULTATION***")
      expect(@notes.getSignVisitTypeSection()).to eq("INTERMEDIATE (30min)")
      expect(@notes.getSignVisitTypeModifier()).to eq("'OPT OUT' PHYS/PRACT EMERG OR URGENT SERVICE")
      
      expect(@driver.find_element(:css, "#sign-section ul:nth-of-type(3) li:nth-of-type(1)").text).to eq("Providers")
      expect(@notes.getSignProviderAtRow(2)).to eq("PROGRAMMER, ONE")
      
      expect(@driver.find_element(:css, "#sign-section ul:nth-of-type(4) li:nth-of-type(1)").text).to eq("Related To")
      expect(@notes.getSignRelatedToNameAtRow(2)).to eq("Service Connected")
      expect(@notes.getSignRelatedToStatusAtRow(2)).to eq("No")
      expect(@notes.getSignRelatedToNameAtRow(3)).to eq("Agent Orange")
      expect(@notes.getSignRelatedToStatusAtRow(3)).to eq("N/A")
      expect(@notes.getSignRelatedToNameAtRow(4)).to eq("Radiation")
      expect(@notes.getSignRelatedToStatusAtRow(4)).to eq("N/A")
      expect(@notes.getSignRelatedToNameAtRow(5)).to eq("Southwest Asia Conditions")
      expect(@notes.getSignRelatedToStatusAtRow(5)).to eq("N/A")
      expect(@notes.getSignRelatedToNameAtRow(6)).to eq("MST")
      expect(@notes.getSignRelatedToStatusAtRow(6)).to eq("N/A")
      expect(@notes.getSignRelatedToNameAtRow(7)).to eq("Head and/or Neck Cancer")
      expect(@notes.getSignRelatedToStatusAtRow(7)).to eq("N/A")
      expect(@notes.getSignRelatedToNameAtRow(8)).to eq("Combat Veteran")
      expect(@notes.getSignRelatedToStatusAtRow(8)).to eq("N/A")
      expect(@notes.getSignRelatedToNameAtRow(9)).to eq("Shipboard Hazard and Defense")
      expect(@notes.getSignRelatedToStatusAtRow(9)).to eq("N/A")
      
      expect(@driver.find_element(:css, "#sign-section ul:nth-of-type(5) li:nth-of-type(1)").text).to eq("Diagnosis")
      #TODO: unstable due to lack of autocomplete - uncomment once implemented
#      expect(@notes.getSignDiagnosisNameAtRow(2)).to eq("999.49 - Anaphylactic Reaction due to other Serum (ICD-9-CM 999.49)")
      
      expect(@driver.find_element(:css, "#sign-section ul:nth-of-type(6) li:nth-of-type(1)").text).to eq("Procedures")
      #TODO: unstable due to lack of autocomplete - uncomment once implemented
#      expect(@notes.getSignProcedureNameAtRow(2)).to eq("00625 - Anesthesia for Procedures on the Thoracic Spine and Cord, via an Anterior Transthoracic Approach; not Utilizing 1 Lung Ventilation")
      
      puts("    -signing note with invalid signature, this should fail...")
      @notes.clickSign()
      expect(@notes.signSubmitButtonDisabled()).to be_true 
      expect(@driver.find_element(:css, "#progressNotes-pin").attribute("type")).to eq("password")#PV-888
      @notes.setEsig("1234abcd")#invalid esig
      expect(@notes.signSubmitButtonDisabled()).to be_false #PV-973
      @notes.clickSignPopupSubmit()
      expect(@notes.getInvalidCredentialsMessage()).to eq("eSignature is incorrect. Please re-enter.")
      
      @notes.clickSignPopupCancel()
      
      expect(@eu.element_present?(:css, "#signPopup-popup.ui-popup-hidden")).to be_true #PV-891
      expect(@notes.getSignNoteBody()).to eq(testNoteBody)

      @notes.clickSign()
      #TODO: bug - uncomment when fixed
      puts("    -signing note with valid signature, this should pass...")
      expect(@notes.signSubmitButtonDisabled()).to be_true 
      @notes.setEsig("CPRS1234")
      @notes.clickSignPopupSubmit()

      #wait for the note to be signed
      sleep(5)
      
      #Verify that the note is destroyed and a new note can be created
      puts("    -validating that note content is cleared and a new note can be created...")
      @notes.openProgressNotes()
      expect(@notes.getNoteTitle()).to eq("")
      expect(@notes.getNoteBody()).to eq("")
    end
  end
end  
