require 'rubygems'
require 'selenium-webdriver'

driver = Selenium::WebDriver.for :chrome
driver.manage.timeouts.implicit_wait = 3 # seconds

describe 'Provider Portal Menu Sort PP-7'

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
   
wait.until { driver.title.downcase.start_with? "portal" }
puts "Page title is #{driver.title}"
   
sleep(2)
element = driver.find_element(:css, "li.ui-btn:nth-child(1) a").text.include? "Home"
$firstApplet = driver.find_element(:css, "li.ui-btn:nth-child(1) a").text
puts "First applet on list is #$firstApplet"

#Click A to Z sort button
element = driver.find_element(:css, "#portal-nav-alphabetical-btn").click

element = driver.find_element(:css, "li.ui-btn:nth-child(1) a").text.include? "Anti"
$firstApplet = driver.find_element(:css, "li.ui-btn:nth-child(1) a").text
puts "First applet on list is #$firstApplet"

