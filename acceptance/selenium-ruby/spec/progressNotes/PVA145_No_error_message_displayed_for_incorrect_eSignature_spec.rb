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


describe "Story:PVA-145:No Error message displays for incorrect eSignature" do

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
    @search.confirmPopWindowOkButton()
    @search.updatePatientContext(@patient_name)
    @container.waitForLoader
    @notes.openProgressNotes()

  end


  describe "Story:PVA-145:No Error message displays for incorrect eSignature" do

    context "Creating a Note and link to an appointment and adding Encounter information and then saving it" do
      it 'Should verify able to create a Note by selecting a valid title and entering note text' do
        @notes.setNoteTitle("C&P D")
        puts @notes.consultPopupIsVisible()
        @notes.selectNoteTitle("C&P DIABETES MELLITUS")
        puts @notes.consultPopupIsVisible()
        @wait.until{ expect(@notes.consultPopupIsVisible()).to be_falsey }
        @notes.setNoteBody("This is a test for PVA-145")
        puts 'Notes body is set to This is a test for PVA-145'

      end

      it 'Should allow to click Link tab and select Hospitalization' do

        @notes.openLinkTab()
        @notes.expandHospitalizations()
        expect(@eu.get_element(:css, "#hospital-appointment-list li:nth-of-type(1) a h3").text()).to eq("7A GEN MED")
        @notes.selectHospitalAdmission("7A GEN MED", "03/25/2004 8:31 AM")

      end

      it 'Should allow to click Encounter link and select Providers' do

        expect(@notes.encounterTabIsDisabled()).to be false
        @notes.openEncounterTab()
        @notes.expandProvider()
        @notes.providerClickSelectAll()

      end

      it 'Should verify that user can enter valid signature/submit signature OR an error message shows up on entering invalid eSignature'do
        @notes.openSignTab()
        @notes.clickSign()
        @driver.switch_to.window @driver.window_handles.last
        puts "Enter invalid eSignature"
        @notes.setEsig("111112")
        @notes.clickSignPopupSubmit()
        expect(@notes.getInvalidCredentialsMessage()).to eq ("eSignature is incorrect. Please re-enter.")
        puts "Enter valid eSignature"
        @notes.setEsig("111111")
        puts "Click Submit button"
        @notes.clickSignPopupSubmit()
        @container.waitForLoader

      end

    end

  end

end
