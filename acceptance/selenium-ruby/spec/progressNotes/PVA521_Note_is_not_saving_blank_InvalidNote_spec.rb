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


describe "Story:PVA-521:Note is not saving with blank and invalid Note Title" do

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
    @notes.openProgressNotes()
  end

describe "Story:PVA-521:Note is not saving with blank and invalid Note Title" do
  it 'Story:PVA-521:Should verify that Note is not saving with blank and invalid Note Title' do
    @notes.setNoteTitle("C&P D")
    puts @notes.consultPopupIsVisible()
    @notes.selectNoteTitle("C&P DIABETES MELLITUS")
    puts @notes.consultPopupIsVisible()
    @notes.setNoteBody("This is a test")
    @notes.setNoteTitle(" ")
    @notes.saveNote

    expect(@notes.getInvalidCredentialsMessageForNotesTitle).to eq ("Please select a valid note title")
    @notes.setNoteTitle("BUTTER")
    @notes.saveNote

    expect(@eu.get_element(:css, ".error-message").text()).to eq("Please select a valid note title")
  end
end
end