require 'applet-test-helpers/utilities/general-utility'

class PatientInfo
  def initialize()
    @driver = GeneralUtility.driver    
  end
  
  def getPopupTitle
    return @driver.find_element(:css, "#subject-info-window h3.ui-title").text
  end
  
  ###############################
  #Methods to get value of fields
  ###############################

  def getLocationId
    return @driver.find_element(:xpath, "//div[@id='subject-info-window']/ul/li[3]/span[2]").text
  end
  
  def getLocationName
    return @driver.find_element(:xpath, "//div[@id='subject-info-window']/ul/li[4]/span[2]").text
  end
  
  def getRoomBed
    return @driver.find_element(:xpath, "//div[@id='subject-info-window']/ul/li[5]/span[2]").text
  end
  
  def getCwad
    return @driver.find_element(:xpath, "//div[@id='subject-info-window']/ul/li[6]/span[2]").text
  end
  
  def getServiceConnected
    return @driver.find_element(:xpath, "//div[@id='subject-info-window']/ul/li[7]/span[2]").text
  end
  
  def getServiceConnectedPercent
    return @driver.find_element(:xpath, "//div[@id='subject-info-window']/ul/li[8]/span[2]").text
  end
  
  def getSensitive
    return @driver.find_element(:xpath, "//div[@id='subject-info-window']/ul/li[9]/span[2]").text
  end
  
  def getAdmitted
    return @driver.find_element(:xpath, "//div[@id='subject-info-window']/ul/li[10]/span[2]").text
  end
  
  def getInternalControlNumber
    return @driver.find_element(:xpath, "//div[@id='subject-info-window']/ul/li[11]/span[2]").text
  end
  
  def closePopup
    @driver.find_element(:xpath, "//div[@id='subject-info-window']/a/span/span[2]").click
  end
  
  
  ###############################
  #Methods to get labels of fields
  ###############################

  def getLabelLocationId
    return @driver.find_element(:xpath, "//div[@id='subject-info-window']/ul/li[3]/span").text
  end

  def getLabelLocationName
    return @driver.find_element(:xpath, "//div[@id='subject-info-window']/ul/li[4]/span").text
  end

  def getLabelRoomBed
    return @driver.find_element(:xpath, "//div[@id='subject-info-window']/ul/li[5]/span").text
  end

  def getLabelCwad
    return @driver.find_element(:xpath, "//div[@id='subject-info-window']/ul/li[6]/span").text
  end

  def getLabelServiceConnected
    return @driver.find_element(:xpath, "//div[@id='subject-info-window']/ul/li[7]/span").text
  end

  def getLabelServiceConnectedPercent
    return @driver.find_element(:xpath, "//div[@id='subject-info-window']/ul/li[8]/span").text
  end

  def getLabelSensitive
    return @driver.find_element(:xpath, "//div[@id='subject-info-window']/ul/li[9]/span").text
  end

  def getLabelAdmitted
    return @driver.find_element(:xpath, "//div[@id='subject-info-window']/ul/li[10]/span").text
  end

  def getLabelInternalControlNumber
    return @driver.find_element(:xpath, "//div[@id='subject-info-window']/ul/li[11]/span").text
  end
  
  
end