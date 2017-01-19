require 'rspec'
require 'json'
require 'selenium-webdriver'
require 'rubygems'

require_relative "./DriverUtility"
require_relative "../spec/rspec_helper"
require_relative "../pages/common"
require_relative "../pages/date_filter"
require_relative "../helpers/entry_form"
require_relative "../pages/nav_menu"
require_relative "../pages/error_validation"
require_relative "../pages/modal_popup"
require_relative "../pages/personal_trackers"

module CommonTests
  include DriverUtility

  MAX_WAIT_LOOPS = 45
  WAIT_LOOP_SLEEP_TIME = 0.5

  def init(metaData)
    @nav_menu = Nav_menu.new(@driver)
    @modal = Modal_popup.new(@driver)
    @error = Error_Validation.new(@driver)
    @common = Common.new(@driver)
    @entry_form = EntryForm.new(@driver)
    @date_filter = Date_Filter.new(@driver)
    @personal_trackers = PersonalTrackers.new(@driver, metaData)


    @expectedHeaders = metaData["expectedHeaders"]
    @baseNav = metaData["baseNav"]
    @normalTableHeaders = metaData["normalOrderedColumnLabels"]
    @phoneTableHeaders = metaData["phoneOrderedColumnLabels"]
    @formName = metaData["formName"]

    @feature = @nav_menu.getParentNav(@baseNav)
    featureSections = @nav_menu.getAllSectionNav(@feature)
    featureSections.delete(@baseNav)

    @siblingSection = featureSections[0]

    features = @nav_menu.getAllFeatureNav()
    features.delete(@feature)

    @siblingFeature = features[0]

    @pdfInfo = metaData["pdf"]
    @graphInfo = metaData["graph"]

    @minTestDataDate = getDateNthDaysAgo(730, "%m/%d/%Y") #set it to two year ago
    @maxTestDataDate = getDateNthDaysAgo(0, "%m/%d/%Y")  #set it to Today
  end

  def navigationTests()
    @nav_menu.navigate(@baseNav)

    !MAX_WAIT_LOOPS.times { break if (getMainHeader() == @expectedHeaders["title"]); sleep WAIT_LOOP_SLEEP_TIME }

    expect(getMainHeader()).to eq(@expectedHeaders["title"])
    expect(getSecondaryHeader()).to eq(@expectedHeaders["secondary"])
    expect(getPrimaryHeader()).to eq(@expectedHeaders["summary"])
  end

  def tableHeaderTest(expectedNormalHeaders, expectedPhoneHeaders)
    @nav_menu.navigate(@baseNav)
    !5.times{ break if (getTextForRowColumn(1, 1) != nil); sleep 1 }

    tableHeaders = @personal_trackers.getTableHeaders()
    numColumns = expectedNormalHeaders.length
    for i in 0...numColumns
      puts tableHeaders[i]
      expect(tableHeaders[i]).to eq(expectedNormalHeaders[i])
    end

    resizeWindowToPhone()
    tableHeaders = @personal_trackers.getTableHeaders()

    numColumns = expectedPhoneHeaders.length
    for i in 0...numColumns
      expect(tableHeaders[i]).to eq(expectedPhoneHeaders[i])
    end

    resizeWindowToDefault()

  end

  def fieldLabelTests(fields)
    @nav_menu.navigate(@baseNav)

    @personal_trackers.clickAddEntryButton()
    waitForPageToFinishLoading()

    #Verifying Screen Headers
    expect(getSecondaryHeader()).to eq(@expectedHeaders["secondary"])
    expect(getPrimaryHeader()).to eq (@expectedHeaders["add"])

    fields.each do |key, value|

      expectValue = ""
      expectPlaceholder = nil
      if value["required"] == true
        expectValue = "* "
      end

      expectValue += value["label"]

      if value["min"] != nil && value["max"] != nil && value["type"] != "slider"
        expectPlaceholder = "Between " + value["min"] + " and " + value["max"]
        expectValue += "\n" + expectPlaceholder
      end

      expect(getLongFieldLabel(key)).to eq(expectValue)

      if value["type"] == "time"
        expectPlaceholder = "HH:MM AM/PM"
      elsif value["type"] == "date"
        expectPlaceholder = "MM/DD/YYYY"
      end

      if expectPlaceholder != nil
        expect(getPlaceHolderByCSS(:css, "input[name='" + key + "']")).to eq(expectPlaceholder)
      end
    end

    @entry_form.clickCancelButton()
    waitForPageToFinishLoading()
  end

  def fieldRestrictionTests(fields)
    @nav_menu.navigate(@baseNav)
    @personal_trackers.clickAddEntryButton()
    waitForPageToFinishLoading()

    expect(getPrimaryHeader()).to eq(@expectedHeaders["add"])

    fields.each do |key, value|

      if value["type"] == "date"
        expect(getValueInField(key)).to eq(getDateNthDaysAgo(0, "%m/%d/%Y"))
      end

      if value["type"] == "time"
        inputTime = Time.parse(getValueInField(key))
        now = Time.new()
        expect(inputTime <= (now + 300)).to eq(true)
        expect(inputTime >= (now - 300)).to eq(true)
      end

      if value["type"] == "select" && value["options"].find_index("") != nil
        expect(getValueInField(key)).to eq("")
      end

      if value["type"] == "slider" && value["min"] != nil && value["max"] != nil
        expect(value["min"]).to eq(getElement(:css, "input[type='range']").attribute("min"))
        expect(value["max"]).to eq(getElement(:css, "input[type='range']").attribute("max"))
      end

      if value["required"] == true && (value["type"] == "select" && value["options"].find_index("") != nil || value["type"] != "select")
        requiredFieldTest(key)
      end

      if (value["min"] != nil || value["max"] != nil) && value["type"] != "slider"
        boundaryTest(key, value["min"], value["max"], value["minDelta"])
      end

      if value["maxLength"]
        textareaMaxLengthTest(key, value["maxLength"], value["hasCounter"])
      end
    end

    #Click Cancel to exit
    @entry_form.clickCancelButton()
    waitForPageToFinishLoading()

  end

  def addTest(fields, addDataSet)
    @nav_menu.navigate(@baseNav)

    #Set the date range to 2 years back so all the entered data will show up
    @date_filter.setDateRangeAndFilter(@minTestDataDate, @maxTestDataDate)

    yesterday = getDateNthDaysAgo(1, "%m/%d/%Y")
    addDataSetTimes = [ "12:00 AM", "01:00 AM", "02:00 AM", "03:00 AM",
                        "04:00 AM", "05:00 AM", "06:00 AM", "07:00 AM",
                        "08:00 AM", "09:00 AM", "10:00 AM", "11:00 AM",
                        "12:00 PM", "01:00 PM", "02:00 PM", "03:00 PM",
                        "04:00 PM", "05:00 PM", "06:00 PM", "07:00 PM",
                        "08:00 PM", "09:00 PM", "10:00 PM", "11:00 PM",
    ]

    #test addings
    dataSetSize = addDataSet.length
    for i in 0...dataSetSize
      if(fields["date"] != nil)
        addDataSet[i]["date"] = yesterday
      end
      if(fields["time"] != nil)
        addDataSet[i]["time"] = addDataSetTimes[i]
      end
      if(fields["Note"] != nil)
        addDataSet[i]["Note"] = "Add Note " + i.to_s
      end
      addAndVerifyEntry(fields, addDataSet[i], 1)
    end
  end

  def editTest(fields, originalDataSet, editDataSet)
    @nav_menu.navigate(@baseNav)

    count = @personal_trackers.getCount() - 3
    !count.times{ deleteAndVerifyEntry(1) }

    editDataSetDates = [ getDateNthDaysAgo(30, "%m/%d/%Y"), getDateNthDaysAgo(10, "%m/%d/%Y"), getDateNthDaysAgo(2, "%m/%d/%Y") ]
    # editDataSetTimes = ["11:11 PM", "08:54 AM", "12:39 AM"]
    editDataSetTimes = ["11:11 PM", "10:10 PM", "09:09 PM", "08:08 PM",
                        "07:07 PM", "06:06 PM", "05:05 PM", "04:04 PM",
                        "03:03 PM", "02:02 PM", "01:01 PM", "12:12 PM",
                        "11:11 AM", "10:10 AM", "09:09 AM", "08:08 AM",
                        "07:07 AM", "06:06 AM", "05:05 AM", "04:04 AM",
                        "03:03 AM", "02:02 AM", "01:01 AM", "12:00 AM",
    ]

    expectedRowStrings = []
    dataSetSize = editDataSet.length
    for i in 0...3
      if(fields["date"] != nil)
        editDataSet[i]["date"] = editDataSetDates[i]
      end
      if(fields["time"] != nil)
        editDataSet[i]["time"] = editDataSetTimes[i]
      end
      if(fields["Note"] != nil)
        editDataSet[i]["Note"] = "Edit Note " + i.to_s
      end

      editAndVerifyEntry(fields, editDataSet[i], dataSetSize - i, dataSetSize - i)
      expectedRowStrings[i] = @personal_trackers.getTextForRow(dataSetSize - i)
    end

    return expectedRowStrings
  end

  def filterLabelsAndPlaceholdersTest()
    @nav_menu.navigate(@baseNav)

    expect(getPrimaryHeader()).to eq (@expectedHeaders["summary"])

    expect(@date_filter.isFilterAccordionExpanded()).to be true
    expect(@date_filter.getFilterAccordionTitle()).to eq("Collapse filter options")

    @date_filter.clickFilterAccordion()
    sleep 1
    expect(@date_filter.isFilterAccordionExpanded()).to be false
    expect(@date_filter.getFilterAccordionTitle()).to eq("Expand filter options")

    @date_filter.clickFilterAccordion()
    sleep 1
    expect(getLongFieldLabel("startDate")).to eq("* Start Date:")
    expect(getLongFieldLabel("endDate")).to eq("* End Date:")

    expect(getPlaceHolderByCSS(:css, "input[name='startDate']")).to eq("MM/DD/YYYY")
    expect(getPlaceHolderByCSS(:css, "input[name='endDate']")).to eq("MM/DD/YYYY")

  end

  def filterTest(expectedRowStrings)
    @nav_menu.navigate(@baseNav)

    noResultDate = Date.new(1900, 1, 1).strftime(format="%m/%d/%Y")
    @date_filter.setDateRangeAndFilter(noResultDate, noResultDate)

    !MAX_WAIT_LOOPS.times { break if (@personal_trackers.getNoResultsFoundMessage() == "No results were found with the current filters. Use the Add button above to create a new record."); sleep WAIT_LOOP_SLEEP_TIME }
    sleep 4
    expect(@personal_trackers.getNoResultsFoundMessage()).to eq("No results were found with the current filters. Use the Add button above to create a new record.")
    expect(getFocusedElementText()).to eq("No results were found with the current filters. Use the Add button above to create a new record.")

    setDateRangeAndValidate(3, 0, expectedRowStrings[2]) #to show the twoDaysAgo entry
    setDateRangeAndValidate(11, 3, expectedRowStrings[1]) #to show the tenDaysAgo entry
    setDateRangeAndValidate(35, 29, expectedRowStrings[0]) #to show the thirtyDaysAgo entry
  end

  def sortTest(expectedRowStrings)
    @nav_menu.navigate(@baseNav)

    @date_filter.setDateRangeAndFilter(@minTestDataDate, @maxTestDataDate)
    !MAX_WAIT_LOOPS.times { break if (@personal_trackers.getCount() == 3); sleep WAIT_LOOP_SLEEP_TIME }
    sleep 4
    dataSetSize = expectedRowStrings.length
    for i in 1..dataSetSize
      dataSetIndex = dataSetSize - i
      expect(@personal_trackers.getTextForRow(i)).to eq(expectedRowStrings[dataSetIndex])
    end
  end

  def deleteTest()
    @nav_menu.navigate(@baseNav)

    deleteModalTest()
    count = @personal_trackers.getCount()
    !count.times{ deleteAndVerifyEntry(1) }

    !MAX_WAIT_LOOPS.times { break if (@personal_trackers.getNoResultsFoundMessage() == "No results were found with the current filters. Use the Add button above to create a new record."); sleep WAIT_LOOP_SLEEP_TIME }
    sleep 4
    expect(@personal_trackers.getNoResultsFoundMessage()).to eq("No results were found with the current filters. Use the Add button above to create a new record.")
  end

  def entryTests(fields, addDataSet, editDataSet)
    @nav_menu.navigate(@baseNav)

    #Display a message in the detailed pane when no records exist
    !MAX_WAIT_LOOPS.times { break if (@personal_trackers.getNoResultsFoundMessage() == "No results were found with the current filters. Use the Add button above to create a new record."); sleep WAIT_LOOP_SLEEP_TIME }
    expect(@personal_trackers.getNoResultsFoundMessage()).to eq("No results were found with the current filters. Use the Add button above to create a new record.")

    expect(@date_filter.isDefaultDateRange()).to eq(true)

    filterLabelsAndPlaceholdersTest()
    #Set the date range to 2 years back so all the entered data will show up

    @date_filter.setDateRangeAndFilter(@minTestDataDate, @maxTestDataDate)

    addTest(fields, addDataSet)

    tableHeaderTest(@normalTableHeaders, @phoneTableHeaders)

    if(@graphInfo != nil)
      graphTest()
    end

    #unsavedWarningModalTests
    unsavedWarningModalTests()

    if @pdfInfo != nil
      pdfTest()
    end
    #test editing
    expectedRowStrings = editTest(fields, addDataSet, editDataSet)

    #filter test
    filterTest(expectedRowStrings)

    #sort test
    sortTest(expectedRowStrings)

    #delete test
    deleteTest()

  end

  def graphTest()
    @nav_menu.navigate(@baseNav)

    noResultDate = Date.new(1900, 1, 1).strftime(format="%m/%d/%Y")
    @date_filter.setDateRangeAndFilter(noResultDate, noResultDate)
    waitForPageToFinishLoading()

    expect(getPrimaryHeader()).to eq(@expectedHeaders["summary"])

    expect(getTextForElement(:css, @personal_trackers.graphButton)).to eq("Graph")
    click(:css, @personal_trackers.graphButton)
    waitForPageToFinishLoading()

    expect(getTextForElement(:css, @personal_trackers.tableButton)).to eq("Table")

    expect(getTextForElement(:css, @personal_trackers.noResultsFoundMessage)).to eq("No results were found with the current filters. Use the Add button above to create a new record.")
    expect(isElementPresentAndVisible(:css, @personal_trackers.graphContainer)).to eq(false)

    @date_filter.setDateRangeAndFilter(@minTestDataDate, @maxTestDataDate)
    waitForPageToFinishLoading()

    expect(getTextForElement(:css, @personal_trackers.viewTableMessage)).to eq("A text description of the information on this page is available in the table view.")
    expect(isElementPresentAndVisible(:css, @personal_trackers.graphContainer)).to eq(true)

    yAxisLabels = @personal_trackers.getYAxisLabels()

    numYAxisLabels = @graphInfo["yAxisLabels"].length

    for i in 0...numYAxisLabels
      # puts yAxisLabels[i]
      expect(yAxisLabels[i]).to eq(@graphInfo["yAxisLabels"][i])
    end

    click(:css, @personal_trackers.tableButton)
    waitForPageToFinishLoading()
  end

  def pdfTest()
    @nav_menu.navigate(@baseNav)

    !45.times{ break if (@personal_trackers.isPDFButtonDisplayed?() == true); sleep 1 }
    expect(@personal_trackers.isPDFButtonDisplayed?()).to eq(true)

    #--------------------------------------------------------------------------
    #-- 02/13/2015 - jnakama
    #-- With moving of PDF to DocumentCompositionServices PDF document is no
    #-- longer opened in a seperate window, therefore commenting out this
    #-- section until we find a way to detect PDF document was downloaded
    #--------------------------------------------------------------------------
    #@personal_trackers.clickPDFButton()
    #
    #switchWindowToWindowHandleLast()
    #
    #!45.times{ break if (@personal_trackers.hasEmbeddedPDF?() == true); sleep 1 }
    #expect(@personal_trackers.hasEmbeddedPDF?()).to eq(true)
    #
    #closeBrowser()
    #switchWindowToWindowHandleFirst()
    #
    #@nav_menu.navigate(@baseNav)
  end

  #Local Functions

  def addEntry(entryMap)
    @personal_trackers.clickAddEntryButton()
    waitForPageToFinishLoading()

    setEntryValues(entryMap)

    expect(getPrimaryHeader()).to eq(@expectedHeaders["add"])

    @entry_form.clickSaveButton()
    waitForPageToFinishLoading()
  end

  def addAndVerifyEntry(fields, entryMap, expectIndex)
    expectCount = @personal_trackers.getCount() + 1

    addEntry(entryMap)

    verifyEntry(fields, entryMap, expectCount, expectIndex)
  end

  def editEntry(entryMap, row)
    @personal_trackers.clickNthRow(row)
    waitForPageToFinishLoading()

    expect(getPrimaryHeader()).to eq(@expectedHeaders["edit"])

    setEntryValues(entryMap)
    @entry_form.clickSaveButton()
    waitForPageToFinishLoading()
  end

  def checkSaveStateInForm(expectedEntryMap, row)
    @personal_trackers.clickNthRow(row)
    waitForPageToFinishLoading()

    # !MAX_WAIT_LOOPS.times{ break if (getPrimaryHeader() == @expectedHeaders["edit"]); sleep WAIT_LOOP_SLEEP_TIME }


    expectedEntryMap.each {|key, value|
      fieldValue = getValueInField(key)

      expectedValue = numeric?(value) ? value.to_f : value
      testValue = numeric?(fieldValue) ? fieldValue.to_f : fieldValue

      expect(testValue).to eq(expectedValue)
    }

    @entry_form.clickCancelButton()
    waitForPageToFinishLoading()

    # !MAX_WAIT_LOOPS.times{ break if (getPrimaryHeader() == @expectedHeaders["summary"]); sleep WAIT_LOOP_SLEEP_TIME }

  end

  def editAndVerifyEntry(fields, entryMap, row, expectIndex)
    expectCount = @personal_trackers.getCount()

    editEntry(entryMap, row)

    verifyEntry(fields, entryMap, expectCount, expectIndex)
  end

  def verifyEntry(fields, entryMap, expectCount, expectIndex)
    !MAX_WAIT_LOOPS.times { break if (@personal_trackers.getCount() == expectCount); sleep WAIT_LOOP_SLEEP_TIME }
    expect(@personal_trackers.getCount()).to eq(expectCount)

    rowData = @personal_trackers.getRowValuesForSection(expectIndex)

    rowData.each { | key, value |
      if(entryMap[key] != nil)
        if(fields[key]["type"] === "slider")
          expectedValue = entryMap[key].to_s + " out of 10"
          testValue = value;
        else
          expectedValue = numeric?(entryMap[key]) ? entryMap[key].to_f : entryMap[key]
          testValue = numeric?(value) ? value.to_f : value
        end

        expect(testValue).to eq(expectedValue)

      end
    }

    if entryMap["time"] == nil
      expect(rowData["Date Entered"]).to start_with(entryMap["date"])
    else
      expect(rowData["Date Entered"]).to eq(entryMap["date"] + " " + entryMap["time"])
    end

    checkSaveStateInForm(entryMap, expectIndex)

  end


  def checkingInlineError(errMsg)

    #Verify that the error message section header is displayed
    !MAX_WAIT_LOOPS.times{ break if (@error.isErrorSummaryElementPresent(@formName)); sleep WAIT_LOOP_SLEEP_TIME }
    #Verify the error message is displayed
    expect(@error.isErrorMessageDisplayed(@formName, errMsg)).to eq(true)

  end


  #start on form page
  def boundaryTest(name, min, max, delta)
    prevValue = getValueInField(name)
    #assume true for personal trackers cause it works out for its cases, but to do it correctly should pass correct isRequired value
    expectedError = getShortFieldLabel(name, true).gsub(/:/, "") + " is outside the expected range. Please enter a value between " + min + " and " + max + "."

    minTestVal = nil
    maxTestVal = nil

    if(delta.to_s.index(".") == nil)
      minTestVal = (min.to_i - delta).to_s;
      maxTestVal = (max.to_i + delta).to_s;
      testVals = [minTestVal, maxTestVal, (max.to_i - delta).to_s + "1", (min.to_i + 0.5).to_s]
    else
      minTestVal = (min.to_f - delta).to_s;
      maxTestVal = (max.to_f + delta).to_s;
      testVals = [minTestVal, maxTestVal, (max.to_f - delta).to_s + "1", max.split(".")[0] + "5.0"]
    end

    testVals.each{ |val|
      editField(name, val)

      fieldValue = getValueInField(name)

      if fieldValue.to_f == val.to_f
        @entry_form.clickSaveButton()
        waitForPageToFinishLoading()
        checkingInlineError(expectedError)
      else
        expect(fieldValue).not_to eq(val)
      end
    }
    editField(name, prevValue)
  end

  def textareaMaxLengthTest(name, maxLength, hasCounter)

    testString = Array.new(maxLength){[*'0'..'9', *'a'..'z', *'A'..'Z'].sample}.join

    if hasCounter == true
      counterText = getTextForElement(:css, "span[ng-if='characterCounter']")
      expect(counterText).to eq(maxLength.to_s + " characters left")
    end

    editField(name, testString + "a")
    fieldText = getValueInField(name)
    expect(fieldText).to eq(testString)

    if hasCounter == true
      counterText = getTextForElement(:css, "span[ng-if='characterCounter']")
      expect(counterText).to eq("0 characters left")
    end
  end

  def requiredFieldTest(name)

    prevValue = getValueInField(name)
    expectedError = getShortFieldLabel(name, true).gsub(/:/, "") + " field is required."
    clearField(name)

    @entry_form.clickSaveButton()
    waitForPageToFinishLoading()

    #Verify that the error message section header is displayed
    # !MAX_WAIT_LOOPS.times{ break if (@error.isErrorSummaryElementPresent(@formName)); sleep WAIT_LOOP_SLEEP_TIME }
    #Verify the error message is displayed
    expect(@error.isErrorMessageDisplayed(@formName, expectedError)).to eq(true)

    #Clear the previously tested area to prepare for the next test
    editField(name, prevValue)

  end

  def deleteEntry(row)
    @personal_trackers.clickNthRow(row)
    waitForPageToFinishLoading()

    # !MAX_WAIT_LOOPS.times{ break if (getPrimaryHeader() == @expectedHeaders["edit"]); sleep WAIT_LOOP_SLEEP_TIME }

    @entry_form.clickDeleteButton()
    !MAX_WAIT_LOOPS.times{ break if (@modal.getConfirmationHeading() == "Confirmation"); sleep WAIT_LOOP_SLEEP_TIME }

    @modal.clickYesButton()
    waitForPageToFinishLoading()

    # !MAX_WAIT_LOOPS.times{ break if (getPrimaryHeader() == @expectedHeaders["summary"]); sleep WAIT_LOOP_SLEEP_TIME }
  end

  def deleteAndVerifyEntry(row)
    expectCount = @personal_trackers.getCount() - 1
    rowText = @personal_trackers.getTextForRow(row)

    deleteEntry(row)

    !MAX_WAIT_LOOPS.times{ break if ( @personal_trackers.getCount() == expectCount); sleep WAIT_LOOP_SLEEP_TIME }
    expect(@personal_trackers.getCount()).to eq(expectCount)

    for i in 1..expectCount
      expect(@personal_trackers.getTextForRow(i)).not_to eq(rowText)
    end
  end

  def deleteModalTest()
    @nav_menu.navigate(@baseNav)
    @personal_trackers.clickNthRow(1)
    waitForPageToFinishLoading()

    @entry_form.clickDeleteButton()
    !MAX_WAIT_LOOPS.times{ break if (@modal.getConfirmationHeading() == "Confirmation"); sleep WAIT_LOOP_SLEEP_TIME }

    expect(@modal.getConfirmationHeading()).to eq("Confirmation")
    expect(@modal.getConfirmationMessage()).to eq("Are you sure you want to remove this entry? Select YES to remove the entry or NO to return to the entry screen.")
    @modal.clickNoButton()

    !MAX_WAIT_LOOPS.times{ break if (getPrimaryHeader() == @expectedHeaders["edit"]); sleep WAIT_LOOP_SLEEP_TIME }
    expect(getPrimaryHeader()).to eq(@expectedHeaders["edit"])

    @entry_form.clickDeleteButton()
    !MAX_WAIT_LOOPS.times{ break if (@modal.getConfirmationHeading() == "Confirmation"); sleep WAIT_LOOP_SLEEP_TIME }
    expect(@modal.getConfirmationHeading()).to eq("Confirmation")
    expect(@modal.getConfirmationMessage()).to eq("Are you sure you want to remove this entry? Select YES to remove the entry or NO to return to the entry screen.")
    @modal.clickYesButton()
    waitForPageToFinishLoading()

    # !MAX_WAIT_LOOPS.times{ break if (getPrimaryHeader() == @expectedHeaders["summary"]); sleep WAIT_LOOP_SLEEP_TIME }
    expect(getPrimaryHeader()).to eq(@expectedHeaders["summary"])

  end

  def unsavedWarningModalTests()
    unsavedWarningModalTest(@siblingFeature)
    unsavedWarningModalTest(@siblingSection)
  end

  def unsavedWarningModalTest(nav)
    @nav_menu.navigate(@baseNav)
    @personal_trackers.clickNthRow(1)
    waitForPageToFinishLoading()

    #make more generic?
    testInput = "unsaved modal test"
    editField("Note", testInput)

    @nav_menu.navigate(nav)

    #CREATE MODAL TEXT CONSTANTS
    !MAX_WAIT_LOOPS.times{ break if (@modal.getConfirmationHeading() == "Confirmation"); sleep WAIT_LOOP_SLEEP_TIME }
    expect(@modal.getConfirmationHeading()).to eq("Confirmation")
    expect(@modal.getConfirmationMessage()).to eq("You have not saved your changes. If you wish to continue without saving select CONTINUE, otherwise select RETURN to return to the entry screen.")
    @modal.clickReturnButton()

    @nav_menu.navigate(nav)

    !MAX_WAIT_LOOPS.times{ break if (@modal.getConfirmationHeading() == "Confirmation"); sleep WAIT_LOOP_SLEEP_TIME }
    expect(@modal.getConfirmationHeading()).to eq("Confirmation")
    expect(@modal.getConfirmationMessage()).to eq("You have not saved your changes. If you wish to continue without saving select CONTINUE, otherwise select RETURN to return to the entry screen.")
    @modal.clickContinueButton()
    waitForPageToFinishLoading()

    # @nav_menu.navigate(nav)

    @nav_menu.navigate(@baseNav)
    @personal_trackers.clickNthRow(1)
    waitForPageToFinishLoading()

    !MAX_WAIT_LOOPS.times{ break if (getPrimaryHeader() == @expectedHeaders["edit"]); sleep WAIT_LOOP_SLEEP_TIME }

    expect(getValueInField("Note")).not_to eq(testInput)

    @entry_form.clickCancelButton()
    waitForPageToFinishLoading()

    # !MAX_WAIT_LOOPS.times{ break if (getPrimaryHeader() == @expectedHeaders["summary"]); sleep WAIT_LOOP_SLEEP_TIME }
  end

  def setDateRangeAndValidate(numOfDaysAgoFromDate, numOfDaysAgoToDate, expectedRowText)
    toDate = getDateNthDaysAgo(numOfDaysAgoToDate, "%m/%d/%Y")  #set it to Today
    fromDate = getDateNthDaysAgo(numOfDaysAgoFromDate, "%m/%d/%Y")

    @date_filter.setDateRangeAndFilter(fromDate, toDate)
    !MAX_WAIT_LOOPS.times{ break if (@personal_trackers.getCount() == 1); sleep WAIT_LOOP_SLEEP_TIME }
    expect(@personal_trackers.getCount()).to eq(1)
    expect(@personal_trackers.getTextForRow(1)).to eq(expectedRowText)
    expect(getFocusedElementText().strip).to eq(expectedRowText)
  end
end