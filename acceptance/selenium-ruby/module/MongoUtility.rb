require 'mongo'
require 'mongo-import'
require 'bson'
require 'active_support/time'

include Mongo
include MongoImport


module MongoUtility
  HOSTANDPORT = '10.2.2.2:27017'


  def removeCollection(collectionName, dbName)
    @db = Mongo::Client.new([ HOSTANDPORT ], :database => dbName)
    @db[collectionName].drop
    # puts "[removeCollection] removed All documents for " + collectionName
  end

  def dropCollection(collectionName, dbName)
    @db = Mongo::Client.new([ HOSTANDPORT ], :database => dbName)
    @db[collectionName].drop
    # puts "[dropCollection] dropped " + collectionName
  end

  def updateDocument(collectionName, dbName, objId, columnName, value)
    @db = Mongo::Client.new([ HOSTANDPORT ], :database => dbName)
    documents = @db[collectionName]
    documents.update_one({:_id => BSON::ObjectId(objId)}, {"$set" => {columnName => value}})
  end

  def updateWellBeingUpdatedDate(daysAgo, patientId)
    @db = Mongo::Client.new([ HOSTANDPORT ], :database => "healthinventorydb")
    collection = @db["assessments"]
    collection.update({"patientIdentifier" => {"uniqueId" => patientId, "assigningAuthority" => "EDIPI"}}, {"$set" => {"wellBeingAssessment" => {"assessmentType" => "well-being", "updatedDate" => daysAgo ,"wellBeingRatings" => [{"type" => "physical","typeDescription" => "Physical Well-Being", "score" => 2},{"type" => "mental","typeDescription" => "Mental/Emotional Well-Being","score" => 4},{"type" => "life","typeDescription" => "Life: How is it to live your day-to-day life?", "score" =>1}]} }}, {"multi" => true})
  end

  def updateProfessionalCareUpdatedDAte(daysAgo, patientId)
    puts "Days Ago string " + daysAgo.to_s
    @db = Mongo::Client.new([ HOSTANDPORT ], :database => "healthinventorydb")
    collection = @db["assessments"]
    collection.update({"patientIdentifier" => {"uniqueId" => patientId, "assigningAuthority"=> "EDIPI"}}, {"$set" =>  {"professionalCareAssessment" => { "assessmentType" => "professional-care", "updatedDate" => daysAgo,"preventionText" => "On a scale of 1(low) to 5(high), select the number that best describes how up to date you are on your preventive care such as a flu shot, cholesterol check, cancer screening, and dental care.", "preventionScore" => 1,"clinicalCareText" => "If you are working with a healthcare professional, on a scale of 1(low) to 5(high), select the number that best describes how well you understand your health problems, the treatment plan, and your role in your health.","clinicalCareScore" => -2147483648,"healthCareProfessionalText" => "I am not working with a healthcare professional.", "haveHealthCareProfessional" => "Yes"}}}, {"multi" => true})
  end

  def updatePersonalValuesUpdatedDate(daysAgo, patientId)
    puts "Days Ago " + daysAgo.to_s
    @db = Mongo::Client.new([ HOSTANDPORT ], :database => "healthinventorydb")
    collection = @db["promptedresponses"]
    collection.update({"patientIdentifier" => { "uniqueId" => patientId, "assigningAuthority" => "EDIPI" }}, {"$set" =>{  "responses" => [{"updatedDate" => daysAgo ,"questionKey" => "what-matters", "question" => "What REALLY matters to you in your life?","response" => ""},{"updatedDate" => daysAgo,"questionKey" => "sense-of-joy","question" => "What brings you a sense of joy?","response" => ""}]} }, {"multi" => true})

  end

  def updateReflectionsUpdatedDate(daysAgo, patientId)
    @db = Mongo::Client.new([ HOSTANDPORT ], :database => "healthinventorydb")
    collection = @db["promptedresponses"]
    collection.update({"patientIdentifier" => {"uniqueId" => patientId, "assigningAuthority"=> "EDIPI"}}, {"$set" =>{ "responses" => [{"updatedDate" => daysAgo,"questionKey" => "health-vision","question" => "Now that you have thought about all of these areas, what is your vision of your best possible health?","response" => "What is my vision of my best possible health?"},{"updatedDate" => daysAgo,"questionKey" => "where-to-start","question" => "Are there any areas you would like to work on? Where might you start?", "response" => "Any areas I would like to work on"}]}}, {"multi" => true})

  end


  def removeDocument(collectionName, dbName, assigningAuthorityValue, uniqueIdValue)
    @db = Mongo::Client.new([ HOSTANDPORT ], :database => dbName)
    documents = @db[collectionName].sort({})
    documents.remove({"patientIdentifier.uniqueId" => uniqueIdValue, "patientIdentifier.assigningAuthority"=> assigningAuthorityValue})

  end

  def removeDocumentByObjectId(collectionName, dbName, objId)
    @db = Mongo::Client.new([ HOSTANDPORT ], :database => dbName)
    documents = @db[collectionName]
    documents.remove({:_id => BSON::ObjectId(objId)})
  end


  def insertCollection(collectionName, dbName, fileName)
      snapshot fileName, :host => '10.2.2.2', :port => 27017, :db => dbName, :collection => collectionName, :path => 'spec/snapshots'
      puts "[insertCollection] imported Collection " + collectionName
    end

  def resetCollection(collectionName, dbName, fileName)
    removeCollection(collectionName, dbName)
    insertCollection(collectionName, dbName, fileName)
    puts "[resetCollection] reset Collection " + collectionName
  end

  def getDocumentByObjId(collectionName, dbName, objId, columnName)
    @db = Mongo::Client.new([ HOSTANDPORT ], :database => dbName)
    document = @db[collectionName].find({:_id => BSON::ObjectId(objId)}, :fields => [columnName]).to_a
    #puts "[getDocumentByObjId ] " + document.to_s

    return document
  end

  def getDocumentByPatientIdentifier(collectionName, dbName, assigningAuthorityValue, uniqueIdValue, columnName)
    @db = Mongo::Client.new([ HOSTANDPORT ], :database => dbName)
    document = @db[collectionName].find({"patientIdentifier.uniqueId" => uniqueIdValue, "patientIdentifier.assigningAuthority"=> assigningAuthorityValue}, :fields => [columnName])

    return document
  end

  def getLatestDocumentByPatientIdentifier(collectionName, dbName, assigningAuthorityValue, uniqueIdValue, columnName)
    @db = Mongo::Client.new([ HOSTANDPORT ], :database => dbName)
    document = @db[collectionName].find({"patientIdentifier.uniqueId" => uniqueIdValue, "patientIdentifier.assigningAuthority"=> assigningAuthorityValue}, :fields => [columnName]).sort({'createdDate' => -1})

    return document
  end

  def verifyNotificationDeleted(collectionName, dbName, objId, columnName)
    document = getDocumentByObjId(collectionName, dbName, objId, columnName)
    isDeleted = true

    for record in document
     if record[columnName] == false
      isDeleted = false
      break
     end
    end

    #puts "[verifyNotificationDeleted ] objId: " + objId + " - columnName: " + columnName + " IsDeleted: " + isDeleted.to_s
    return isDeleted

  end

  def verifyDocumentsDeleted(collectionName, dbName, assigningAuthorityValue, uniqueIdValue, columnName)
    document = getDocumentByPatientIdentifier(collectionName, dbName, assigningAuthorityValue, uniqueIdValue, columnName)
    isDeleted = true

    for record in document
      #puts "record[columnName] = " + record[columnName].to_s

      if record[columnName] == false
        isDeleted = false
        break
      end
    end

    return isDeleted

  end

  def retrieveThisFieldInDocumentWithMultiRows(collectionName, dbName, assigningAuthorityValue, uniqueIdValue, columnName)
    document = getDocumentByPatientIdentifier(collectionName, dbName, assigningAuthorityValue, uniqueIdValue, columnName)
    outPut = ""
    document.each { |record|
      #puts record[columnName]
      if record[columnName] != nil then
        outPut = record[columnName] + ',' + outPut.to_s
      else
        output = "" + "," + output.to_s
      end
    }
    #puts "outPut=" + outPut.to_s
    return outPut

  end

  def retrieveThisFieldInDocument(collectionName, dbName, assigningAuthorityValue, uniqueIdValue, columnName)
    document = getDocumentByPatientIdentifier(collectionName, dbName, assigningAuthorityValue, uniqueIdValue, columnName)

    for record in document
      puts "record[columnName]=" + record[columnName].to_s
      return record[columnName]
    end
  end

  def retrieveLatestRecordFieldInDocument(collectionName, dbName, assigningAuthorityValue, uniqueIdValue, columnName)
    document = getLatestDocumentByPatientIdentifier(collectionName, dbName, assigningAuthorityValue, uniqueIdValue, columnName)

    for record in document
      puts "record[" + columnName + "]=" + record[columnName].to_s
      return record[columnName]
    end
  end

  def getTotalDocumentCountByPatientIdentifier(collectionName, dbName, assigningAuthorityValue, uniqueIdValue)
    @db = Mongo::Client.new([ HOSTANDPORT ], :database => dbName)
    document = @db[collectionName].find({"patientIdentifier.assigningAuthority"=> assigningAuthorityValue, "patientIdentifier.uniqueId" => uniqueIdValue})

    return document.count
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


  def retreiveAllDocumentsInCollection(collectionName, dbName)
    documentArray = []
    @db = Mongo::Client.new([ HOSTANDPORT ], :database => dbName)
    documents = @db[collectionName].find()
    documents.each do | document |
      documentArray << document
    end
    return documentArray
  end

  def setDefaultPreferencesForPatient(uniqueId)
    @db = Mongo::Client.new([ HOSTANDPORT ], :database => "notificationsdb")
    documents = @db["preferences"]
    document = getDocumentByPatientIdentifier("preferences", "notificationsdb", "EDIPI", uniqueId, "timeZone")
    if(document.next() == nil)
      documents.insert({"patientIdentifier" => { "uniqueId" => uniqueId, "assigningAuthority"=> "EDIPI" }, "timeZone" => "(+04:00) Asia/Dubai"})
    end
  end

  def setDefaultNotificationPreferencesForPatient(uniqueId, firstName, lastName)
    @db = Mongo::Client.new([ HOSTANDPORT ], :database => "notificationsdb")
    documents = @db["notificationPreferences"]
    document = getDocumentByPatientIdentifier("notificationPreferences", "notificationsdb", "EDIPI", uniqueId, "optInSelected")
    if(document.next() == nil)
      documents.insert({"patientIdentifier" => { "uniqueId" => uniqueId, "assigningAuthority"=> "EDIPI" }, "firstName" => firstName, "lastName" => lastName, "optInSelected" => true, "dateOfBirth" => {"format" => "MMM dd, yyyy", "value" => "Jan 19, 1900", "valid" => true}})
    end
  end
end