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
require_relative '../../config'
require_relative "../../pages/patientInfo"


describe "Dashboard view of staff-centric applets Story#CNTR-130" do

	before(:all) do
		GeneralUtility.setConfig($config)
	    @wait = GeneralUtility.wait
	    @eu = ElementUtility.new
	    @gu = GeneralUtility.new
	    @login = ProviderLogin.new    
	    @mongo = MongoUtility.new  
	    @container = Container.new              
	    @search = Search.new   	    	    

   		@mongo.removeCollection("contextCollection", "patientContext")    

    	@login.loginAsCprs1234()            
	end

	describe "switch from Patient View to Staff View - AC#CNTR-132" do

		it 'should display Patient View as a default view - TEST#CNTR-235' do			
      @search.updatePatientContext('TEN, PATIENT')
			@wait.until { @eu.element_present?(:css, "#patient-context") }
			expect(@eu.element_present?(:css, "#patient-context .icon-9")).to eq(true)
			expect(@eu.element_present?(:css, "#patient-search .icon-15")).to eq(true)
		end

		it 'should switch from Patient View to Staff View - TEST#CNTR-235' do			
      @container.switchView()
			expect(@eu.element_present?(:css, "#context-wrapper .user-context")).to eq(true)
			expect(@eu.get_element(:css, "#context-wrapper .user-context").text).to eq("Hello PROGRAMMER, ONE")
		end

		it 'should switch from Staff View to Patient View - TEST#CNTR-236' do			
      @container.switchView()
			expect(@eu.element_present?(:css, "#patient-context .icon-9")).to eq(true)
			expect(@eu.element_present?(:css, "#patient-search .icon-15")).to eq(true)
		end
	end

	describe "Default Applet - AC#CNTR-133, AC#CNTR-136 " do
		it 'should display default applet for Patient View when switching from Staff View to Patient View - Test#CNTR-237' do			
      		expect(@container.getAppletTitle()).to eq("Cover Sheet")
		end
		it 'should display default applet for Staff View when switching from Patient View to Staff View - Test#CNTR-238' do			
      @container.switchView()
			expect(@container.getAppletTitle()).to eq("Task List")
			@container.switchView()
		end
	end


	describe "Wrapper sub-header - AC#CNTR-139, AC#CNTR-138" do
		it 'should list applets within the context menu for Patient View - Test#CNTR-239' do			
      expect(@eu.element_visible?(:link, "Cover Sheet")).to eq(true)
			expect(@eu.element_visible?(:link, "Task List")).to eq(false)
			expect(@eu.get_element(:css, "#portal-about-btn").text).to eq("About")
		end
		it 'should list applets within the context menu for Staff View - Test#CNTR-240' do			
      @container.switchView()
			expect(@eu.element_visible?(:link, "Task List")).to eq(true)
			expect(@eu.element_visible?(:link, "Cover Sheet")).to eq(false)
			expect(@eu.get_element(:css, "#portal-about-btn").text).to eq("About")
		end
	end


	describe "Container Footer --> negative test" do
		it 'should contain the app name and version' do			
      @wait.until{ @eu.get_element(:css, "#app-name > h1:not(:empty)") }
			expect(@eu.get_element(:css, "#app-name > h1").text).to eq("Container - v1.1.6")
		end

		it 'should display the logged in user' do			
      @wait.until{ @eu.element_present?(:css, "#portal-infobar-footer .user-context > span") }
			expect(@eu.get_element(:css, "#portal-infobar-footer .user-context > span").text).to eq("Logged in as: PROGRAMMER, ONE - WASHINGTON")
		end
	end

	describe "Container Header: AC#CNTR-137" do
		it 'should display the first and last name of logged in user: - TEST#CNTR-241' do			
      @wait.until{ @eu.element_present?(:css, "#context-wrapper .user-context") }
			expect(@eu.get_element(:css, "#context-wrapper .user-context").text).to eq("Hello PROGRAMMER, ONE")
		end

		it 'should display the icon for switching Staff view to Patient View - TEST#CNTR-235' do			
      expect(@eu.element_present?(:css, "#switch-view-mode .icon-switch-user")).to eq(true)
		end
	end
end
