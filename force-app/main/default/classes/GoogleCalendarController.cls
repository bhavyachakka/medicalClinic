/**
 * @name        : GoogleCalendarController
 * @description : To get, create and delete events in Physican email
 * @author      : Bhavya Chakka
 * @createddate : 2020-07-29
 * @testclass   : GoogleCalendarControllerTest
 */
public with sharing class GoogleCalendarController {
    
    /**
     * @methodname  : getCalendarEvents
     * @description : To get physician events from Google calendar
     * @params      : String - physician Email
     * @output      : String - Google Calendar API response body
     */
    @AuraEnabled
    public static String getCalendarEvents(String physicianEmail) {

        //Get current time and encode to UTF-8 as per google docs
        String currentTime = DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ', 'Europe/Zurich');
        currentTime = EncodingUtil.urlEncode(currentTime, 'UTF-8');

        //Default the timezone to CET
        String timeZone = EncodingUtil.urlEncode('Europe/Zurich', 'UTF-8');

        //Prepare the request to Google
        HttpRequest request = new HttpRequest();
        request.setEndPoint('callout:GoogleCalendar/calendars/' + physicianEmail + '/events?timeMin=' + currentTime + 
                                                                '&timeZone=' + timeZone );
        request.setMethod('GET');
        Http newhttp = new Http();

        //sending the request
        Httpresponse response = newhttp.send(request);
        return response.getBody();
    }
    
    /**
     * @methodname  : createEvent
     * @description : To create events in physician calendar
     * @params      : String - physician Email,startTime,endTime
     * @output      : String - Google Calendar API response body
     */

    @AuraEnabled
    public static String createEvent(String startTime, String endTime, String physicianEmail) {
        
        //Get start and end time and encode it as per google docs
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
            gen.writeStringField('summary', System.Label.Google_Calendar_Summary);
            gen.writeStringField('location', System.Label.Google_Calendar_Location);
            gen.writeStringField('description', System.Label.Google_Calendar_Description);
            
            gen.writeFieldName('start');
            gen.writeStartObject();
                gen.writeStringField('dateTime',startTime );
                gen.writeStringField('timeZone', 'Europe/Zurich');
            gen.writeEndObject();

            gen.writeFieldName('end');
            gen.writeStartObject();
                gen.writeStringField('dateTime',endTime );
                gen.writeStringField('timeZone', 'Europe/Zurich');
            gen.writeEndObject();
        gen.writeEndObject();
        String jsonBody = gen.getAsString();

        //Prepare the request to Google
        HttpRequest request = new HttpRequest();
        request.setEndPoint('callout:GoogleCalendar/calendars/' + physicianEmail +'/events');
        request.setMethod('POST');
        request.setBody(jsonBody);
        Http sendit = new Http();

        //sending the request
        Httpresponse response = sendit.send(request);
        return response.getBody();
    }

    /**
     * @methodname  : deleteCalendarEvents
     * @description : To delete appointments in physician calendar
     * @params      : String - physician Email,calendarId
     * @output      : Integer - Google Calendar API response Statuscode
     */

    @AuraEnabled
    public static Integer deleteCalendarEvents(String physicianEmail, String calendarId) {

        //Getting the physician email and calendarId abd setting them in the URL
        HttpRequest request = new HttpRequest();
        request.setEndPoint('callout:GoogleCalendar/calendars/' + physicianEmail + '/events/'+ calendarId );
        request.setMethod('DELETE');
        Http sendit = new Http();
        //sending the request
        Httpresponse response = sendit.send(request);
        return response.getStatusCode();
        
    }

    /**
     * @methodname  : getspecializationTypes
     * @description : To get the specilalizations
     * @output      : List of Specalization records
     */

    @AuraEnabled(cacheable = true)
    public static List<Specialization__c> getspecializationTypes() {
        return [SELECT Name, Id FROM Specialization__c ];
    }

    /**
     * @methodname  : getPhysicians
     * @description : To get the physicians records list
     * @params      : String -specializationId
     * @output      : List of Specalization records
     */
    @AuraEnabled(cacheable = true )
    public static List<Physician__c> getPhysicians(String specializationId) {
        // Without an explicit specializationId, the full list is desired
        String query = 'SELECT '
                     + 'Id,Name,Email__c,Phone__c,'
                     + 'Specialization__c, Specialization__r.Name,Specialization__r.Price__c '
                     + 'FROM Physician__c';
        if (String.isNotBlank(specializationId)) {
            query += ' WHERE Specialization__c = :specializationId AND Email__c != NULL';
        }else{
            query += ' WHERE Email__c != NULL ';
        }
        return Database.query(query);
    }

    /**
     * @methodname  : getAppointmentDetails
     * @description : To get the appointments
     * @params      : String -calendarId
     * @output      : List of Appointment records
     */
    @AuraEnabled(cacheable = true )
    public static List<Appointment__c> getAppointmentDetails(String calendarId) {
        return [SELECT Name, Id,Patient__r.Name,Physician__r.Name,Physician__r.Email__c,
                        Google_Calendar_Id__c 
                FROM Appointment__c
                WHERE Google_Calendar_Id__c = :calendarId];
    }
    
}