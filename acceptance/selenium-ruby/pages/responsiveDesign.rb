require 'applet-test-helpers/utilities/general-utility'
require 'applet-test-helpers/utilities/element-utility'

class ResponsiveDesign    


  def initialize
    @driver = GeneralUtility.driver
    @wait = GeneralUtility.wait
    @eu = ElementUtility.new
  end

  def sectionListDisplay()
    @wait.until{@eu.element_present?(:css, "#portal-container .content-filters" )}
    return @driver.find_element(:css, "#portal-container .content-filters" ).displayed?
  end

  def sectionDetailDisplay()
    @wait.until{@eu.element_present?(:css, "#portal-container .content-details")}
    return @driver.find_element(:css, "#portal-container .content-details" ).displayed?
  end

  def clickBackButton()
    @wait.until{ @driver.find_element(:css, "#responsive-btn").displayed?}
    @driver.find_element(:css, "#responsive-btn").click
  end


  def backButtonDisplayed()
    return @driver.find_element(:css, "#responsive-btn").displayed?
  end

  def fullScreenButtonDisplayed()
    @wait.until{ @driver.find_element(:css, "#responsive-fullscreen-btn a") }
    @eu.is_visible_by?(:css, "#responsive-fullscreen-btn a")
  end

  def getWindowWidth()
    window_size = @driver.manage.window.size
    window_width = window_size.width()
   # puts window_width
    return window_width
  end

  def phoneView()
    currentWindowWidth = getWindowWidth()
    if currentWindowWidth <= 768
      return true
    else
      return false
    end
  end

  def desktopView()
    currentWindowWidth = getWindowWidth()
    if currentWindowWidth > 768
      return true
    else
      return false
    end
  end

end

