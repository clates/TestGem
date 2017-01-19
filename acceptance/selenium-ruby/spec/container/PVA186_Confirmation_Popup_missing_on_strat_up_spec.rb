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

include RSpec::Expectations


describe "Story:PVA-186:Confirmation pop-up missing on start up_spec.rb" do

  before(:all) do
    GeneralUtility.setConfig($config)
    @wait = GeneralUtility.wait
    @eu = ElementUtility.new
    @gu = GeneralUtility.new    
    @login = ProviderLogin.new
    @search = Search.new    
    @mongo = MongoUtility.new  
    @container = Container.new  
    @accept_next_alert = true    
    @verification_errors = []   
    
    @mongo.removeCollection("contextCollection", "patientContext")    

    @login.loginAsCprs1234KeepPopupOpen()
   end

 describe "Confirmation of pop-up message on Start-Up" do

  it 'Should verify that when user has no prior patient selected, no message will be shown' do
    @container.waitForLoader
    expect(@container.confirmPopWindowClosed).to be true
    @search.updatePatientContextByName('ten, patient')

    @eu.click(:css, '#user-nav-bottomlist >li:nth-of-type(3) div div a')
  end

  it 'Should verify that message dialog box have OK button ' do    
    @login.loginAsCprs1234()    
  end

   it 'Should verify that when user has previously had a patient in context, a popup message is presented to the user ' do
     @gu.refreshPage
      popupdata = @container.getPopupWindowText
      patdata = PatientRestClient.get_patient     

     formatteddob = Date.parse(patdata["dateOfBirth"])


      formatteddobto= formatteddob.strftime("%m/%d/%Y")
     expected = [
          "Last #{patdata["lastName"]}",
          "	    First #{patdata["firstName"]}",
          "	    DOB #{formatteddobto}",
          "	    Age #{patdata["age"]}",
          "	    Gender #{patdata["gender"].capitalize}",
          "	    Location #{patdata["wardLocation"]}, #{patdata["roombed"]}",
          "	    SSN #{patdata["ssn"]}"
     ].join("\n")

     expect(popupdata).to eq expected
    end


  it 'Should verify that clicking on X button will close the popup message ' do    
    @container.closePopWindow()    
    expect(@container.confirmPopWindowClosed).to be true
   end
end
end
