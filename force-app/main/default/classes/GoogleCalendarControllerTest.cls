/**
 * @name        : GoogleCalendarControllerTest
 * @description : Test class of GoogleCalendarController
 * @author      : Bhavya Chakka
 * @createddate : 2020-07-29
 */
@isTest(seeAlldata = false)
public with sharing class GoogleCalendarControllerTest {

    //setting up the data for the test methods to reuse
    @TestSetup
    static void makeData() {
        //creation of specialization record
        Specialization__c eachspecialization = new Specialization__c();
        eachspecialization.Name = 'TestSpecialization';
        eachspecialization.Price__c = 1000;
        insert eachspecialization;
        System.debug(eachspecialization.Id);

        //creation of physician record
        Physician__c eachphysician = new Physician__c();
        eachphysician.Specialization__c = eachspecialization.id;
        eachphysician.Name = 'TestPhysician';
        eachphysician.Email__c = 'testphysician@test.com';
        eachphysician.Phone__c = '123456' ;
        insert eachphysician;

        //creation of patient record
        Patient__c eachpatient = new Patient__c();
        eachpatient.Full_Name__c = 'TestPatient';
        eachpatient.Email__c = 'testpatient@test.com';
        eachpatient.Mobile_No__c ='70910';
        eachpatient.Age__c = 25;
        eachpatient.Salutation__c ='Mrs';
        insert eachpatient;

        //creation of appointment record
        Appointment__c eachappointment = new Appointment__c();
        eachappointment.Patient__c = eachpatient.Id;
        eachappointment.Physician__c = eachphysician.Id;
        eachappointment.Reason_For_Appointment__c = 'Health Issues';
        eachappointment.Start_Time__c = system.now();
        eachappointment.End_Time__c = system.now().addHours(1);
        eachappointment.Google_Calendar_Id__c = 'abcdefghi1233456';
        insert eachappointment;

    }
    
    @isTest
    public  static void testGetspecializationTypes() {
        //To test specialization 
        Test.startTest();
        List<Specialization__c> speclist = GoogleCalendarController.getspecializationTypes();
        Test.stopTest();
        System.assertEquals(speclist.size(), 1);
    }

    @isTest
    public static void testGetPhysiciansWithSpecialization() {

        List<Specialization__c> speclist = [SELECT Id, Name FROM Specialization__c LIMIT 1 ];
         //To test physician records
        Test.startTest();
        List<Physician__c> physicianlist = GoogleCalendarController.getphysicians(speclist[0].Id);
        Test.stopTest();

        System.assertEquals(physicianlist.size(), 1);

    }
    @isTest
    public static void testGetPhysiciansWithoutSpecialization() {
         //To test physician records
        Test.startTest();
        List<Physician__c> physicianlist = GoogleCalendarController.getPhysicians(null);
        Test.stopTest();

        System.assertEquals(physicianlist.size(),1);
    }
    @isTest
    public static void testGetAppointmentDetails(){

        String calendarId = 'abcdefghi1233456';
        //To test Appointment records
        Test.startTest();
        List<Appointment__c> applist =GoogleCalendarController.getAppointmentDetails(calendarId);
        Test.stopTest();

        System.assertEquals(applist.size(),1);
    }
    @isTest
    public static void testGetCalendarEvents(){

        String email = 'chakka.bhavya95@gmail.com';

        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new GoogleCalendarMockController()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        Test.startTest();
        String response = GoogleCalendarController.getCalendarEvents(email);
        Test.stopTest();
        // Verify that the response received contains fake values
        String expectedValue = '{"kind":"calendar#events","etag":"\"p33sf1ncairuek0g\"","summary":"chakka.bhavya95@gmail.com","updated":"2020-08-02T09:09:32.667Z","timeZone":"Europe/Stockholm","accessRole":"writer","defaultReminders":[],"nextSyncToken":"CPjw3YqW_OoCEPjw3YqW_OoCGAQ=","items":[{"kind":"calendar#event","etag":"\"3192601424002000\"","id":"4occa0b81ghsi9ouqrap8aettg","status":"confirmed","htmlLink":"https://www.google.com/calendar/event?eid=NG9jY2EwYjgxZ2hzaTlvdXFyYXA4YWV0dGcgYnJhaG1hamk4M0Bt&ctz=Europe/Zurich","created":"2020-08-01T16:51:51.000Z","updated":"2020-08-01T16:51:52.001Z","summary":"Appointment Booked","description":"This is description","location":"At Hospital","creator":{"email":"bhavya.chitti6@gmail.com"},"organizer":{"email":"brahmaji83@gmail.com","self":true},"start":{"dateTime":"2020-08-04T09:00:00+02:00","timeZone":"Europe/Zurich"},"end":{"dateTime":"2020-08-04T09:30:00+02:00","timeZone":"Europe/Zurich"},"iCalUID":"4occa0b81ghsi9ouqrap8aettg@google.com","sequence":0,"reminders":{"useDefault":true}}]}';
        System.assertEquals(response, expectedValue);

    }
    @isTest
    public static void testCreateEvent(){

        DateTime startTime = System.now();
        DateTime endTime = System.now().addHours(1);
        String physicianEmail ='chakka.bhavya95@gmail.com';

        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new GoogleCalendarMockController()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        Test.startTest();
        String response = GoogleCalendarController.createEvent(startTime.format(),endTime.format(),
                                                                        physicianEmail);
        Test.stopTest();
        // Verify that the response received contains fake values
        String expectedValue = '{"kind":"calendar#event","etag":"\"3192733013244000\"","id":"9rlm2m8ii3m18rgeae729ngvvk","status":"confirmed","htmlLink":"https://www.google.com/calendar/event?eid=OXJsbTJtOGlpM20xOHJnZWFlNzI5bmd2dmsgYnJhaG1hamk4M0Bt","created":"2020-08-02T11:08:26.000Z","updated":"2020-08-02T11:08:26.622Z","summary":"Appointment Booked","description":"This is description","location":"At Hospital","creator":{"email":"bhavya.chitti6@gmail.com"},"organizer":{"email":"chakka.bhavya95@gmail.com","self":true},"start":{"dateTime":"2020-08-05T09:30:00+02:00","timeZone":"Europe/Zurich"},"end":{"dateTime":"2020-08-05T10:00:00+02:00","timeZone":"Europe/Zurich"},"iCalUID":"9rlm2m8ii3m18rgeae729ngvvk@google.com","sequence":0,"reminders":{"useDefault":true}}';
        System.assertEquals(response, expectedValue);

    }
    @isTest
    public static void testDeleteCalendarEvents(){

        String calendarId = 'abc123';
        String email = 'chakka.bhavya95@gmail.com';

        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new GoogleCalendarMockController()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        Test.startTest();
        Integer response = GoogleCalendarController.deleteCalendarEvents(email,calendarId);
        Test.stopTest();
        // Verify that the response received contains fake values
        Integer expectedValue = 202;
        System.assertEquals(response, expectedValue);

    }
}
