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
    @search.updatePatientContext("seventyeight, patient")
  end
  
  #acceptance tests to implement (on existing functionality):
  #   -test removal of providers and primary selection updates
  #   -test stability of save and resume, so add some new items, remove some, set others to primary, swap patients around and retest validity
  
  describe "PV-582: Encounter form - Primary Provider" do

    it 'should allow user to select providers: PV-664, PV-665, PV-876, PV-947' do
      requiredNoteSetup()
      
      #TODO: complete the minimum data to enable the sign button
      
      expect(@notes.getProviderNameAtRow(1)).to eq("PROGRAMMER, ONE")#PV-876
      expect(@notes.providerIsPrimaryAtRow(1)).to be_true()#PV-876
      
      @notes.searchForProvider("pro")
      #PV-947: Verify the provider list is populated
      providerList = @notes.getSearchedProviderList()
      @wait.until{ @eu.element_present?(:css, "#provider-list li") }
      expect(@eu.element_present?(:css, "#provider-list li")).to be_true

      # previousItem = providerList[0].text()
      # for i in (0...providerList.size)
      #   nextItem = providerList[i].text()
      #   expect(previousItem <= nextItem).to be_true
      #   previousItem = nextItem
      # end
      
      puts "    -adding additional providers"
      selectProviderAtRow(1)
      @notes.searchForProvider("PROVIDER,EIGHTEEN")
      selectProviderAtRow(1)
      
      expect(@notes.providerIsPrimaryAtRow(1)).to be_true()#logged-in provider is still primary
      
      #set other user as primary
      puts "    -selecting new primary provider"
      @notes.setProviderAsPrimaryAtRow(3)
      expect(@notes.providerIsPrimaryAtRow(3)).to be_true()
      
      #remove the primary provider
      puts "    -removing currently selected primary provider, verifying correct re-selection to first provider"
      @notes.selectAvailableProviderAtRow(3)
      @notes.providerClickRemove();
      expect(@notes.providerIsPrimaryAtRow(1)).to be_true()#logged-in provider is now primary
    end
  end

  def requiredNoteSetup
    @notes.openProgressNotes()

    @notes.createDefaultNote()
    @notes.openLinkTab()

    @notes.createDefaultNewVisit()
    @notes.openNoteTab()
    @notes.openEncounterTab()
    @notes.expandProvider()
  end

  def selectProviderAtRow(index)
    #note, stale element happens because the list needs time to re-query and redraw after every selection and keypress, should consider updating frontend code
    begin
      @notes.selectProviderAtRow(1)
    rescue
      puts "error: caught potential stale element, re-attempting selection after waiting 2 seconds"
      @notes.selectProviderAtRow(1)
    end
  end

end  