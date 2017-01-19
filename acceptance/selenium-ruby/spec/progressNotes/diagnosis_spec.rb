require "bundler/setup"
require "selenium-webdriver"
require "rspec"

require 'applet-test-helpers/utilities/general-utility'
require 'applet-test-helpers/utilities/element-utility'
require 'applet-test-helpers/pages/container'
require 'applet-test-helpers/pages/provider-login'
require 'applet-test-helpers/rest/patient-rest-client'
require 'applet-test-helpers/mongo/mongo-utility'
require 'search-page'
require 'date'
require 'applet-test-helpers/pages/orders-viewer'
require "applet-test-helpers/pages/progress-notes"
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
    GeneralUtility.driver.get(@gu.appUrl)
    @search.clickPopupWindowOkButton()
    @search.updatePatientContext("seventyeight, patient")
    @notes.openProgressNotes()
  end  
  
  describe "PV-580: Encounter form - Diagnosis" do
    #PV-676: User is able to see the patient's Problem list to select a potential diagnosis
    #PV-677: User is able to perform an auto-complete search for diagnosis terms
    #PV-678: User is able to  indicate a single diagnosis as the primary diagnosis for the encounter
    #PV-679: User is unable to sign/submit encounter form without Primary Diagnosis indicated
    #PV-680: User is able to indicate if a diagnosis item for the encounter should be added to the patient's problem list (if not already on it)
    #PV-681: User is able to select all diagnosis items to be added to patient's problem list (if not already on it)


    it 'should allow user to select diagnoses: PV-676, PV-678, PV-679, PV-680, PV-681' do    
      @notes.createDefaultNote()
    
      @notes.openLinkTab()
      @notes.createDefaultNewVisit()
      @notes.openNoteTab()
      
      @notes.openEncounterTab()
      @notes.createDefaultVisitType()

      @notes.createDefaultRelatedTo()

      @notes.createDefaultProcedure()      

      @notes.expandDiagnosis()
      expect(@notes.signTabIsDisabled()).to be_true() #PV-677
      expect(@notes.diagnosisSelectAllDisabled()).to be_true()
      expect(@notes.diagnosisDeselectAllDisabled()).to be_true()
      expect(@notes.diagnosisRemoveDisabled()).to be_true()
      
      problemListDiagnosis = @eu.get_element(:css, "#problem-list .ui-checkbox:nth-of-type(2) h3").text()
      icd9Code = @eu.get_element(:css, "#problem-list .ui-checkbox:nth-of-type(2) .diagnosis-code").text().strip
      
      expect(problemListDiagnosis[0..5].strip).to eq(icd9Code)#PV-1362: Verify the ICD code is displayed first

      @notes.selectDiagnosisFromProblemListAtRow(1)
      
      expect(@notes.getDiagnosisDescriptionAtRow(1)).to eq(problemListDiagnosis)
      expect(@notes.diagnosisAddToPlIsDisabledAtRow(1)).to be_true()
      @notes.selectDiagnosisFromProblemListAtRow(1) #deselect the problem list
      

      @notes.searchForDiagnosis(icd9Code)
      
      @eu.get_element(:css, "#diagnosis-section-autocomplete input").send_keys " "
      expect(@eu.get_element(:css, "#diagnosis-autocomplete li:nth-of-type(1) a h3").text[0..5].strip).to eq(icd9Code)
      @notes.selectSearchedDiagnosisAtRow(1)

      
      @notes.searchForDiagnosis(icd9Code)
      @wait.until{ element_present?(:css, "#diagnosis-autocomplete li.ui-li-divider") }

      expect(@eu.get_element(:css, "#diagnosis-autocomplete li.ui-li-divider").text()).to eq("There Were No Results Found Matching Your Search")
      
      
      @notes.searchForDiagnosis("410")
      diagnosisSearchResults = @notes.getDiagnosisSearchList()
      expect(diagnosisSearchResults.length).to be > 0
    
      previousItem = diagnosisSearchResults[0].text()
      for i in (1...diagnosisSearchResults.length)
        nextItem = diagnosisSearchResults[i].text()
        expect(previousItem <= nextItem).to be_true
        previousItem = nextItem
      end
      
    
      @notes.searchForDiagnosis("dia")
      @notes.selectSearchedDiagnosisAtRow(1)
      
      expect(@notes.diagnosisIsPrimaryAtRow(1)).to be_true()
      
      @notes.searchForDiagnosis("dia")
      @notes.selectSearchedDiagnosisAtRow(2)
      
      @notes.searchForDiagnosis("dia")
      @notes.selectSearchedDiagnosisAtRow(3)
      
      expect(@notes.getSelectedDiagnosisListLength).to be > 0

    
      @notes.setDiagnosisAsPrimaryAtRow(3)
      @notes.addDiagnosisToProblemListAtRow(3)      
      
      expect(@notes.diagnosisIsPrimaryAtRow(3)).to be_true()
      expect(@notes.diagnosIsSetToAddToPLAtRow(3)).to be_true()
      
      expect(@notes.signTabIsDisabled()).to be_false() #PV-677

    
      @notes.diagnosisClickSelectAll()
      
      selectedLength = @notes.getSelectedDiagnosisListLength() 
      for i in (1...selectedLength)
        expect(@notes.diagnosisIsSelectedAtRow(i)).to be_true()
      end

    
      @notes.diagnosisClickDeselectAll()
      for i in (1...selectedLength)
        expect(@notes.diagnosisIsSelectedAtRow(i)).to be_false()
      end

    
      @notes.selectSelectedDiagnosisAtRow(1)
      @notes.diagnosisClickRemove()
      
      expect(@notes.getSelectedDiagnosisListLength()).to eq(selectedLength - 1)
    end
  end  
end  