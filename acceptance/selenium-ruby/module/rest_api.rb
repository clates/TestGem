require "selenium-webdriver"
require 'rubygems'
require 'JSON'
require "rspec"
require 'rest-client'
require_relative "../pages/_config"
include RSpec::Expectations

#LOGIN
def get_patient(driver)

  @wait = Selenium::WebDriver::Wait.new(:timeout => 60)
  @wait.until {
    driver.execute_script(
        [
            "var x = ' ';",
            "x = sessionStorage.getItem('token');",
            "return !!x;"
        ].join("\n")
    )
  }
  token = driver.execute_script("var x = ' '; x = sessionStorage.getItem('token'); return eval(x);")
  #PATIENT-VIEWER
  token = "Bearer "+token
  url = $acp_url + '/PatientViewerServices/rest/mhpuser'
  puts "loading #{url}"
  response = RestClient::Request.execute(method: :get, url: url, headers: {authorization: token, :accept => :json})
  json_hash = JSON.parse(response)

  vistaLocation = json_hash['vistaLocation']#688
  userIdentifier = json_hash["userIdentifier"]#
  uniqueId = userIdentifier['uniqueId']
  url = $acp_url + '/UserContext/rest/context/user/system/'+vistaLocation+'/id/'+uniqueId
  puts "loading #{url}"
  response = RestClient::Request.execute(method: :get, url: url, headers: {authorization: token, :accept => :json})

  json_hash = JSON.parse(response)
  return json_hash

end
