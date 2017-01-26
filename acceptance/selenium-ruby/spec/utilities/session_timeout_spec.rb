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

describe "Session Timeout Handler" do

	before(:all) do
    GeneralUtility.setConfig($config)
    @driver = GeneralUtility.driver
    @wait = GeneralUtility.wait
    @search = Search.new
    @container = Container.new
    @gu = GeneralUtility.new
    @eu = ElementUtility.new
    login = ProviderLogin.new

    login.loginAsCprs1234()
	end
	

	#should also have test for popup showing at appropriate time after Continue button has been clicked?
	describe 'A warning popup' do
		it 'shows when the session has (less than) three minutes left' do
			sleep ((15 - 3) * 60)
			@wait.until{ @eu.element_present?(:css, ".ui-popup-active #logout-warning-popup") }
		end

		it 'shows the number of minutes remaining when the session has between three minutes to one minute left' do
			expect(@eu.get_element(:id, "countdown-session").text()).to eq("3")
			expect(@eu.get_element(:id, "countdown-units").text()).to eq("Minute(s)")
			sleep(60)
			expect(@eu.get_element(:id, "countdown-session").text()).to eq("2")
			expect(@eu.get_element(:id, "countdown-units").text()).to eq("Minute(s)")
			sleep(60)
		end

		it 'shows the number of seconds remaining when the session has (less than) one minute left' do
			expect(@eu.get_element(:id, "countdown-session").text()).to_not eq("1")
			expect(@eu.get_element(:id, "countdown-units").text()).to eq("Second(s)")
		end

		describe 'has a Continue button that' do
			it 'should reset the session timer and reload the current page on click' do
				continue_button_element = @eu.get_element(:id, "session-continue-button")

				expect(continue_button_element.text()).to eq("Continue")
				continue_button_element.click()
			end
		end

		describe 'has a Logout button that' do
			it 'should tell the server to end the session and load the Launchpad page on click' do
			end
		end
	end

	describe 'A reconnect popup' do
		it 'shows when the session has ended' do
		end

		describe 'has a Login button that' do
			it 'should should load the authentication login page on click and redirect user back to app after a successful login' do
			end
		end

		describe 'has a Launchpad button that' do
			it 'should tell the server to end the session and load the Launchpad page on click' do
			end
		end
	end
end