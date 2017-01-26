require 'rubygems'
require 'selenium-webdriver'

driver = Selenium::WebDriver.for :chrome

#describe 'View system availability notification PP-155' do
  
  driver = Selenium::WebDriver.for :chrome
  driver.manage.timeouts.implicit_wait = 10 # seconds
  
  #def loginAsStaff01
  
    #element = driver.get(@base_url + "/portal/")
    driver.get "http://localhost/portal"
  
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
  
  #end
  
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
  driver.find_element(:css, "#messageButton").click
  # static wait as workaround
  sleep(1)
  # Confirm message popup 
#  $messageHeader = driver.find_element(:css, ".ui-popup-active li.first-child a").text
#  puts "Popup is #$messageHeader"
 
#examples from other tests   
#element = driver.find_element(:css, "li.ui-btn:nth-child(1) a").text.include? "Home"
#  popup.find_element(:css, '.ui-popup-active li:nth-child(2) span.ui-icon-checkbox-on') #Active selected

#Trial and error  
  #<li class="ui-li ui-li-static ui-btn-up-c ui-first-child ui-last-child" data-role="divider">System Alerts</li>
  #messageButton > span:nth-child(1) > span:nth-child(2)
  #alertHeader > li:nth-child(1)
#alertHeader > li:nth-child(1)
  
#alerts > li:nth-child(1) > p:nth-child(1)
#alerts > li:nth-child(1) > p:nth-child(2)
  $message1Content = driver.find_element(:css, ".ui-popup li:nth-child(1) a").text
  puts "Systems Alerts are #$message1Content"

  #Confirm that message count goes to 0 after messages are viewed
  driver.find_element(:id, 'messageButton').text.include? "0"
  $messageCount = driver.find_element(:id, 'messageBadge').text
  puts "Message count is #$messageCount"
  
 #driver.quit
