require 'rubygems'
require 'selenium-webdriver'

driver = Selenium::WebDriver.for :chrome

driver.manage.timeouts.implicit_wait = 5 # seconds

#def loginAsStaff01

  #element = driver.get(@base_url + "/portal/")
  driver.get "http://localhost/portal"

  #login button not required with automatic redirect to login screen
  #element = driver.find_element(:css, "login ui-link").click

  puts "Page title is #{driver.title}"
  
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  wait.until { driver.title.downcase.start_with? "department of veterans affairs" }
  
  puts "Page title is #{driver.title}"
  
  #Enter credentials/site
  element = driver.find_element(:id, "name-c").send_keys "zztest.staff01"
  element = driver.find_element(:id, "password").send_keys "pass"
  #Enter DC
  element = driver.find_element(:css, "input.ui-input-text.ui-body-d").send_keys "dc"
  #Click the location popup
  element = driver.find_element(:css, "a[data-facility-name='DC VAMC']").click

  #Submit
  element = driver.find_element(:id, 'loginButton').click
  
#end

wait = Selenium::WebDriver::Wait.new(:timeout => 500)
wait.until { driver.title.downcase.start_with? "portal" }

puts "Page title is #{driver.title}"
#element = driver.find_element(:id, "user-context")
#puts "User context is #{driver.find_element(:id, "user-context")}"

wait = Selenium::WebDriver::Wait.new(:timeout => 500)
element = wait.until { driver.execute_script("return document.readyState") === 'complete' }
puts "After ready state"

sleep(2);

element = driver.find_element(:id, 'messageButton').click

driver.quit
