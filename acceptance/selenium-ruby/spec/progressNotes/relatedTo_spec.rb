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
    
    @search.updatePatientContext("graphingpatient, two")
  end

  describe "PV-581: Encounter form - Related To..." do

    it 'Should have conditions related to events: PV-670 ' do
      puts("    -creating default note...")
      @notes.openProgressNotes()
      @notes.createDefaultNote()

      puts("    -opening link tab and creating default visit...")
      @notes.openLinkTab()
      @notes.createDefaultNewVisit()

      puts("    -opening encounter tab and validating \"Related To\" content...")
      @notes.openEncounterTab()
      @notes.expandRelatedTo()
      
      puts("         -validating descriptions...")
      expect(@notes.getConditionDescriptionAtRow(1)).to eq("Service Connected")
      expect(@notes.getConditionDescriptionAtRow(2)).to eq("Agent Orange")
      expect(@notes.getConditionDescriptionAtRow(3)).to eq("Radiation")
      expect(@notes.getConditionDescriptionAtRow(4)).to eq("Southwest Asia Conditions")
      expect(@notes.getConditionDescriptionAtRow(5)).to eq("MST")
      expect(@notes.getConditionDescriptionAtRow(6)).to eq("Head and/or Neck Cancer")
      expect(@notes.getConditionDescriptionAtRow(7)).to eq("Combat Veteran")
      expect(@notes.getConditionDescriptionAtRow(8)).to eq("Shipboard Hazard and Defense")
      
      #Verify the UI elements are set based on the data returned by the server
      puts("         -validating default enabled states...")
      expect(@notes.conditionIsDisabledAtRow(1)).to be_false
      expect(@notes.conditionIsDisabledAtRow(2)).to be_true
      expect(@notes.conditionIsDisabledAtRow(3)).to be_true
      expect(@notes.conditionIsDisabledAtRow(4)).to be_false
      expect(@notes.conditionIsDisabledAtRow(5)).to be_true
      expect(@notes.conditionIsDisabledAtRow(6)).to be_true
      expect(@notes.conditionIsDisabledAtRow(7)).to be_true
      expect(@notes.conditionIsDisabledAtRow(8)).to be_true

      #For the elements that aren't disabled, verify that they are not set to yes or no
      puts("         -validating default items are unchecked...")
      expect(@notes.conditionIsSetToNoAtRow(1)).to be_false 
      expect(@notes.conditionIsSetToYesAtRow(1)).to be_false

      expect(@notes.conditionIsSetToNoAtRow(4)).to be_false 
      expect(@notes.conditionIsSetToYesAtRow(4)).to be_false
        
      #set the related-to condition to yes and no and verify the value
      puts("         -validating selection default behavior...")
      @notes.setConditionToNoAtRow(1)
      @notes.setConditionToYesAtRow(4)

      expect(@notes.conditionIsSetToNoAtRow(1)).to be_true
      expect(@notes.conditionIsSetToYesAtRow(4)).to be_true

      #reverse the values and verify them   
      @notes.setConditionToYesAtRow(1)
      @notes.setConditionToNoAtRow(4)

      expect(@notes.conditionIsSetToYesAtRow(1)).to be_true
      expect(@notes.conditionIsSetToNoAtRow(4)).to be_true
            
    end
  end 
  
end  