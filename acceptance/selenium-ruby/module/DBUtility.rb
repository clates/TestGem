require 'mysql'

module DBUtility
  DBPASSWORD = "Agilexadmin99$"
  USER = "root"
  SCHEMA = "HADB"
  AUTHSCHEMA = "AUTHDB"
  MOCKSCHEMA = "MOCKDB"
  #Notification QUARTZ schema
  QUARTZ_SCHEMA = "QUARTZ"

  def getPatientDOB(uniqueId)
    con = Mysql.new('localhost', USER, DBPASSWORD, MOCKSCHEMA)
    queryStr = 'SELECT MOCK_DOB FROM MOCKDB.MOCK_USERS where UNIQUE_ID= "'+uniqueId+'"'
    puts queryStr
    rs = con.query(queryStr)
    if rs.nil? == false then
      #puts "Number of rows returned: " + rs.num_rows.to_s
      while row = rs.fetch_hash do
        return row["MOCK_DO@pleasenote = PleaseNote.new(@driver)B"].to_date.strftime("%m/%d/%Y").to_s
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

  def resetQuartzNotificationDb()
    con = Mysql.new('localhost', USER, DBPASSWORD, QUARTZ_SCHEMA)
    rs = con.query('DELETE FROM QRTZ_CRON_TRIGGERS')
    rs = con.query('DELETE FROM QRTZ_TRIGGERS')
    rs = con.query('DELETE FROM QRTZ_JOB_DETAILS')
    con.close
    puts "Deleted QRTZ TRIGGERS data"
  end


end
