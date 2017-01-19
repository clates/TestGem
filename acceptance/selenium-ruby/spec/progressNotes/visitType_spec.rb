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
    @mongo.collection("clinical-events").remove()
    GeneralUtility.driver.get($acp_url + "/" + $acp_app)
    puts("    -setting test patient (seventyeight, patient)...")
    @search.updatePatientContext("seventyeight, patient")
  end

  describe "PV-570: Encounter form - Visit Type" do

    it 'should allow user to select visit type, section and modifiers: PV-571, PV-662, PV-663' do
      puts("    -creating default note...")
      @notes.openProgressNotes()
      @notes.createDefaultNote()

      puts("    -opening link tab, setting time and date (current), location (Cardiology)...")
      @notes.openLinkTab()
      @notes.createDefaultNewVisit()
      
      #@notes.openNoteTab()
      puts("    -opening encounter tab, verifying default state of contents...")
      @notes.openEncounterTab()
      @notes.expandVisitType()
      
      #verify that the visit type is populated and nothing is selected by default
      expect(@eu.get_elements(:css, "#pn-visit-type-section fieldset:first-of-type .ui-radio").length).to be > 0
      expect(@eu.get_elements(:css, "#pn-visit-type-section fieldset:first-of-type .ui-radio .ui-icon-radio-on").length).to eq(0)
      #Verify that only the visit type section is displayed
      expect(@eu.get_elements(:css, "#pn-visit-type-section .ui-li-divider").length).to eq(1)

      puts("    -selecting new patient visit type...")
      @wait.until{ @eu.element_present?(:css, "#pn-visit-type-section fieldset:first-of-type .ui-radio:nth-of-type(3) input") }
      @eu.click(:css, "#pn-visit-type-section fieldset:first-of-type .ui-radio:nth-of-type(3) input")
      
      #Verify the 'section' and visit type sections are displayed
      puts("    -verifying additional section is visible and selecting extended visit duration (40m)...")
      @wait.until{ @eu.element_present?(:css, "#pn-visit-type-section fieldset:last-of-type .relative-wrapper:nth-of-type(3) > .ui-radio") }
      expect(@eu.get_elements(:css, "#pn-visit-type-section fieldset:last-of-type .relative-wrapper .ui-radio").length).to eq(3) 
      @eu.click(:css, "#pn-visit-type-section fieldset:last-of-type .relative-wrapper:nth-of-type(3) > .ui-radio input") #select second item (40min)
      @wait.until { @eu.element_present?(:css, "#pn-visit-type-section fieldset:last-of-type .relative-wrapper:nth-of-type(3) .ui-icon-radio-on") }

      #add section modifiers
      puts("    -adding section modifiers and closing popup...")
      @eu.click(:css, "#pn-visit-type-section fieldset:last-of-type > div:nth-of-type(3) > .ui-btn > button")

      @wait.until{ @eu.element_present?(:css, "#visit-section-modifiers .ui-checkbox") }
      # find_element narrows selection to first element to match
      @eu.click(:css, "#visit-section-modifiers fieldset div:first-of-type label") #click on first modifier
      @notes.closeVisitTypeModifierPopup()
      @wait.until{ @eu.element_present?(:css, "#pn-visit-type-section fieldset:last-of-type > .relative-wrapper:nth-of-type(3) .ui-li-desc") }
      
      puts("    -verifying selection has correctly affected contents...")
      expect(@eu.get_element(:css, "#pn-visit-type-section fieldset:last-of-type .relative-wrapper:nth-of-type(3) .ui-li-desc").text()).to eq("'OPT OUT' PHYS/PRACT EMERG OR URGENT SERVICE")

      #tap different visit type, which should cause the sections and modifiers to change
      puts("    -selecting different visit type, verifying that only one selection can be performed...")
      @eu.click(:css, "#pn-visit-type-section fieldset:last-of-type .relative-wrapper:nth-of-type(4) > .ui-radio input") #select second item (40min)
      @wait.until { @eu.element_present?(:css, "#pn-visit-type-section fieldset:last-of-type .relative-wrapper:nth-of-type(4) .ui-icon-radio-on") }
      expect(@eu.element_present?(:css, "#pn-visit-type-section fieldset:last-of-type .relative-wrapper:nth-of-type(3) .ui-icon-radio-on")).to be_false() #check that only one radio button is selected

      #tap the first visit type, which should cause the sections and modifiers to change back to what was previously selected
      puts("    -selecting original visit type, verifying that previously chosen content will be repopulated...")
      @eu.click(:css, "#pn-visit-type-section fieldset:last-of-type .relative-wrapper:nth-of-type(3) > .ui-radio input") #select second item (40min)
      @wait.until { @eu.element_present?(:css, "#pn-visit-type-section fieldset:last-of-type .relative-wrapper:nth-of-type(3) .ui-icon-radio-on") }
      expect(@eu.get_element(:css, "#pn-visit-type-section fieldset:last-of-type .relative-wrapper:nth-of-type(3) .ui-li-desc").text()).to eq("'OPT OUT' PHYS/PRACT EMERG OR URGENT SERVICE")
    end

    it 'should allow the signing of a note when only a visit type is selected with no procedures' do
      puts "    -opening note writer and entering a default set of note contents..."
      @notes.openProgressNotes()
      @notes.createDefaultNote()

      puts "    -opening link tab and creating a new visit..."
      @notes.openLinkTab()
      @notes.createDefaultNewVisit()

      puts "    -opening encounter tab, creating a default visit type..."
      @notes.openEncounterTab()
      @notes.createDefaultVisitType()
      puts "        -entering Related To information..."
      @notes.createDefaultRelatedTo()
      puts "        -entering Diagnosis information..."
      @notes.createDefaultDiagnosis()

      puts "    -opening procedures tab, verifying default UI state..."
      @notes.expandProcedure()
      
      expect(@notes.selectAllDisabled()).to be_true()
      expect(@notes.deselectAllDisabled()).to be_true()
      expect(@notes.removeDisabled()).to be_true()
      expect(@notes.signTabIsDisabled()).to be_false() #PV-672, PV-666
    end
  end

  describe "PV-570: Encounter form - Visit Type" do
    it 'should present a message when no visit types exist: PV-938' do
      @notes.openProgressNotes()

      @notes.createDefaultNote()
      @notes.openLinkTab()
      
      @notes.setCurrentDate()
      @notes.setCurrentTime()
      @notes.setLocation("DIA")
      sleep(3)
      @notes.selectLocation("DIABETIC")
      
      @notes.openNoteTab()
      @notes.openEncounterTab()
      @notes.expandVisitType()
      
      expect(@eu.get_element(:css, "#noVisitType").text()).to eq("Clinic has not provided Visit Types")
    end
  end
end  
