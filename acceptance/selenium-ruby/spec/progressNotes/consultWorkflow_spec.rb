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

    @search.updatePatientContext("ten, patient")
    @notes.openProgressNotes()
  end  
  
  
  describe "PV-1437: Consult note title workflow" do
    it 'expect only open the note popup if a consult note title is selected' do
      @notes.setNoteTitle("C&P D")      
      @notes.selectNoteTitle("C&P DIABETES MELLITUS")      
      @wait.until{ expect(@notes.consultPopupIsVisible()).to be false }

    end

    it 'expect present a message when a patient has no consults' do      
      @search.updatePatientContext("eleven, patient")      
      @notes.openProgressNotes()      

      selectConsultNote()
      @wait.until{ @eu.get_element(:css, "#note-select-consult-popup.ui-popup-active").displayed? }
      
      expect(@eu.get_element(:css, "#note-select-consult li h3").text()).to eq("INFECTIOUS DISEASE Cons")
      
      @notes.closeConsultPopupWithoutSelection()
      
      expect(@notes.getNoteTitle()).to eq("")
    end

     it 'expect require a valid consult when a consult note title is selected' do
       @search.updatePatientContext("eleven, patient")

       @notes.openProgressNotes()  
       selectConsultNote()
       @container.waitForLoader      
       @wait.until{ @eu.get_element(:css, "#note-select-consult-popup.ui-popup-active").displayed? }
       expect(@notes.selectNoteConsultPopupIsVisible).to be true


       expect(@eu.get_element(:css, "#note-select-consult-popup li:nth-of-type(1)").text()).to eq("Select a Consult")

       consults = @notes.getConsultList()
       expect(consults.length).to be > 0

       #PV-1664: Verify the consults are sorted in chronological order
       previousItem = consults[0].text()[0..9]
       for i in (0...consults.length)
         nextItem = consults[i].text()[0..9]

         nextItemDateTime = DateTime.strptime(nextItem, '%m/%d/%Y')
         previousItemDateTime = DateTime.strptime(previousItem, '%m/%d/%Y')

         expect(previousItemDateTime <= nextItemDateTime).to be true

          previousItem = nextItem
       end

       @notes.closeConsultPopupWithoutSelection()
       sleep(30)       
       expect(@notes.consultPopupIsVisible()).to be false
       sleep(10)
       expect(@notes.getNoteTitle()).to eq("")
     end



     it 'expect require a consult note title to sign: PV-1658, PV-1659, PV-1661, PV-1664, PV-1669 ' do
       
       @mongo.removeCollection("note-writer", "clinical-events")    

       @search.setPatientContextBySSN("o0001", "one, patient")
       
       @notes.setNoteBody("Consult Test Note Body")

       
       selectConsultNote()
       @notes.selectConsultAtRow(1)
       expect(@notes.getNoteTitle()).to eq("CONSULT  <CARE COORDINATION HOME TELEHEALTH SCREENING CONSULT>") #PV-1659
       
       @notes.openLinkTab()

       @notes.createDefaultNewVisit()

       @notes.openNoteTab()
       @notes.openEncounterTab()

       @notes.createDefaultVisitType()
       @notes.createDefaultRelatedTo()
       @notes.createDefaultDiagnosis()
       @notes.createDefaultProcedure()


       expect(@notes.signTabIsDisabled()).to be_false

       @notes.openNoteTab()

       selectConsultNote()
       @notes.closeConsultPopupWithoutSelection()

       expect(@notes.getNoteTitle()).to eq("")
       expect(@notes.signTabIsDisabled()).to be_true

       selectConsultNote()
       @notes.selectConsultAtRow(1)
       expect(@notes.getNoteTitle()).to eq("CARE COORDINATION HOME TELEHEALTH SCREENING CONSULT  <CARE COORDINATION HOME TELEHEALTH SCREENING CONSULT>")

       @notes.saveNote()
       @search.updatePatientContext("onehundred, inpatient")
       @notes.openProgressNotes()
       expect(@notes.getNoteTitle()).not_to eq("CARE COORDINATION HOME TELEHEALTH SCREENING CONSULT  <CARE COORDINATION HOME TELEHEALTH SCREENING CONSULT>")

       @search.setPatientContextBySSN("o0001", "one, patient")
       @notes.openProgressNotes()
       @notes.openNoteTab()
       expect(@notes.getNoteTitle()).to eq("CARE COORDINATION HOME TELEHEALTH SCREENING CONSULT  <CARE COORDINATION HOME TELEHEALTH SCREENING CONSULT>") #PV-1659

       @notes.openSignTab()
       expect(@notes.getSignNoteTitle()).to eq("CARE COORDINATION HOME TELEHEALTH SCREENING CONSULT <CARE COORDINATION HOME TELEHEALTH SCREENING CONSULT>")#PV-1659
    end
  end

  def selectConsultNote()
    @notes.setNoteTitle("CONSULT  <DIETICIAN CONSULT NOTE>")
    partialtext = "CARE COORDINATION HOME TELEHEALTH SCREENING CONSULT"
         
    @wait.until{ @eu.get_element(:partial_link_text, partialtext)}.displayed?
    @eu.click(:partial_link_text, partialtext)
  end
end

