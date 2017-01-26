#require './pages/portal'
class PortalLogin
  def initialize driver, baseUrl
    @driver = driver
    @base_url = baseUrl
  end

  def loginAsStaff01(name, password, facility)
    #need to check login status, or just logout...

    @driver.get(@base_url + "/portal")

    #click login button
    @driver.find_element(:css, "login ui-link").click

    #Enter credentials/site
    @driver.find_element(:id, "name-c").send_keys name
    @driver.find_element(:id, "password").send_keys password
    #Enter DC
    @driver.find_element(:css, "input.ui-input-text.ui-body-d").send_keys facility
    #Click the location popup
    @driver.find_element(:xpath, "//a[@data-facility-name='DC VAMC']").click

    #Submit
    @driver.find_element(:name, 'loginButton').click

    return @driver, @base_url
  end
  
end
