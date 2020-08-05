@isTest
public with sharing class testAppointmentCreation {

    @TestSetup
    static void makeData(){
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
        
        Test.startTest();
        List<Specialization__c> speclist = bookAnAppointment.getspecializationTypes();
        Test.stopTest();
        System.assertEquals(1 ,speclist.size());
    }

    @isTest
    public static void testGetPhysiciansWithSpecialization() {
        List<Specialization__c> speclist = [SELECT Id, Name FROM Specialization__c LIMIT 1 ];
        Test.startTest();
        List<Physician__c> physicianlist = bookAnAppointment.getphysicians(speclist[0].Id);
        Test.stopTest();
        System.assertEquals(1 ,physicianlist.size());

    }
    @isTest
    public static void testGetPhysiciansWithoutSpecialization() {
        Test.startTest();
        List<Physician__c> physicianlist = bookAnAppointment.getPhysicians(null);
        Test.stopTest();
        System.assertEquals(0 ,physicianlist.size());
    }
    @isTest
    public static void testGetAppointmentDetails(){
        String calendarId = '';
        Test.startTest();
        List<Appointment__c> applist =bookAnAppointment.getAppointmentDetails(calendarId);
        Test.stopTest();
        System.assertEquals(1,applist.size());

    }

}
