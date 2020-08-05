public with sharing class bookAnAppointment {
    @AuraEnabled(cacheable = true )
    public static List<Specialization__c> getspecializationTypes() {
        return [SELECT Name, Id FROM Specialization__c ];
    }

    @AuraEnabled(cacheable = true )
    public static List<Physician__c> getPhysicians(String specializationId) {
        // Without an explicit specializationId, the full list is desired
        String query = 'SELECT '
                     + 'Id,Name,Email__c,Phone__c,'
                     + 'Specialization__c, Specialization__r.Name,Specialization__r.Price__c '
                     + 'FROM Physician__c';
        if (String.isNotBlank(specializationId)) {
            query += ' WHERE Specialization__c = :specializationId AND Email__c! = NULL';
        }else{
            query += 'WHERE Email__c! = NULL ';
        }
        return Database.query(query);
    }
    @AuraEnabled(cacheable = true )
    public static List<Appointment__c> getAppointmentDetails(String calendarId) {
        return [SELECT Name, Id,Patient__r.Name,Physician__r.Name,Physician__r.Email__c,
                Google_Calendar_Id__c 
                FROM Appointment__c
                WHERE Google_Calendar_Id__c = :calendarId];
    }

}
