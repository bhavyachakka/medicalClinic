/**
 * @name        : GoogleCalendarMockController
 * @description : To implemet HttpCalloutMock interface to create a fake response
 * @author      : Bhavya Chakka
 * @createddate : 2020-07-29
 */
@isTest
global class GoogleCalendarMockController implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        // Creating  a fake response
        HttpResponse response = new HttpResponse();

        if(request.getMethod() == 'GET'){
            response.setBody('{"kind":"calendar#events","etag":"\"p33sf1ncairuek0g\"","summary":"chakka.bhavya95@gmail.com","updated":"2020-08-02T09:09:32.667Z","timeZone":"Europe/Stockholm","accessRole":"writer","defaultReminders":[],"nextSyncToken":"CPjw3YqW_OoCEPjw3YqW_OoCGAQ=","items":[{"kind":"calendar#event","etag":"\"3192601424002000\"","id":"4occa0b81ghsi9ouqrap8aettg","status":"confirmed","htmlLink":"https://www.google.com/calendar/event?eid=NG9jY2EwYjgxZ2hzaTlvdXFyYXA4YWV0dGcgYnJhaG1hamk4M0Bt&ctz=Europe/Zurich","created":"2020-08-01T16:51:51.000Z","updated":"2020-08-01T16:51:52.001Z","summary":"Appointment Booked","description":"This is description","location":"At Hospital","creator":{"email":"bhavya.chitti6@gmail.com"},"organizer":{"email":"brahmaji83@gmail.com","self":true},"start":{"dateTime":"2020-08-04T09:00:00+02:00","timeZone":"Europe/Zurich"},"end":{"dateTime":"2020-08-04T09:30:00+02:00","timeZone":"Europe/Zurich"},"iCalUID":"4occa0b81ghsi9ouqrap8aettg@google.com","sequence":0,"reminders":{"useDefault":true}}]}');
            response.setStatusCode(200);
        }if(request.getMethod() == 'POST'){
            response.setBody('{"kind":"calendar#event","etag":"\"3192733013244000\"","id":"9rlm2m8ii3m18rgeae729ngvvk","status":"confirmed","htmlLink":"https://www.google.com/calendar/event?eid=OXJsbTJtOGlpM20xOHJnZWFlNzI5bmd2dmsgYnJhaG1hamk4M0Bt","created":"2020-08-02T11:08:26.000Z","updated":"2020-08-02T11:08:26.622Z","summary":"Appointment Booked","description":"This is description","location":"At Hospital","creator":{"email":"bhavya.chitti6@gmail.com"},"organizer":{"email":"chakka.bhavya95@gmail.com","self":true},"start":{"dateTime":"2020-08-05T09:30:00+02:00","timeZone":"Europe/Zurich"},"end":{"dateTime":"2020-08-05T10:00:00+02:00","timeZone":"Europe/Zurich"},"iCalUID":"9rlm2m8ii3m18rgeae729ngvvk@google.com","sequence":0,"reminders":{"useDefault":true}}');
            response.setStatusCode(200);
        }if(request.getMethod() == 'DELETE'){
            response.setStatusCode(202);
        }
        return response; 
    }

}
