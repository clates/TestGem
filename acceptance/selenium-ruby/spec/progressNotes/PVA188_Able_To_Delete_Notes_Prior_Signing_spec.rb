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


describe "Story:PVA-188:Note must be able to be deleted prior to signing" do

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
    @search.updatePatientContext(@patient_name)
     waitForLoader

    @notes.openProgressNotes()

  end


  describe "Story:PVA-188:Note must be able to be deleted prior to signing" do
    it 'Story:PVA-188:Should verify that user is able to enter Note Title, then delete the Note and deleted Note does not display under Task List' do
      @notes.setNoteTitle("C&P D")
      puts @notes.consultPopupIsVisible()
      @noteTitle = "C&P DIABETES MELLITUS"
      @notes.selectNoteTitle(@noteTitle)
      puts @notes.consultPopupIsVisible()
      @wait.until{expect(@notes.consultPopupIsVisible()).to be false}
       @notes.setNoteBody("This is a Note Text")
      @notes.saveNote()
      waitForLoader
      @notes.openSwitchUserFolderIcon()
      @notes.clickTaskListMenu()
      puts "Number of rows display in table"
      puts @notes.getNoteCountFromTable()
      expect(@noteTitle).to eq (@notes.getFirstRowTitle())
      @eu.click(:css, '#content-table tr:nth-of-type(1) td:nth-of-type(3)')
      puts "Clicking X button on popup window"
      @search.confirmPopWindow()
      waitForLoader
      @notes.deleteNoteButton()
      @notes.clickDeleteYesButton()
      waitForLoader
      @notes.openSwitchUserFolderIcon()
      waitForLoader
      expect(@notes.getNoteCountFromTable()) == 0
    end

     it 'Should verify that user enter Note and Link information and then delete Note and deleted Note does not display under Task List' do
       @notes.openSwitchUserFolderIcon()
      # waitForLoader
      @notes.openProgressNotes()
      @notes.setNoteTitle("C&P D")
      puts @notes.consultPopupIsVisible()
      @noteTitle = "C&P DIABETES MELLITUS"
      @notes.selectNoteTitle(@noteTitle)
      puts @notes.consultPopupIsVisible()
      @notes.setNoteBody("This is a Note/Link Text")
      @notes.openLinkTab
      @notes.expandHospitalizations()
      expect(@eu.get_element(:css, "#hospital-appointment-list li:nth-of-type(1) a h3").text()).to eq("7A GEN MED")
      @notes.selectHospitalAdmission("7A GEN MED", "03/25/2004 8:31 AM")

    #   CLICK DELETE BUTTON HERE
      @notes.saveNote()
      waitForLoader
      @notes.openSwitchUserFolderIcon()
      waitForLoader
      @notes.clickTaskListMenu()
      puts "Number of rows display in table"
      puts @notes.getNoteCountFromTable()
      expect(@noteTitle).to eq (@notes.getFirstRowTitle())
      @eu.click(:css, '#content-table tr:nth-of-type(1) td:nth-of-type(3)')
      puts "Clicking X button on popup window"
      @search.confirmPopWindow()
      waitForLoader
      @notes.deleteNoteButton()
      @notes.clickDeleteYesButton()
      waitForLoader
      @notes.openSwitchUserFolderIcon()

      expect(@notes.getNoteCountFromTable()) == 0
    end

    it 'Should verify that user enter Note, Link and Encounter information then delete Note and deleted Note does not display under Task List' do
      @notes.openSwitchUserFolderIcon()
      @notes.openProgressNotes()
      @notes.setNoteTitle("C&P D")
      puts @notes.consultPopupIsVisible()
      @noteTitle = "C&P DIABETES MELLITUS"
      puts "Selecting Note Title"
      @notes.selectNoteTitle(@noteTitle)
      puts @notes.consultPopupIsVisible()
      @wait.until{expect(@notes.consultPopupIsVisible()).to be false}
      @notes.setNoteBody("This is a Note/Link/Encounter Text")
      @notes.openLinkTab
      @notes.expandHospitalizations()
      expect(@eu.get_element(:css, "#hospital-appointment-list li:nth-of-type(1) a h3").text()).to eq("7A GEN MED")
      @notes.selectHospitalAdmission("7A GEN MED", "03/25/2004 8:31 AM")
      expect(@notes.encounterTabIsDisabled()).to be false
      @notes.openEncounterTab()
      @notes.expandProvider()
      @notes.providerClickDeselectAll()

    #   click delete here
      @notes.saveNote()
      waitForLoader
      @notes.openSwitchUserFolderIcon()
      waitForLoader
      @notes.clickTaskListMenu()
      puts "Number of rows display in table"
      puts @notes.getNoteCountFromTable()
      expect(@noteTitle).to eq (@notes.getFirstRowTitle())
      @eu.click(:css, '#content-table tr:nth-of-type(1) td:nth-of-type(3)')
      puts "Clicking X button on popup window"
      @search.confirmPopWindow()
      waitForLoader
      @notes.deleteNoteButton()
      @notes.clickDeleteYesButton()
      waitForLoader
      @notes.openSwitchUserFolderIcon()
      waitForLoader
      expect(@notes.getNoteCountFromTable()) == 0

    end



    it 'Should verify that user able to delete Note before signing it and deleted Note does not display under Task List' do
      @notes.openSwitchUserFolderIcon()
      @notes.openProgressNotes()
      waitForLoader
      @notes.setNoteTitle("C&P D")
      puts @notes.consultPopupIsVisible()

      @noteTitle = "C&P DIABETES MELLITUS"
      puts "Selecting Note Title"
      @notes.selectNoteTitle(@noteTitle)
      puts @notes.consultPopupIsVisible()

      @wait.until{expect(@notes.consultPopupIsVisible()).to be false}
      @notes.setNoteBody("This is a test")
      @notes.openLinkTab
      @notes.expandHospitalizations()
      expect(@eu.get_element(:css, "#hospital-appointment-list li:nth-of-type(1) a h3").text()).to eq("7A GEN MED")
      @notes.selectHospitalAdmission("7A GEN MED", "03/25/2004 8:31 AM")
      expect(@notes.encounterTabIsDisabled()).to be false
      @notes.openEncounterTab()
      @notes.expandProvider()
      @notes.providerClickDeselectAll()
      @notes.openSignTab()

    #   click delete here
      @notes.saveNote()
      waitForLoader
      @notes.openSwitchUserFolderIcon()
      waitForLoader

      puts "Number of rows display in table"
      puts @notes.getNoteCountFromTable()
      expect(@noteTitle).to eq (@notes.getFirstRowTitle())
      @eu.click(:css, '#content-table tr:nth-of-type(1) td:nth-of-type(3)')
      puts "Clicking X button on popup window"
      @search.confirmPopWindow()
      waitForLoader
      @notes.deleteNoteButton()
      @notes.clickDeleteYesButton()
      waitForLoader
      @notes.openSwitchUserFolderIcon()
      waitForLoader
      expect(@notes.getNoteCountFromTable()) == 0

    end

  end

end
