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
    @patient_name = 'ten, patient'
    puts 'Searching for patient', @patient_name
    @search.clickPopupWindowOkButton()
    @search.updatePatientContext("seventynine, patient")
    # @search.updatePatientContext("ten, patient")
    # @notes.openProgressNotes()

  end
  
  describe "PV-579: Encounter form - Procedures" do

    it 'should have a complete list of selectable and removable procedures and disagnoses for note completion <complete>' do
      puts "    -opening note writer and entering a default set of note contents..."
      @notes.openProgressNotes()
      @notes.setNoteTitle("C&P D")
      puts @notes.consultPopupIsVisible()
      @notes.selectNoteTitle("C&P DIABETES MELLITUS")
      puts @notes.consultPopupIsVisible()
      @wait.until{ expect(@notes.consultPopupIsVisible()).to be_falsey }
      @notes.setNoteBody("This is a test")
      # @notes.createDefaultNote()

      puts "    -opening link tab and creating a new visit..."
      @notes.openLinkTab()
      @notes.createDefaultNewVisit()

      puts "    -opening encounter tab, creating a default visit type..."
      @notes.openEncounterTab()
      puts "        -entering Related To information..."
      @notes.createDefaultRelatedTo()
      puts "        -entering Diagnosis information..."
      @notes.createDefaultDiagnosis()

      puts "    -opening procedures tab, verifying default UI state..."
      @notes.expandProcedure()
      
      expect(@notes.selectAllDisabled()).to be true
      expect(@notes.deselectAllDisabled()).to be true
      expect(@notes.removeDisabled()).to be true
      expect(@notes.signTabIsDisabled()).to be true #PV-672, PV-666
      
      puts "    -searching for procedure 449, selecting first entry..."
      @notes.searchForProcedure("449")
      expect(@notes.getProcedureSearchResultsLength()).to be > 0
      puts "        -selecting procedure 44900..."
      @notes.selectSearchedProcedureAtRow(1)
      
      puts "        -expecting procedure to be populated, sign tab should be enabled"
      expect(@notes.getProcedureNameAtRow(1)).to eq("44900 - Open Incision and Drainage of Appendiceal Abscess")
      expect(@notes.signTabIsDisabled()).to be_false() #PV-672, PV-666

      #Add more procedures to verify sorting and removing procedures
      puts "    -searching for procedure 449, selecting second entry..."
      @notes.searchForProcedure("449")
      @notes.selectSearchedProcedureAtRow(1)  
      
      puts "    -searching for procedure 449, selecting third entry (second in result list)..."
      @notes.searchForProcedure("449")
      @notes.selectSearchedProcedureAtRow(1)
      
      expect(@notes.getProcedureListLength()).to eq(3)

      #select and remove the last procedure
      puts "    -selecting procedure and removing, validating..."
      @notes.selectExistingProcedure(3)

      @notes.clickRemove()
      expect(@notes.getProcedureListLength()).to eq(2)
      
      puts "    -testing select all and deselect all..."
      @notes.clickSelectAll()
      expect(@notes.procedureIsSelected(1)).to be true
      expect(@notes.procedureIsSelected(2)).to be true
      
      @notes.clickDeselectAll()
      expect(@notes.procedureIsSelected(1)).to be false
      expect(@notes.procedureIsSelected(2)).to be false

      puts "    -testing procedure modifiers funtionality..."
      @notes.openProcedureModifierAtRow(1)        
      @notes.selectProcedureModifierAtRow(1)
      @notes.selectProcedureModifierAtRow(2)
      @notes.closeProceduresModifierPopup()
      
      expect(@notes.getProcedureModifierAtRow(1,1)).to eq("'OPT OUT' PHYS/PRACT EMERG OR URGENT SERVICE")
      expect(@notes.getProcedureModifierAtRow(1,2)).to eq("ACTUAL ITEM/SERVICE ORDERED")

      #TODO: Verify the 'No modifiers found' feature if it's still valid
      
    end

  end 
  
end  