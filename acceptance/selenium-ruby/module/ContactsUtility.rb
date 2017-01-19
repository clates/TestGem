require 'active_support/time'
require 'rubygems'
require "json"
require 'selenium-webdriver'
require 'mysql'
require_relative '../module/DriverUtility'


module ContactsUtility
  include DriverUtility

  def helper_get_TestPatientID
    @TEST_PATIENT_ID = "D123401"
    return @TEST_PATIENT_ID
  end
  
  def helper_setTestDates
    @tomorrow = getDateNthDaysFromNow(1, "%m/%d/%Y") #Use "%Y-%m-%d" for YYYY/mm/dd
    
    @today = getDateNthDaysAgo(0, "%m/%d/%Y")
    @thirtyDaysAgo = getDateNthDaysAgo(30, "%m/%d/%Y")
    @fortyDaysAgo = getDateNthDaysAgo(40, "%m/%d/%Y")
    @fiftyDaysAgo = getDateNthDaysAgo(40, "%m/%d/%Y")

    @twentynineDaysAgo = getDateNthDaysAgo(29, "%m/%d/%Y")
    @twentysevenDaysAgo = getDateNthDaysAgo(27, "%m/%d/%Y")
    @twentyfiveDaysAgo = getDateNthDaysAgo(25, "%m/%d/%Y")
    @twentyDaysAgo = getDateNthDaysAgo(20, "%m/%d/%Y")
    
    
    @fifteenDaysAgo = getDateNthDaysAgo(15, "%m/%d/%Y")
    
    @twoDaysAgo = getDateNthDaysAgo(2, "%m/%d/%Y")
    @oneDayAgo = getDateNthDaysAgo(1, "%m/%d/%Y")
  end
  
  def helper_setDateRangeThenClickFilter(pageObject, numOfDaysAgo)
    today = @common.getDateNthDaysAgo(0, "%m/%d/%Y")
    fromDate = @common.getDateNthDaysAgo(numOfDaysAgo, "%m/%d/%Y")
    
    pageObject.setDateRangeAndFilter(fromDate, today)
  end
    
  def helper_validatAllEntriesWithinRange(pageObject)
    expect(pageObject.isDatesWithinFilteredDateRange?()).to eq(true)
  end
  
  def helper_validateEntryInRange(pageObject, subjectStr, shouldBeInRange=true)
    if ( shouldBeInRange )
      expect(pageObject.isCommLogDisplayed?(subjectStr)).to eq(true)
    else
      expect(pageObject.isCommLogDisplayed?(subjectStr)).to eq(false)
    end 
  end
   
  def helper_validateEntryShouldBeInRange(pageObject, subjectStr)
    helper_validateEntryInRange(pageObject, subjectStr, true)
  end
   
  def helper_validateEntryShouldNotBeInRange(pageObject, subjectStr)
    helper_validateEntryInRange(pageObject, subjectStr, false)
  end

  def helper_clickNthRow(pageObject, number, editScreenTitle)
    pageObject.clickNthCommunicationLog(number)
    helper_verifyEntryDetailScreenTitle(editScreenTitle)
  end
  
  def helper_verifyMsgOnConfirmModal(msg)
    sleep 2
    !45.times{ break if (@modal.getConfirmationHeading() == "Confirmation"); sleep 1 }
    sleep 1
    # When running locally, modal title is in getConfirmationHeading(), but when running
    # on build server, getConfirmationHeading() is blank and instead,
    # getTopLayerModalConfirmationHeading() contains the modal title.
    # So check for both
    #puts "DEBUG: ContactsUtility.helper_verifyMsgOnConfirmModal.@modal.getConfirmationHeading()=[#{@modal.getConfirmationHeading()}]"
    #puts "DEBUG: ContactsUtility.helper_verifyMsgOnConfirmModal.@modal.getTopLayerModalConfirmationHeading()=[#{@modal.getTopLayerModalConfirmationHeading()}]"
    #puts "DEBUG: ContactsUtility.helper_verifyMsgOnConfirmModal.@modal.getConfirmationMessage()=[#{@modal.getConfirmationMessage()}]"
    if @modal.getConfirmationHeading() != ""
      expect(@modal.getConfirmationHeading()).to eq("Confirmation")
    else
      expect(@modal.getTopLayerModalConfirmationHeading()).to eq("Confirmation")
    end
    expect(@modal.getConfirmationMessage()).to eq(msg)
  end

  def helper_NO_deleteNthCommLog(pageObject, number, editScreenTitle, communicationsLogScreenTitle)
    commLogCountBeforeDelete = pageObject.getCommunicationsLogCount()
    
    helper_clickNthRow(pageObject, number, editScreenTitle)
    
    selectedSubject = pageObject.getSelectedLogSubject()

    pageObject.clickDeleteButton()
    helper_verifyMsgOnConfirmModal("Are you sure you want to remove this entry? Select YES to remove the entry or NO to return to the entry screen.")
    
    @modal.clickNoButton()

    sleep 2
    !45.times{ break if ( pageObject.getSubjectInForm() == selectedSubject); sleep 1 }
    expect(pageObject.getSubjectInForm()).to eq(selectedSubject)
      
    pageObject.clickCancelButton()
    helper_verifyListScreenTitle(communicationsLogScreenTitle)
   
    expect(pageObject.getCommunicationsLogCount()).to eq(commLogCountBeforeDelete)
  end

  def helper_YES_deleteNthCommLog(pageObject, number, editScreenTitle, communicationsLogScreenTitle)
    commLogCountBeforeDelete = pageObject.getCommunicationsLogCount()
    helper_clickNthRow(pageObject, number, editScreenTitle)
    selectedSubject = pageObject.getSelectedLogSubject()

    pageObject.clickDeleteButton()
    helper_verifyMsgOnConfirmModal("Are you sure you want to remove this entry? Select YES to remove the entry or NO to return to the entry screen.")
    @modal.clickYesButton()
    helper_verifyListScreenTitle(communicationsLogScreenTitle)
    !45.times{ break if ( pageObject.getCommunicationsLogCount() == (commLogCountBeforeDelete - 1)); sleep 1 }
    expect(pageObject.getCommunicationsLogCount()).to eq(commLogCountBeforeDelete - 1)
    expect(pageObject.isCommLogDisplayed?(selectedSubject)).to eq(false)
  end

  def helper_validateErrorMessages(errors, formName)
    expectedValidationSummaryHeader = errors.length > 0 ? "The following errors were found:" : ""
    sleep 1

    !45.times{ break if (@errorSummary.getValidationSummaryHeader(formName) == expectedValidationSummaryHeader); sleep 1 }
    expect(@errorSummary.getValidationSummaryHeader(formName)).to eq(expectedValidationSummaryHeader)

    if(expectedValidationSummaryHeader != "")
      for i in 0..(errors.length - 1)
        if errors[i] != nil
          expect(@errorSummary.isErrorMessageDisplayed(formName, errors[i])).to eq(true)
        else
          expect(@errorSummary.isErrorMessageDisplayed(formName, errors[i])).to eq(false)
        end
      end
    else
      expect(@errorSummary.isErrorSummaryElementPresent(formName)).to eq(false)
    end
  end

  # Local functions starts - "entryForm" for Add/Edit page  and "fileterForm" form Filter page
  def helper_checkingInlineError(errMsg, formName)
    #Verify that the error message section header is displayed
    !45.times{ break if (@errorSummary.getValidationSummaryHeader(formName) == "The following errors were found:"); sleep 1 }
    expect(@errorSummary.getValidationSummaryHeader(formName)).to eq("The following errors were found:")
    #Verify the error message is displayed
    expect(@errorSummary.isErrorMessageDisplayed(formName, errMsg)).to eq(true)
  end

  def helper_requiredDateTimeFieldTest(pageObject, testArea, errMsg)
    case testArea
      when "Date" then
        clearDateOrTime("input[name='date']")
      when "Time" then
        clearDateOrTime("input[name='time']")

    end

    pageObject.clickSaveButton()
    helper_checkingInlineError(errMsg, "entryForm")

    #Clear the previously tested area to prepare for the next test
    time = Time.new
    today = time.strftime("%m/%d/%Y")
    now = time.strftime("%I:%M %p")
    case testArea
      when "Date" then
        setDate(today, "input[name='date']")
      when "Time" then
        setTime(now, "input[name='time']")
    end

    sleep 2
  end

  def helper_navigateToCommunicationsLog
    #Click on left nav menu to open it
    @main.clickNavMenu()
    !45.times{ break if (@nav_menu.getNavMenuHeading() == "App Options"); sleep 1 }
    expect(@nav_menu.getNavMenuHeading()).to eq("App Options")
      
    #then click on Contacts button under left nav menu
    @nav_menu.clickContacts    
    !45.times{ break if (@contacts.getSecondaryHeader == "Contacts"); sleep 1 }
    
    #then click on Communications Log button under Contacts menu                 
    expect(@contacts.isCommunicationsLogButtonVisible).to eq(true)
    @contacts.clickCommunicationsLog
  end
  
  def helper_verifyEntryDetailScreenTitle(title)
    !45.times{ break if (getPrimaryHeader() == title); sleep 1 }  
    expect(getPrimaryHeader()).to eq(title)
  end
  
  def helper_verifyListScreenTitle(title)
    sleep 1.0
    !45.times{ break if (getPrimaryHeader() == title); sleep 1}
    expect(getPrimaryHeader()).to eq(title)
  end
  
  def helper_verify_row_data(pageObject, entryDate, entryContactType, entrySubject, entryContact, entryNotes, rowIndex)
    currentRowEntry = pageObject.getCommunicationsLogEntry(rowIndex)

    #validating subject cell 
    subjCellText = pageObject.getSubjectTextInRowEntry(currentRowEntry)
    expect(subjCellText).to eq(entrySubject[0,50])
      
    #validating contact cell 
    contactCellText = pageObject.getContactTextInRowEntry(currentRowEntry)
    expect(contactCellText).to eq(entryContact[0,50])

    #validating type cell 
    contactTypeCellText = pageObject.getCommunicationTypeTextInRowEntry(currentRowEntry)
    expect(contactTypeCellText).to eq(entryContactType)
    
    #validating changing date and time for date entry
    dateCellText = pageObject.getDateTextInRowEntry(currentRowEntry)
    expect(isDateFormatValid?(dateCellText, "%m/%d/%Y")).to eq(true)
    expect(dateCellText).to eq(entryDate)
  end

  #Adding entry in an expected row
  def helper_add_this_entry(pageObject, listTitle, entryDate, entryContactType, entrySubject, entryContact, entryNotes, expectedRow)
    waitForPageToFinishLoading
    commLogCountBeforeAdded = pageObject.getCommunicationsLogCount()
    pageObject.addCommunicationLog(entryDate, entryContactType, entrySubject, entryContact, entryNotes)
    
    helper_verifyListScreenTitle(listTitle)
    
    #Wait until the grid's count increase by 1 
    !45.times{ break if (pageObject.getCommunicationsLogCount() == ( commLogCountBeforeAdded + 1) ); sleep 1 }
    actualCount = pageObject.getCommunicationsLogCount()
    expect(actualCount).to eq(commLogCountBeforeAdded + 1)

    subOfExpectedRow = pageObject.getNthSubjectInCommList(expectedRow)

    i=0;
    #Wait loop until the subject of newly added entry is dispalyed in the grid
    !45.times{ 
          break if (subOfExpectedRow == ( entrySubject[0,50]) ); 
          subOfExpectedRow = pageObject.getNthSubjectInCommList(expectedRow)
          i = i+1
          sleep 1 
    }
    subOfExpectedRow = pageObject.getNthSubjectInCommList(expectedRow)
    expect(subOfExpectedRow).to eq(entrySubject[0,50])
    
    helper_verify_row_data(pageObject, entryDate, entryContactType, entrySubject, entryContact, entryNotes, expectedRow)
  end

  def helper_verify_this_entry_added(pageObject, listTitle, editScreenTitle, createdDateTime, entryContactType, entrySubject, entryContact, entryNotes)
    rowIndex = pageObject.findIndexWithGivenLogSubject(entrySubject[0,50])
    pageObject.clickNthCommunicationLog(rowIndex)
       
    helper_verifyEntryDetailScreenTitle(editScreenTitle)
    
    #Capturing the Date and Time after the event is selected for modification
    dateInForm = pageObject.getDateInForm()
    contactTypeInForm = pageObject.getContactTypeInForm()
    contactInForm = pageObject.getContactInForm()
    notesInForm = pageObject.getNotesInForm()
    subjectInForm = pageObject.getSubjectInForm()

    expect(dateInForm).to eq(createdDateTime)
    expect(contactInForm).to eq(entryContact[0,50])
    expect(contactTypeInForm).to eq(entryContactType)
    expect(notesInForm).to eq(entryNotes[0,250])
    expect(subjectInForm).to eq(entrySubject[0,50])

    pageObject.clickCancelButton()
    helper_verifyListScreenTitle(listTitle)
  end
  
  def helper_verify_Empty_List(pageObject, emptyMsg)
    #display emptyMsg in the detailed pane when no items are found.
    !45.times{ break if (pageObject.getNoResultsFoundMessage() == emptyMsg); sleep 1 }
    expect(pageObject.getNoResultsFoundMessage()).to eq(emptyMsg) #("No results found.")
    expect(pageObject.getCommunicationsLogCount()).to eq(0)
  end
    
  #Adding entry in an expected row
  def helper_add_nav_this_log_entry(pageObject, listTitle, addScreenTitle, entryDate, entryContactType, entrySubject, entryContact, entryNotes, expectedRow)
    commLogCountBeforeAdded = pageObject.getCommunicationsLogCount()
    
    pageObject.clickAddCommunicationBtn()
    helper_verifyEntryDetailScreenTitle(addScreenTitle)
    
    #Fill data in edit screen 
    pageObject.fillDataInCommunicationLogForm(entryDate, entryContactType, "XXX", "YYY", "ZZZ")
    #Then click somewhere else to navigate away
    @contacts.clickPersonalContacts

    helper_verifyMsgOnConfirmModal("You have not saved your changes. If you wish to continue without saving select CONTINUE, otherwise select RETURN to return to the entry screen.")
    @modal.clickContinueButton()
    
    #Verify at Personal Contacts screen
    !45.times{ break if (@contacts.getPrimaryHeader == "Personal Contacts"); sleep 1 }
    expect(@contacts.getPrimaryHeader).to eq("Personal Contacts")
    
    #Then navigate back to Communications Log
    helper_navigateToCommunicationsLog
    
    helper_verifyListScreenTitle(listTitle)
    expect(pageObject.getCommunicationsLogCount()).to eq(commLogCountBeforeAdded)
    
    pageObject.clickAddCommunicationBtn()
    helper_verifyEntryDetailScreenTitle(addScreenTitle)
      
    #Fill data in edit screen 
    pageObject.fillDataInCommunicationLogForm(entryDate, entryContactType, "XXX", "YYY", "ZZZ")
    #Then click somewhere else to navigate away
    @contacts.clickPersonalContacts

    helper_verifyMsgOnConfirmModal("You have not saved your changes. If you wish to continue without saving select CONTINUE, otherwise select RETURN to return to the entry screen.")
      
    @modal.clickReturnButton()
    
    helper_verifyEntryDetailScreenTitle(addScreenTitle)
    
    pageObject.fillDataInCommunicationLogForm(entryDate, entryContactType, entrySubject, entryContact, entryNotes)
    pageObject.clickSaveButton()
    
    helper_verifyListScreenTitle(listTitle)
   
    #Wait until the grid's count increase by 1 
    !45.times{ break if (pageObject.getCommunicationsLogCount() == ( commLogCountBeforeAdded + 1) ); sleep 1 }
    actualCount = pageObject.getCommunicationsLogCount()
    expect(actualCount).to eq(commLogCountBeforeAdded + 1)
  
    subOfExpectedRow = pageObject.getNthSubjectInCommList(expectedRow)

    i=0;
    #Wait loop until the subject of newly added entry is dispalyed in the grid
    !45.times{ 
          break if (subOfExpectedRow == ( entrySubject[0,50]) ); 
          subOfExpectedRow = pageObject.getNthSubjectInCommList(expectedRow)
          i = i+1
          sleep 1 
    }
    subOfExpectedRow = pageObject.getNthSubjectInCommList(expectedRow)
    
    helper_verify_row_data(pageObject, entryDate, entryContactType, entrySubject, entryContact, entryNotes, expectedRow)
  end

  #Editing entry in an expected row
  def helper_edit_nav_this_log_entry(pageObject, listTitle, editScreenTitle, entryDate, entryContactType, entrySubject, entryContact, entryNotes, expectedRow)
    commLogCountBeforeEdited = pageObject.getCommunicationsLogCount()
    
    helper_clickNthRow(pageObject, expectedRow, editScreenTitle)
    
    #Fill data in edit screen 
    pageObject.fillDataInCommunicationLogForm(entryDate, entryContactType, "XXX", "YYY", "ZZZ")
    #Then click somewhere else to navigate away
    @contacts.clickPersonalContacts

    helper_verifyMsgOnConfirmModal("You have not saved your changes. If you wish to continue without saving select CONTINUE, otherwise select RETURN to return to the entry screen.")
    @modal.clickContinueButton()
    
    #Verify at Personal Contacts screen
    !45.times{ break if (@contacts.getPrimaryHeader == "Personal Contacts"); sleep 1 }
    expect(@contacts.getPrimaryHeader).to eq("Personal Contacts")
    
    #Then navigate back to Communications Log
    helper_navigateToCommunicationsLog
    
    helper_verifyListScreenTitle(listTitle)
    expect(pageObject.getCommunicationsLogCount()).to eq(commLogCountBeforeEdited)
    
    helper_clickNthRow(pageObject, expectedRow, editScreenTitle)
      
    #Fill data in edit screen 
    pageObject.fillDataInCommunicationLogForm(entryDate, entryContactType, "XXX", "YYY", "ZZZ")
    #Then click somewhere else to navigate away
    @contacts.clickPersonalContacts

    helper_verifyMsgOnConfirmModal("You have not saved your changes. If you wish to continue without saving select CONTINUE, otherwise select RETURN to return to the entry screen.")
      
    @modal.clickReturnButton()
    
    helper_verifyEntryDetailScreenTitle(editScreenTitle)
    
    pageObject.fillDataInCommunicationLogForm(entryDate, entryContactType, entrySubject, entryContact, entryNotes)
    pageObject.clickSaveButton()
    
    helper_verifyListScreenTitle(listTitle)
   
    #Wait for the grid's count
    !45.times{ break if (pageObject.getCommunicationsLogCount() == ( commLogCountBeforeEdited) ); sleep 1 }
    actualCount = pageObject.getCommunicationsLogCount()
    expect(actualCount).to eq(commLogCountBeforeEdited)
  
    subOfExpectedRow = pageObject.getNthSubjectInCommList(expectedRow)

    i=0;
    #Wait for the row subject dispalyed in the grid
    !45.times{ 
          break if (subOfExpectedRow == ( entrySubject[0,50]) ); 
          subOfExpectedRow = pageObject.getNthSubjectInCommList(expectedRow)
          i = i+1
          sleep 1 
    }
    subOfExpectedRow = pageObject.getNthSubjectInCommList(expectedRow)
    
    helper_verify_row_data(pageObject, entryDate, entryContactType, entrySubject, entryContact, entryNotes, expectedRow)
  end

  #Editing entry in an expected row
  def helper_edit_required_fields_and_cancel_button(pageObject, listTitle, editScreenTitle, entryDate, entryContactType, entrySubject, entryContact, entryNotes, expectedRow)
    helper_clickNthRow(pageObject, expectedRow, editScreenTitle)
    helper_verifyEntryDetailScreenTitle(editScreenTitle)
    
    #Fill all fields in edit screen with blanks
    pageObject.fillDataInCommunicationLogForm("", "", "", "", "")
    pageObject.clickSaveButton()
    helper_validateErrorMessages(["Date field is required.", "Type field is required.", "Subject field is required."], "entryForm")
    
    pageObject.fillDataInCommunicationLogForm(entryDate, entryContactType, entrySubject, entryContact, entryNotes)
    pageObject.clickCancelButton()
  end
  
  def helper_verify_list(actual_list, expected_list)
    expected_list.each_with_index do |line, i|
      expect(actual_list[i]).to eq(line)
    end 
    expect(actual_list.length).to eq(expected_list.length) 
  end
  
end
