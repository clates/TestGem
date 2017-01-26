class PortalSearch
  def initialize driver, baseUrl
    # To change this template use File | Settings | File Templates.  def initialize driver, baseUrl
    @driver = driver
    @base_url = baseUrl
  end

  def clickSearch
    searchBtn = @driver.find_element(:id, search)
    searchBtn.click
  end
  
end