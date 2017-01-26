require './helper'
#@base_url = "http://localhost"

#driver = Selenium::WebDriver.for :chrome
#driver.manage.timeouts.implicit_wait = 10 # seconds

before(:each) do
  @driver = Selenium::WebDriver.for :chrome
  #Selenium IDE put in a slash at end of base_url which caused bad url's below
  @base_url = "http://localhost"
  @accept_next_alert = true
  @driver.manage.timeouts.implicit_wait = 10 # seconds
  @verification_errors = []

  login = PortalLogin.new @driver, @base_url
#  @launchpad = login.loginAsStaff01
#  puts @launchpad
end

#after(:each) do
#  @driver.quit
#  [].should == @verification_errors
#end


#describe 'System availability notification' do

#loginAsStaff01

def loginAsStaff01

  element = driver.get(@base_url + "/portal/")

  puts "Page title is #{driver.title}"
  
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  wait.until { driver.title.downcase.start_with? "department of veterans affairs" }
  
  puts "Page title is #{driver.title}"
  
  #Enter credentials/site
  element = driver.find_element(:id, "name-c").send_keys "zztest.staff01"
  element = driver.find_element(:id, "password").send_keys "pass"
  #Enter DC
  element = driver.find_element(:css, "input.ui-input-text.ui-body-d").send_keys "dc"
#  wait = Selenium::WebDriver::Wait.new(:timeout => 30)
  #Click the location popup
  #wait.until(ExpectedConditions.presenceOfElementLocated(By.css("a[data-facility-name='DC VAMC']")))
  element = driver.find_element(:css, "a[data-facility-name='DC VAMC']").click

  #Submit
  element = driver.find_element(:id, 'loginButton').click

end

#wait = Selenium::WebDriver::Wait.new(:timeout => 500)
wait.until { driver.title.downcase.start_with? "portal" }
puts "Page title is #{driver.title}"



#WebElement myDynamicElement = (new WebDriverWait(driver, 10))
#  wait.until(ExpectedConditions.presenceOfElementLocated(By.id('messageButton')))
# static wait as workaround
sleep(3)
driver.find_element(:id, 'messageBadge').text.include? "2"
$messageCount = driver.find_element(:id, 'messageBadge').text
puts "Message count is #$messageCount"
#puts "Message count is #{driver.find_element}"
driver.find_element(:css, "#messageButton").click
# static wait as workaround
sleep(1)
#Confirme that message count goes to 0 after messages are viewed
driver.find_element(:id, 'messageButton').text.include? "0"
$messageCount = driver.find_element(:id, 'messageBadge').text
puts "Message count is #$messageCount"


#element = driver.page_source.include? 'System Alerts'

#end

#driver.quit
