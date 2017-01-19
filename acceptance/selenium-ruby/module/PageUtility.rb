#Implemented from nursing --DriverUtility module and added more methods

require_relative "../pages/_config"
require 'fileutils'


module PageUtility

  ############################################

  def initializeTestConfigurations()
    @driver = Selenium::WebDriver.for :firefox
    @base_url = $acp_url
    @wrapper_url = $acp_url + "/" + $acp_app
    @wait = Selenium::WebDriver::Wait.new(:timeout => 30)
    @accept_next_alert = true
    @driver.manage.timeouts.implicit_wait = 3
    @verification_errors = []
    @driver.manage().window().maximize()
  end

  def initializeAbsPathConfigurations(app_path)
    file = File.join("", app_path)
    raise "App doesn't exist #{file}" unless File.exist? file
    file
  end

  def initializeWebSimulatorConfigurations(server_url)
    capabilities = {
        'device' => 'iPad Simulator',
        'browserName' => 'safari',
        'javascript_enabled' => 'true'
    }
    @wait = Selenium::WebDriver::Wait.new(:timeout => 80)
    @driver = Selenium::WebDriver.for(:remote, :desired_capabilities => capabilities, :url => server_url)
    @accept_next_alert = true
    @driver.manage.timeouts.implicit_wait = 45
    @verification_errors = []
  end

  ######################## app ####################

  def initializeAppSimulatorConfigurations(app_path, server_url)
    capabilities = {
        'device' => 'iPad Simulator',
        'browserName' => '',
        'platform' => 'Mac',
        'version' => '7.1',
        'app' => initializeAbsPathConfigurations(app_path),
        'javascript_enabled' => 'true'
    }
    @wait = Selenium::WebDriver::Wait.new(:timeout => 80)
    @driver = Selenium::WebDriver.for(:remote, :desired_capabilities => capabilities, :url => server_url)
    @accept_next_alert = true
    @driver.manage.timeouts.implicit_wait = 45
    @verification_errors = []
  end

  def verifySUD()
    !5.times{
      if (element_present?(:id, "portal-staff-user-disclaimer"))
        @driver.find_element(:id, "accept-btn").click()
        break
      end
      sleep 1
    }
  end


  ######################

  def quitDriver()
    @driver.quit
    @verification_errors.should == []
  end

  def gotoHome(baseUrl)
    @driver.get(baseUrl + "/")
  end

  def switchWindowToWindowHandleLast()
    @driver.window_handles.last
  end

  ############# added by sarita
  def resizeNewWindow(width, height)
    handles = driver.window_handles
    @driver.execute_script("window.open('about:blank','_blank','width=#{width},height=#{height}');")
    @driver.switch_to.window((driver.window_handles - handles).pop)
    @driver.execute_script("window.resizeTo(#{width}, #{height}); window.moveTo(0,1);")
  end

  def resizeWindow(width, height)
    @driver.manage.window.move_to(300, 400)
    @driver.manage.window.resize_to(768, 800)
  end

  def creatDir(dirPath)
    if File.exists?(dirPath)
       FileUtils.rm_r(dirPath)
    end
      Dir.mkdir(dirPath)
  end

  def takeScreenShot(name)
      @time = Time.new
      @driver.save_screenshot('./screenshot/' +name+ @time.inspect + '.png')
  end

  def switchWindowToWindowHandleWebviewLast(webview)
    webview = @driver.window_handles.last
    @driver.switch_to.window(webview)
  end

  def switchWindowToWindowHandleFirst()
    @driver.switch_to.window @driver.window_handles.first
  end

  def closeBrowser()
    @driver.close()
  end

  def getCurrentURL()
    return @driver.current_url
  end

  def getPageTitle()
    wait = Selenium::WebDriver::Wait.new(:timeout => 10)
    wait.until {@driver.title}
    return @driver.title
  end

  def deleteAllCookies()
    @driver.manage.delete_all_cookies
  end

  def getTextForElement(pId)
    element = @driver.find_element(:id, pId)
    #puts "Element Text is : " + element.text
    return element.text.strip
  end

  def getTextForElement(how, what)
    element = @driver.find_element(how, what)
    #puts "Element Text is : " + element.text
    return element.text.strip
  end

  def getTextsForElements(how, what)
    elements = @driver.find_elements(how, what)
    texts = []
    for i in 1..elements.length
      element = elements[i]
      texts[i] = element.text.strip
    end
    return texts
  end

  def click(how, what)
    #how  (:class, :class_name, :id, :link_text, :link, :partial_link_text, :name, :tag_name, :xpath)
    #what (String)
    @driver.find_element(how, what).click
  end

  def getElement(how, what)
    element = @driver.find_element(how, what)
    return element
  end

  def getElements(how, what)
    #how  (:class, :class_name, :id, :link_text, :link, :partial_link_text, :name, :tag_name, :xpath)
    #what (String)
    elements = []
    elements = @driver.find_elements(how, what)
    return elements
  end

  def isElementVisible(pId)
    element = @driver.find_element(:id, pId)
    return element.displayed?
  end

  
=begin
def isElementVisible(how, what)
    element = (@driver.find_element(how, what)).displayed?
   # return element.displayed?
  end
=end

  def isElementEnabled?(how, what)
    element = @driver.find_element(how, what)
    #puts 'isElementEnabled? ' + element.enabled?.to_s
    return element.enabled?
  end

  
  def isElementVisible(how, what)
    begin
      element = (@driver.find_element(how, what)).displayed?
      # return element.displayed?
          return true
        rescue Exception=>e
          return false
    end
  end
  
  def is_element_present(how, what)
    begin
      element = @driver.find_element(how, what)
      return true
    rescue Exception=>e
      return false
    end
  end

#############
  def waitUntilElementFound(how, what, count)
    !count.times{ break if (is_element_present(how, what)); sleep 1 }
  end


  def waitUntilElementVisible(how, what, count)
    !count.times{ break if (isElementVisible(how, what)); sleep 1 }
  end



  
  
#############


  def scroll_to_element(scrollableSelector, elementSelector, offset = 0)
    scrollable = '$("' + scrollableSelector + '")'
    element = '$("' + elementSelector + '")'
    @driver.execute_script( scrollable + '.scrollTop(' + element + '.offset().top - ' + scrollable + '.offset().top + ' + scrollable + '.scrollTop() + ' + offset.to_s + ');')
  end



  def clickBackButtonOnBrowser()
    @driver.navigate.back()
  end

  def multiAttempt
    i=0
    puts "multiAttempt"
    45.times do
      begin
        yield
        break
      rescue
        pause 1.0
        i=i+1
        puts "multiAttempt failed Iteration=[#{i}]"
      end
    end

    yield if i == 45;
  end

  end
