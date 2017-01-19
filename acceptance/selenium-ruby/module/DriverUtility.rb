require 'active_support/time'
require 'rubygems'
require "json"
require 'selenium-webdriver'
require 'mysql'

module DriverUtility
  FIREFOX_PROFILE_PATH = File.expand_path('.') + "/firefoxProfile"

  DBPASSWORD = "Agilexadmin99$"
  USER = "root"
  SCHEMA = "HADB"
  AUTHSCHEMA = "AUTHDB"
  MOCKSCHEMA = "MOCKDB"


  def initializeConfigurations(base_url)

    profile = Selenium::WebDriver::Firefox::Profile.new(FIREFOX_PROFILE_PATH)
    @driver = Selenium::WebDriver.for :firefox, :profile => profile
    @driver.manage.window.maximize
    @driver.manage.delete_all_cookies

    # @driver.manage.timeouts.implicit_wait = 5
    # @driver.manage.timeouts.script_timeout = 15
    # @driver.manage.timeouts.page_load = 15

    #Selenium IDE put in a slash at end of base_url which caused bad url's below
    @driver.get(base_url + "/")

    @accept_next_alert = true
    @verification_errors = []
    sleep(5)
    ##For Demo below
    # last_picture = @driver.find_elements(:css, '.item.app.isotope-item.ui-link:nth-of-type(21)').last
    # last_picture.location_once_scrolled_into_view
    # sleep(5)
    # click('css', '.item.app.isotope-item.ui-link:nth-of-type(20)')
    end

  def quitDriver()
    @driver.quit
    #    puts "driver.quit is called"
    expect(@verification_errors).to eq([])
  end

  def switch_to_alert_accept
  @driver.switch_to.alert.accept
  end

  def getMainHeader()
    return getTextForElement(:css, ".main-title[aria-hidden]")
  end

  def getPrimaryHeader()
    return getTextForElement(:css, "div.primary-header h2")
  end

  def getSecondaryHeader()
    return getTextForElement(:css, "div.secondary-header h2")
  end

  def getMBBHeader()
    return getTextForElement(:css, "div>section>h2")
  end

  def gotoHome(baseUrl)
    @driver.get(baseUrl + "/")
  end

  def gotoLaunchpad()
    @driver.get("http://localhost:8080/launchpad")
  end

  def getRequiredFieldInfoText()
    return getTextForElement(:css,  "span[required-field]")
  end

  def switchWindowToWindowHandleLast()
    @driver.switch_to.window @driver.window_handles.last
  end

  def switchWindowToWindowHandleFirst()
    @driver.switch_to.window @driver.window_handles.first
  end

  def getTotalWindowsOpen()
    return @driver.window_handles.length
  end

  def getActiveElement()
    return @driver.switch_to.active_element()
  end

  def getFocusedElementText()
    element = getActiveElement()
    return element.text
  end

  def getFocusedElementName()
    element = getActiveElement()
    return element.attribute("name")
  end

  def getWindowSize()
    return @driver.manage.window.size
  end

  def resizeWindowTo(width, height)
    @driver.manage.window.resize_to(width, height)
    sleep 0.5
  end

  def resizeWindowToPhone()
    resizeWindowTo(320, 480)
  end

  def resizeWindowToDefault()
    resizeWindowTo(1260, 727)
    sleep 0.5
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

  def getSelectedOptionValue(how, what)
    select = Selenium::WebDriver::Support::Select.new(@driver.find_element(how,  what))
    option = select.first_selected_option
    return option.attribute('value')
  end

  def getTextForElement(pId)
    element = @driver.find_element(:id, pId)
    #puts "Element Text is : " + element.text
    return element.text.strip
  end

  def getTextForElement(how, what)
    begin
      element = getElement(how, what)
      return element.text.strip
    rescue Exception => e
      return ""
    end


    # element = nil
    # i = 0
    # begin
    #   elements = getElements(how, what)
    #   return elements.length == 0 ? nil : elements[0].text.strip
    # rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
    #   i = i + 1
    #   retry if i < 3
    # end
    # # puts "Element Text is : " + element.text
  end

  # grabs text of descendent elements too (strips html tags)
  def getTextContentForElement(how, what)
    element = @driver.find_element(how, what)
    return element.attribute('textContent').strip
  end

  def getTextFromInput(how, what)
    element = @driver.find_element(how, what)
    #puts "Element Text is : " + element.text
    return element.attribute("value")
  end

  def getTextsForElements(how, what)
    elements = @driver.find_elements(how, what)
    texts = []
    for item in elements
      texts << item.text.strip
    end

    return texts
  end

  # def click(how, what)
  #   #how  (:class, :class_name, :id, :link_text, :link, :partial_link_text, :name, :tag_name, :xpath)
  #   #what (String)
  #   @driver.find_element(how, what).click
  # end

  def clickJquery(what)
    puts "first what: "
    puts what
    methodname = what[/'(.*)'/, 1]
    puts "first methodname: "
    puts methodname
    what = what.gsub("'", %q(\\\'))
    puts "second what: "
    puts what
    @driver.execute_script("$('" + what + "').scope()." + methodname)
  end

  def clickJqueryEvent(what)
    @driver.execute_script("$('" + what + "').click()")
  end

  def clickRowJquery(what)
    if what == "#logout"
      @driver.execute_script("$('#logout').scope().openLink($('#logout').scope().item.link)")
    else
      what = what.gsub("'", %q(\\\'))
      puts "first what: "
      puts what
      @driver.execute_script("$('" + what + "').scope().onItemClick({item : $('" + what + "').scope().item })")
    end
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
    begin
      element = @driver.find_element(:id, pId)
      return element.displayed?
    rescue Exception=>e
      return false
    end
  end

  def isElementDisappeared(how, what)
    return @driver.find_elements(how, what).size == 0
  end

  def isElementVisible(how, what)
    begin
      element = @driver.find_element(how, what)
      #puts "DEBUG DriverUtility.isElementVisible: element found [#{what}]"
      #puts "DEBUG DriverUtility.isElementVisible: is displayed? [#{element.displayed?}]"
      return element.displayed?
    rescue Exception=>e
      #puts "DEBUG DriverUtility.isElementVisible: element not found [#{what}]"
      return false
    end
  end

  def isElementEnabled?(how, what)
    element = @driver.find_element(how, what)
    #puts 'isElementEnabled? ' + element.enabled?.to_s
    return element.enabled?
  end

  def isElementPresentAndVisible(how, what)
    isDisplayed = false
    begin
      element = getElement(how, what)
      if(element.displayed?)
        isDisplayed = true
      end
    rescue Exception => e
      return false
    end

    return isDisplayed
  end

  def isThisElementDisabled(selectorName, selectorPath)
    #selectorName: :id, :css, :class, :name
    #selectorPath:  "dropdown", "select[name='dropdownform']"

    isItDisabled = false
    element = getElement(selectorName, selectorPath)
    if element.attribute("disabled") != nil then
      isItDisabled = true
    end

    return isItDisabled
  end

  def is_element_present(how, what)
    begin
      element = @driver.find_element(how, what)
      return true
    rescue Exception=>e
      return false
    end
  end

  def isFieldRequired(how, what)
    element = getElement(how, what)
    required = element.attribute("required")
    if required == "true"
      return true
    else
      return false
    end
end

  def executeJquery(jqueryStr)
    @driver.execute_script(jQuery(jqueryStr))
  end

  def executeJavaScript(javaScriptStr)
     @driver.execute_script(javaScriptStr)
  end

  #format="%b %d, %Y"  JAN 10, 2014
  #format="%m/%d/%Y"    01/10/2014
  def isDateFormatValid?(dateStr, formatStr)
    #puts "Date String is " + dateStr
    begin
      dateObj = DateTime.strptime(dateStr, format=formatStr)
      #puts "[isDateFormatValid?] Date is " + dateObj.to_s

      return true
    rescue Exception=>e
      return false
    end
  end

  def isTimeFormatValid?(timeStr, formatStr)
    #puts "Date String is " + dateStr
    begin
      time = DateTime.strptime(timeStr, format=formatStr)
      #puts "[isDateFormatValid?] Date is " + dateObj.to_s

      return true
    rescue Exception=>e
      return false
    end
  end

  #format=%Y-%m-%d"
  def getDateNthDaysAgo(numberOfDaysAgo, formatStr)
    dateNthDaysAgo = numberOfDaysAgo.day.ago.strftime(format=formatStr)

    return dateNthDaysAgo

  end

  def getDateNthDaysFromNow(numberOfDaysFromNow, formatStr)
    dateNthDaysFromNow = numberOfDaysFromNow.day.from_now.strftime(format=formatStr)

    return dateNthDaysFromNow
  end

  def getDateNthMonthsFromNow(numberOfDaysFromNow, formatStr)
    dateNthDaysFromNow = numberOfDaysFromNow.month.from_now.strftime(format=formatStr)

    return dateNthDaysFromNow
  end

  def getDateNthDaysFromGivenDate(dateStr, nthDay)
    dateStrArray = dateStr.split("/")
    time = Time.parse(dateStrArray[2] + '-' + dateStrArray[0] + '-' + dateStrArray[1] + ' 09:00 AM')
    nthDaysLater = time + nthDay.day

    return nthDaysLater.strftime("%m/%d/%Y")
  end

  #input date string format is "%m/%d/%Y"
  def convertDateByFormatStr(dateStr, format)
    dateStrArray = dateStr.split("/")
    time = Time.parse(dateStrArray[2] + '-' + dateStrArray[0] + '-' + dateStrArray[1] + ' 09:00 AM')
    return time.strftime(format)
  end

  def getDateNThYearFromGivenDate(dateStr, nthYear)
    dateStrArray = dateStr.split("/")
    time = Time.parse(dateStrArray[2] + '-' + dateStrArray[0] + '-' + dateStrArray[1] + ' 09:00 AM')
    nthYearLater = time + nthYear.year

    return nthYearLater.strftime("%m/%d/%Y")
  end

  def getDateNthYeasFromNow(numberOfYearsFromNow, formatStr)
    dateStr = numberOfYearsFromNow.year.from_now.strftime(format=formatStr)

    #puts ("[getDateNthYearsFromNow() ]" + dateStr)

    return dateStr
  end

  def getDateNthYearsAgo(numberOfYearsAgo, formatStr)
    dateNthYearsAgo = numberOfYearsAgo.year.ago.strftime(format=formatStr)

    return dateNthYearsAgo
  end

  def getDayofWeek(dateStr)
    dateStrArray = dateStr.split("/")
    time = Time.parse(dateStrArray[2] + '-' + dateStrArray[0] + '-' + dateStrArray[1] + ' 09:00 AM')
    puts "time=" + time.to_s
    time.strftime("%A")
  end

  def get_auth_token(patientID)
    con = Mysql.new('localhost', USER, DBPASSWORD, AUTHSCHEMA)
    rs = con.query('select token from oauth_access_token where user_name="' + patientID + '"')
    if !rs.nil?
      while row = rs.fetch_hash do
        authtoken = row["token"].to_s.split(//).last(45).join("").to_s
        return authtoken
        con.close
      end
    end
    con.close
  end

  def getPatientDOB(uniqueId)
    con = Mysql.new('localhost', USER, DBPASSWORD, MOCKSCHEMA)
    queryStr = 'SELECT MOCK_DOB FROM MOCKDB.MOCK_USERS where UNIQUE_ID= "'+uniqueId+'"'
    # puts queryStr
    rs = con.query(queryStr)
    if rs.nil? == false then
      #puts "Number of rows returned: " + rs.num_rows.to_s
      while row = rs.fetch_hash do
        return row["MOCK_DOB"].to_date.strftime("%m/%d/%Y").to_s
      end

    else
      puts "DOB IS NOT AVAILABLE FOR " + patientId
      return ""
    end
    con.close

  end

  def verifyAssessmentIsSavedAsDraft(patientId)
    assessmentRecordFound = false
    con = Mysql.new('localhost', USER, DBPASSWORD, SCHEMA)
    rs = con.query('select PATIENT_ID, IN_PROGRESS from ASSESSMENT_RESULT where PATIENT_ID="' + patientId + '"')
    if rs.nil? == false then
      #puts "Number of rows returned: " + rs.num_rows.to_s
      while row = rs.fetch_hash do
        if row["IN_PROGRESS"] == 1 then
          assessmentRecordFound = true
        end
      end

    else
      puts "No assessment was created by " + patientId
      assessmentRecordFound = false
    end

    con.close

    return assessmentRecordFound

  end

  def verifyAssessmentIsSubmitted(patientId)
    assessmentRecordFound = false
    con = Mysql.new('localhost', USER, DBPASSWORD, SCHEMA)
    rs = con.query('select PATIENT_ID, IN_PROGRESS from ASSESSMENT_RESULT where PATIENT_ID="' + patientId + '"')
    if rs.nil? == false then
      #puts "Number of rows returned: " + rs.num_rows.to_s
      while row = rs.fetch_hash do
        if row["IN_PROGRESS"] == 0 then
          assessmentRecordFound = true
        end
      end

    else
      puts "No assessment was created by " + patientId
      assessmentRecordFound = false
    end
    con.close

    return assessmentRecordFound

  end

  def verifyAllAssessmentInfoAreSaved(assessmentName, version, patientId, dateTaken)
    assessmentRecordComplete = false
    con = Mysql.new('localhost', USER, DBPASSWORD, SCHEMA)
    rs = con.query('select UNIQUE_TITLE, VERSION, PATIENT_ID, DATE_TAKEN, RESPONSES from ASSESSMENT_RESULT where PATIENT_ID="' + patientId + '"')
    if rs.nil? == false then
      #puts "Number of rows returned: " + rs.num_rows.to_s
      while row = rs.fetch_hash do
        if row["UNIQUE_TITLE"] == assessmentName || row["VERSION"] == version || row["PATIENT_ID"] == patientId || row["DATE_TAKEN"].include?(dateTaken) == true || row["VERSION"].include?("<?xml") == true then
          assessmentRecordComplete = true
        end
      end

    else
      puts "No assessment was created by " + patientId
        assessmentRecordComplete = false
    end
    con.close

  end

  def getAssessmentSubmissionDateTime(patientId)
    con = Mysql.new('localhost', USER, DBPASSWORD, SCHEMA)
    sleep 4
    rs = con.query('select DATE_TAKEN from ASSESSMENT_RESULT where PATIENT_ID="' + patientId + '"')
    sleep 4
    if rs.nil? == false then
      #puts "Number of rows returned: " + rs.num_rows.to_s
      while row = rs.fetch_hash do
        #puts row["DATE_TAKEN"]
        #puts row["DATE_TAKEN"].to_datetime
        #puts row["DATE_TAKEN"].to_datetime.strftime("%m/%d/%Y %H:%M:%S").to_s
        return row["DATE_TAKEN"].to_datetime.strftime("%m/%d/%Y %H:%M:%S").to_s
      end

    else
      puts "No assessment was created by " + patientId
      return ""
    end
    con.close

  end

  def deleteROAFromTable(patientId)
    con = Mysql.new('localhost', USER, DBPASSWORD, SCHEMA)
    rs = con.query('delete from USER_RIGHTOFACCESS where USER_ID="' + patientId + '"')
    con.close
    puts "Deleted ROA for UserID=" + patientId

  end

  def deleteDailyEventTable(patientId)
    con = Mysql.new('localhost', USER, DBPASSWORD, SCHEMA)
    rs = con.query('delete from Daily_Event where PATIENT_ID="' + patientId + '"')
    con.close
    puts "Deleted DailyEvent data for PatientId=" + patientId
  end

  def deleteCommunicationsTable(patientId)
    con = Mysql.new('localhost', USER, DBPASSWORD, SCHEMA)
    rs = con.query('delete from Communications where PATIENT_ID="' + patientId + '"')
    con.close
    puts "Deleted Communications Log data for PatientId=" + patientId
  end

  def deleteFromDietTable(patientId)
    con = Mysql.new('localhost', USER, DBPASSWORD, SCHEMA)
    rs = con.query('delete from DIET where PATIENT_ID="' + patientId + '"')
    con.close
    puts "Deleted the meal data for PatientId=" + patientId
  end

  def deleteRecordsFromTable(tableName, patientId)
    con = Mysql.new('localhost', USER, DBPASSWORD, SCHEMA)
    queryStr = "delete from " + tableName + " where PATIENT_ID='" + patientId + "'"
    #puts queryStr
    rs = con.query(queryStr)
    con.close
    puts "Deleted the " + tableName + " data for PatientId=" + patientId
  end

  def deleteAllRecordsFromTable(tableName)
    con = Mysql.new('localhost', USER, DBPASSWORD, SCHEMA)
    queryStr = "delete from " + tableName
    con.query(queryStr)
    con.close
    puts "Truncated the " + tableName + "table"
  end

  def deleteAssessmentResultsTable(patientId)
    con = Mysql.new('localhost', USER, DBPASSWORD, SCHEMA)
    rs = con.query('delete from ASSESSMENT_RESULT where PATIENT_ID="' + patientId + '"')
    con.close
    puts "Deleted Assessment Results data for PatientId=" + patientId
  end

  def deleteMoodTable(patientId)
    con = Mysql.new('localhost', USER, DBPASSWORD, SCHEMA)
    rs = con.query('delete from MOOD where PATIENT_ID="' + patientId + '"')
    con.close
    puts "Deleted Mood data for PatientId=" + patientId
  end

  def deletePainTable(patientId)
    con = Mysql.new('localhost', USER, DBPASSWORD, SCHEMA)
    rs = con.query('delete from VITAL_OBSERVATION')
    con.close
    puts "Deleted VITAL_OBSERVATION data"

    con = Mysql.new('localhost', USER, DBPASSWORD, SCHEMA)
    rs = con.query('delete from VITAL_ENTRY')
    con.close
    puts "Deleted VITAL_ENTRY data"

  end

  def updateLogTimeCommunicationsTable(patientId, subject, timeLog)
    con = Mysql.new('localhost', USER, DBPASSWORD, SCHEMA)
    rs = con.query('update Communications set LOG_TIME="' + timeLog + '" where PATIENT_ID="' + patientId + '" and subject="' + subject + '"')
    con.close
    puts "Updated Communications Log_Time data for PatientId=" + patientId  + "and subject = " + subject
  end

  def updateDailyEvent(patientId, title, timeLog)
    con = Mysql.new('localhost', USER, DBPASSWORD, SCHEMA)
    rs = con.query('update Daily_Event set Entry_Date="' + timeLog + '" where PATIENT_ID="' + patientId + '" and title="' + title + '"')
    con.close
    puts "Updated Daily_Event Event_Date data for PatientId=" + patientId  + "and title = " + title

  end

  def updateLogTimeMoodTable(patientId, note, mood, entry_date)
    con = Mysql.new('localhost', USER, DBPASSWORD, SCHEMA)
    rs = con.query('update MOOD set ENTRY_DATE="' + entry_date + '" where PATIENT_ID="' + patientId + '" and note="' + note + '" and mood="' + mood + '"')
    con.close
    puts "Updated Mood Entry_Date for PatientId=" + patientId  + "and mood = " + mood + " note =" + note
  end

  def updateEntryTimePainTable(patientId, notes, entry_date)
    con = Mysql.new('localhost', USER, DBPASSWORD, SCHEMA)
    rs = con.query('update VITAL_ENTRY set ENTRY_DATE="' + entry_date + '" where PATIENT_ID="' + patientId + '" and notes="' + notes + '"')
    con.close
    puts "Updated Pain Entry_Date for PatientId=" + patientId  + "and note =" + notes

  end

  def updateMockUsersTable(userId, maleOrFemale, newDob)
    con = Mysql.new('localhost', USER, DBPASSWORD, MOCKSCHEMA)
    if (maleOrFemale != "") and (newDob != "") then
      queryStr = 'update MOCK_USERS set MOCK_DOB="' + newDob + '", MOCK_GENDER="' + maleOrFemale + '" where MOCK_USER_ID=' + userId.to_s
      puts queryStr
    end

    rs = con.query(queryStr)
    con.close
    #puts "Updated Mock_Patients table for PatientId=" + patientId.to_s

  end

  def clickBackButtonOnBrowser()
    @driver.goBack()
  end

  def clickBackButtonOnBrowser()
    @driver.navigate.back()
  end

  def refreshBrowser()
    @driver.navigate().refresh()
  end

  def moveArrowInputRangeToRight(inputName, numberOfArrowMove)
    @driver.find_element(:css, "input[name=" + inputName + "]").send_keys :tab
    sleep 1
    for i in 1..numberOfArrowMove
      @driver.find_element(:css, "input[name=" + inputName + "]").send_keys :arrow_right
      sleep 1
    end
  end

  def moveArrowInputRangeToLeft(inputName, numberOfArrowMove)
    @driver.find_element(:css, "input[name=" + inputName + "]").send_keys :tab
    sleep 1
    for i in 1..numberOfArrowMove
      @driver.find_element(:css, "input[name=" + inputName + "]").send_keys :arrow_left
      sleep 1
    end
  end

  def getInputRangeValue(inputName)
    element = @driver.find_element(:css, "input[name=" + inputName + "]")
    return element.attribute("aria-valuetext").strip
  end

  def setDateAndTime(dateStr, timeStr, dateCssPath, timeCssPath)
    sleep 1
    setDate(dateStr, dateCssPath)
    sleep 0.5
    setTime(timeStr, timeCssPath)
    sleep 0.5
  end

  def setDate(dateStr, cssPath)
    #cssPath could be e.g. "input[name='date']"
    sleep 1
    @driver.find_element(:css, cssPath).clear
    @driver.find_element(:css, cssPath).send_keys(dateStr)
    sleep 2
  end

  def setTime(timeStr, cssPath)
    ##cssPath could be e.g. "input[name='time']"
    time = Time.parse(timeStr);
    elem = @driver.find_element(:css, cssPath)
    elem.clear
    sleep 1
    elem.send_keys(time.strftime("%I"))
    elem.send_keys [:shift, ";"]
    elem.send_keys(time.strftime("%M %p"))
    sleep 1

  end

  def clearDateOrTime(cssPath)
    @driver.find_element(:css, cssPath).clear
  end

  def getPlaceHolder(id)
    element = getElement(:id, id)
    return element.attribute('placeholder')
  end

  def getPlaceHolderByCSS(how, where)
    element = getElement(how, where)
    return element.attribute('placeholder')
  end

  def addJournalLaunchpadItemToDatabase()
    con = Mysql.new('localhost', USER, DBPASSWORD, SCHEMA)
    rs = con.query('SELECT * FROM LAUNCHPAD_ITEM WHERE NAME="My VA Health"')
    entry = rs.fetch_hash
    if entry != nil then
      con.query('UPDATE LAUNCHPAD_ITEM set URL="/my-va-health" WHERE NAME="My VA Health"')
    else
      con.query('INSERT INTO LAUNCHPAD_ITEM (NAME, ITEM_MODE, TYPE, ITEM_POSITION, DESCRIPTION, URL, IMAGE_URL) VALUES ("My VA Health", "VETERAN", "APP", "14", "Track and share health and healthcare information.", "/my-va-health", "img/app-icons/journal/apple-touch-icon-72x72-precomposed.png")')
    end
    con.close
    puts "Added My-VA-Health to LaunchPadItems"
  end

  def selectTimeZone(timeZone)
    #puts "Time Zone is " + timeZone
    sleep(5)

    @driver.execute_script("$('[name=timeZone]').scope().preferences.timeZone = \"" + timeZone + "\"")
    @driver.execute_script("$('[name=timeZone]').scope().$digest()")
  end

  def byPassTheNotificationSettingsScreen()
    #Select a Timezone from the drop down
    selectTimeZone("(-05:00) America/New_York (Eastern)")
    sleep(5)
    @driver.execute_script("$('button[ng-click=\"save()\"]').scope().save()")
  end

  def setNarrative(text)
    @driver.find_element(:css, "textarea[name='Note']").clear
    sleep 1
    @driver.find_element(:css, "textarea[name='Note']").send_keys(text)
  end

  def verifyTotalCharacterInNarrative()
    boundaryTest = false
    part1 = "VerifyTheTotalAllowedCharactersInNarrativeField001"
    part2 = "VerifyTheTotalAllowedCharactersInNarrativeField002"
    part3 = "VerifyTheTotalAllowedCharactersInNarrativeField003"
    part4 = "VerifyTheTotalAllowedCharactersInNarrativeField004"
    part5 = "VerifyTheTotalAllowedCharactersInNarrativeField005"
    typeInText = part1 + part2 + part3 + part4 + part5

    setNarrative(typeInText)
    sleep 1

    counterText = getTextForElement(:css, "span[ng-if='characterCounter']")
    if counterText == "0 characters left"
      boundaryTest = true
    else
      boundaryTest = false
    end

    return boundaryTest
  end

  def isThisRadioButtonOrCheckBoxSelected(type, value, radioButtonName)
    element = getElement(:css, "input[name='" + radioButtonName + "'][type='" + type + "'][value='" + value +"']")
    #puts "[isThisRadioButtonOrCheckBoxSelected] Value " + value + " - " + element.selected?.to_s
    return element.selected?
  end

  def areAllTheseValuesAvailableInDropDown(cssPath, valueString)
    verifiedTrue = true
    select = getElement(:css, cssPath)
    options = select.find_elements(:tag_name, "option")
    options.each do |option|
      displayedValue = option.attribute('value')
      if displayedValue == nil then
        displayedValue = "Select"
      end

      if valueString.include?(displayedValue) == false then
        verifiedTrue = false
        break
      end
    end

    return verifiedTrue
  end
     
  
  def helper_instsertCommunicationsLogEntryToTable(id, patientId, entryDate, entryContactType, entrySubject, entryContact, entryNotes)
    con = Mysql.new('localhost', USER, DBPASSWORD, SCHEMA)
    
    #entryDate is in format mm/dd/YYYY 
    entryDate2 = entryDate[6,4] + "/" + entryDate[0,2] + "/" + entryDate[3,2] 
    #DELETE * FROM FROM `HADB`.`COMMUNICATIONS` WHERE PATIENT_ID = "D123401";
    #puts("entryDate= [#{entryDate2}]")
    insertQuery = 'INSERT INTO Communications (ID, PATIENT_ID, LOG_TIME, CONTACT, CONTACT_TYPE, SUBJECT, NOTE) VALUES ("' + id + '", "' + patientId + '", "' + entryDate2 + '", "' + entryContact + '", "' + entryContactType + '", "' + entrySubject + '", "' + entryNotes + '")' 
    #puts"Inserting query\n[" + insertQuery  + "]"
    con.query(insertQuery)
    con.close
    puts "Done Inserting data dated [#{entryDate2}] for PatientId=[" + patientId  + "], subject=[" + entrySubject + "]"
  end

  ##SHEERI DID IT!!!

  def numeric?(string)
    Float(string) != nil rescue false
  end

  def getFieldType(fieldName)
    field = getField(fieldName)
    type = field.tag_name

    if(type == "input")
      type = field.attribute("type")
    end

    return type
  end

  def getField(fieldName)
    return getElement(:css, "input[name='" + fieldName + "'], textarea[name='" + fieldName + "'], select[name='" + fieldName + "']")
  end

  def clearField(fieldName)
    case getFieldType(fieldName)
      when "checkbox", "radio"
        puts "TODO"
      when "select"
        setSelectField(fieldName, "")
      else
        getField(fieldName).clear
    end 

    sleep 0.5
  end

  def editField(fieldName, value)
    case getFieldType(fieldName)
      when  "radio", "checkbox"
        puts "TODO"
      when "file"
        addAttachment(fieldName, value)
      when "select"
        setSelectField(fieldName, value)
      when "range"
        setSliderField(fieldName, value)
      else
        setKeyboardField(fieldName, value)
    end
    sleep 0.5
  end

  def getLongFieldLabel(fieldName)
    return getTextForElement(:css, "[name='" + fieldName + "'] .input-label-content")
  end

  def getShortFieldLabel(fieldName, isRequired)
    return getTextForElement(:css, "[name='" + fieldName + "'] .input-label-content span:nth-of-type(" + (isRequired ? 2 : 1).to_s + ")")
  end

  def getValueInField(fieldName)
    return getField(fieldName).attribute("value")
  end

  def setEntryValues(entryMap)
    entryMap.each { | key, value |
      editField(key, value)
    }
  end

  def setKeyboardField(fieldName, value)
    field = getField(fieldName)
    field.clear
    field.send_keys(value.to_s)
    sleep 0.5
  end

  def setSelectField(fieldName, value)
    field = getField(fieldName)
    option = field.find_element(:css, "[value='" + value + "']")
    if option != nil
      select = Selenium::WebDriver::Support::Select.new(field)
      select.select_by(:value, value)
    end
  end

  def setSliderField(fieldName, value)
    field = getField(fieldName)
    field.send_keys :tab

    currentValue = field.attribute("value").to_f
    step = field.attribute("step").to_f

    numSteps = ((value - currentValue)/step).to_i

    # sleep 0.2

    direction = numSteps > 0 ? :arrow_right : :arrow_left

    numSteps = numSteps.abs

    for i in 1..numSteps
      field.send_keys direction
      sleep 0.2
    end

  end

  def addAttachment(fieldName, value)
    inputFile = getField(fieldName)
    inputFile.send_keys (File.dirname(__FILE__) + "/../resources/" + value)
  end

  def deleteAttachment(attachementNumber)
    attachmentDeleteButtons = getElements(:css, "[ng-click='deleteAttachment($index)']")
    attachmentDeleteButtons[attachementNumber - 1].click
  end

  def waitForPageToFinishLoading
    sleep 1
    !45.times{ break if (isElementVisible(:css, ".content-loaded") == true); sleep 0.5 }
    sleep(1)
  end

  def waitforCssAttributeToLoad(cssAttribute)
    sleep 1
    !45.times{ break if (isElementVisible(:css, cssAttribute) == true); sleep 0.5 }
  end

  # def waitForIt(functionToCheck, valueToExpect)
  #   methodPointer = method(waitFor)
  #   !45.times{ break if methodPointer.call() == valueToExpect sleep 0.2;}
  #   return methodPointer.call() == valueToExpect
  # end

  def setDefaultROAForPatient(patientId)
    con = Mysql.new('localhost', USER, DBPASSWORD, SCHEMA)
    rs = con.query('SELECT * FROM USER_RIGHTOFACCESS WHERE USER_ID="' + patientId + '"')
    entry = rs.fetch_hash
    if entry == nil then
      con.query('INSERT INTO USER_RIGHTOFACCESS (USER_ID, ROA_STATE, ROA_DATE, ROA_FORM) VALUES ("' + patientId + '", "1", "2014-09-18 18:59:59", "empty")')
    end
    con.close
    puts "Updated ROA State"
  end

  def stripSelectTextFromScreen(mainList, selectFields)
    tmpList = mainList
    selectFields.each do |  f |
      tmpList = removeSubsetFromList( tmpList, getPulldownValues(f))
    end
    return tmpList
  end

  def getPulldownValues(fieldName)
    #puts "Type is [#{type}]"
    select = getElement(:css, "select[name='"+ fieldName + "']")
    options = select.find_elements(:tag_name, "option")
    values = []
    options.each_with_index do |e, i|
      #puts "Checking option <#{e.text}>"
      values << e.text
    end
    #puts "getPulldownValues=[#{values}]"
    return values
  end


  def removeSubsetFromList(mainList, subsetList)
    if subsetList.length == 0
      return mainList
    end
    startPos = mainList.index(subsetList[1])
    #puts "removeSubsetFromList startPos=[#{startPos}] [#{subsetList[1]}]"
    retArray = []
    if startPos == nil
      retArray = mainList
    else
      retArray = mainList[0..startPos-2]
      # retArray.each_with_index do | ee, j|
      #   puts "retArray(1)=[#{j}]  [#{ee}]"
      #end
      endPos = 0
      pos = startPos
      subsetList.each_with_index do |e, i|
        if i > 0
          #puts "comparing [#{i}] [#{e}] with  [#{mainList[startPos]}] startPos=[#{startPos}] endPos=[#{endPos}] pos=[#{pos}]"
          if e != mainList[pos]
            #puts "endPos = #{endPos}"
            break
          end
          pos = pos + 1
          endPos = endPos + 1
        end
      end
      endPos = endPos + startPos
      #puts "endPos=[#{endPos}] after loop"
      for i in endPos..(mainList.length-1)
        retArray << mainList[i]
      end
      #retArray.each_with_index do | ee, j|
      #   puts "retArray(2)=[#{j}]  [#{ee}]"
      #end
    end

    return retArray

  end

  def setPhoneInput(selector, text)
    elem = @driver.find_element(:css, selector)
    elem.click
    elem.clear
    elem.send_keys "\u0008"
    text.split("").each do |i|
      elem.send_keys i
    end
  end

  def getSelectBoxText(selector)
    select = Selenium::WebDriver::Support::Select.new(@driver.find_element(:css,  selector))
    return select.first_selected_option.text()
  end

  def setInput(selector, value)
    @driver.find_element(:css, selector).clear;
    @driver.find_element(:css, selector).send_keys(value);
  end

  def setSelectBoxValue(selector, value)
    selector = selector.gsub("'", %q(\\\'))
    @driver.execute_script("$('" + selector + "').scope().ngModel = '" + value + "'")
    @driver.execute_script("$('" + selector + "').scope().$digest()")
  end

  def setEmptyCountryBoxValue(selector, value)
    selector = selector.gsub("'", %q(\\\'))
    @driver.execute_script("$('" + selector + "').scope().details.address = {}")
    @driver.execute_script("$('" + selector + "').scope().details.address.country = '" + value + "'")
    @driver.execute_script("$('" + selector + "').scope().$digest()")
  end

  def formatTimeAMPM(t)
    return t.strftime("%I:%M %P").upcase.gsub(/  /," ")
  end

  def formatFullDateTime(t)
    # dt = DateTime.parse(t.to_s())
    ## The DateTime function was failing occasionally. There is a known bug with the rounding in new_offset.
    ## The below fix will only work if the tests are run in time zone EST
    t = Time.parse(t.to_s()).in_time_zone("Eastern Time (US & Canada)")
    # return dt.new_offset(DateTime.now.offset).strftime('%m/%d/%Y %I:%M %p')
    return t.strftime("%m/%d/%Y %I:%M %p")
  end

  def getTodayInZeroTimeUTC
    # Get current time into array
    # format is [sec,min,hour,day,month,year,wday,yday,isdst,zone]
    a = Time.now.utc.to_a
    # Zero out sec, min, hrs positions
    a[0] = 0
    a[1] = 0
    a[2] = 0
    # Convert it to date
    return Time.utc(*a)
  end

  def getTodayInZeroTime
    # Get current time into array
    # format is [sec,min,hour,day,month,year,wday,yday,isdst,zone]
    a = Time.now.to_a
    # Zero out sec, min, hrs positions
    a[0] = 0
    a[1] = 0
    a[2] = 0
    # Convert it to date
    return Time.local(*a)
  end


  def addDays(t, d)
    # Convert days into seconds and add it to date
    return t+(d*86400)
  end


  def getElementColor(selector, cssvalue)
    rgb = getElement(:css, selector).css_value(cssvalue).gsub(/rgba\(/,"").gsub(/\)/,"").split(",")
    color = '#%02x%02x%02x' % [rgb[0], rgb[1], rgb[2]]
    return color.upcase
  end

  def getElementAttribute(csspath, attributeKey)
    element = @driver.find_element(:css, csspath)
    return element.attribute(attributeKey)

  end

  def dropdownOption(tagname, css, text)
    dropdown_list = @driver.find_element(:css, css)
    options = dropdown_list.find_elements(:tag_name, tagname)
    options.each { |option| option.click if option.text == text }
    selected_option = options.map { |option| option.text if option.selected? }.join
    expect(selected_option.text).to eql text
  end
end
