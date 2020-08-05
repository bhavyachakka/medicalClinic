import { LightningElement, track, wire, api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FullCalendarJS from '@salesforce/resourceUrl/FullCalendarJS';
import { refreshApex } from '@salesforce/apex';
import createEvent from '@salesforce/apex/GoogleCalendarController.createEvent';
import deleteCalendarEvents from '@salesforce/apex/GoogleCalendarController.deleteCalendarEvents';
import getAppointmentDetails from '@salesforce/apex/GoogleCalendarController.getAppointmentDetails';
import { createRecord,deleteRecord } from 'lightning/uiRecordApi';
import Google_Calendar_Summary from '@salesforce/label/c.Google_Calendar_Summary';
import Google_Calendar_Load_Error from '@salesforce/label/c.Google_Calendar_Load_Error';
import Google_Calendar_Appointment_Delete_Title from '@salesforce/label/c.Google_Calendar_Appointment_Delete_Title';
import Google_Calendar_Appointment_Delete from '@salesforce/label/c.Google_Calendar_Appointment_Delete';
import Google_Calendar_Appointment_Form_Title from '@salesforce/label/c.Google_Calendar_Appointment_Form_Title';
import Google_Calendar_Appointment_Private from '@salesforce/label/c.Google_Calendar_Appointment_Private';
import Google_Calendar_Appointment_Retrive from '@salesforce/label/c.Google_Calendar_Appointment_Retrive';
const WARNING_VARIANT = 'warning';
const ERROR_VARIANT = 'error';
const SUCCESS_VARIANT = 'success';

export default class FullCalendarJs extends LightningElement {
    //To avoid the recursion from renderedcallback
    fullCalendarJsInitialised = false;
    //Fields to store the event data
    title;
    startDate;
    endDate;
    calenderId; //store the calendar id to retrieve and delete
    activeSections = ['appointment'];
    @track
    appointmentId = '';
    @api
    selectedPhysicianId;
    @api
    selectedPhysicianEmail;
    newpatient = true;
    openAppointmentForm = false; //To open the appointment modal
    eventsRendered = false;//To render initial events only once
    openSpinner = false; //To open the spinner in waiting screens
    openModal = false; //To open form
    openInnerSpinner = false;//To open the spiiner on when the appointment is submitted
    @track
    events = []; //all calendar events are stored in this field
    //To store the orignal wire object to use in refreshApex method
    eventOriginalData = [];

    //Load the fullcalendar.io in this lifecycle hook method
    renderedCallback() {
        // Performs this operation only on first render
        if (this.fullCalendarJsInitialised) {
            return;
        }
        this.fullCalendarJsInitialised = true;

        // Executes all loadScript and loadStyle promises
        // and only resolves them once all promises are done
        Promise.all([
            loadScript(this, FullCalendarJS + "/FullCalendarJS/jquery.min.js"),
            loadScript(this, FullCalendarJS + "/FullCalendarJS/moment.min.js"),
            loadScript(this, FullCalendarJS + "/FullCalendarJS/fullcalendar.min.js"),
            loadStyle(this, FullCalendarJS + "/FullCalendarJS/fullcalendar.min.css"),
        ])
        .then(() => {
            //initialize the full calendar
            this.initialiseFullCalendarJs();
        })
        .catch((error) => {
            this.showNotification(Google_Calendar_Load_Error, error.body.message, WARNING_VARIANT);
        });
    }

    //Initializing the fullcalendar and adding all event handlers - select and eventClick
    initialiseFullCalendarJs() {
        const ele = this.template.querySelector("div.fullcalendarjs");

        //To store the current context
        var self = this;

        //To open the form with predefined fields
        //TODO: to be moved outside this function
        function openActivityForm(startDate, endDate){
            self.startDate = startDate;
            self.endDate = endDate;
            self.openModal = true;
        }
        function appointmentForm(calEventid){
            self.calenderId = calEventid; 
            self.fetchAppointmentDetails(self.calenderId);
            
        }

        let today = new Date();
        let yesterdayDate = today.setDate(today.getDate() - 1); //to block old dates

        //Actual fullcalendar renders here - https://fullcalendar.io/docs/v3/view-specific-options
        $(ele).fullCalendar({
            header: {
                left: "prev,next,today",
                center: "title",
                right: "agendaWeek,agendaDay",
            },
            defaultDate: new Date(), // default day is today - to show the current date
            defaultView : 'agendaWeek', //To display the default view - as of now it is set to week view
            validRange: {
                start: yesterdayDate
              },
            navLinks: true, // can click day/week names to navigate views
            // editable: true, // To move the events on calendar - TODO 
            selectable: true, //To select the period of time
            timezone: 'CET',
            //To select the time period : https://fullcalendar.io/docs/v3/select-method
            select: function (startDate, endDate) {
                let stDate = startDate.format();
                let edDate = endDate.format();
                openActivityForm(stDate, edDate);
            },
            //Ability to open and cancel the appointment
            eventClick : function(calEvent, jsEvent, view) {
                let calEventid = calEvent.id;
                appointmentForm(calEventid);
            },
            eventLimit: true, // allow "more" link when too many events
            events: this.events, // all the events that are to be rendered - can be a duplicate statement here
        });
    }

    //To fetch appointment details on click of existing event - for cancellation
    fetchAppointmentDetails(calEventid) {
        console.log(calEventid);
        getAppointmentDetails({calendarId : calEventid })
        .then((result) => {
            console.log(result);
            if(result[0] && result[0].Google_Calendar_Id__c){
                this.appointmentId = result[0].Id;
                this.openAppointmentForm = true;
            }else{
                this.showNotification(Google_Calendar_Appointment_Private, '', WARNING_VARIANT);
                
            }
        })
        .catch((error) => {
            this.showNotification(Google_Calendar_Appointment_Retrive, '', ERROR_VARIANT);
        });
    }

    /**
     * @description : to add the events to calendar
     * It works when the user changes the physician, first remove all events from prev physician 
     * and add new physician events     * 
     */
    @api
    addEventsToCalendar(result){
        let eventObj = JSON.parse(result);
        let events = eventObj.items.map(event => {
            return { id : event.id, 
                    title : Google_Calendar_Summary,//event.summary
                    start : event.start.dateTime,
                    end   : event.end.dateTime,
                    allDay : false};
        });
        this.events = events;
        const ele = this.template.querySelector("div.fullcalendarjs");
        //Remove events from the calendar
        this.removeEvents();
        //Add events to calendar
        $(ele).fullCalendar('renderEvents', this.events, true);
        
    }

    //To remove events from the calendar when physical is changed
    @api
    removeEvents() {
        const ele = this.template.querySelector("div.fullcalendarjs");
        //remove all events first
        $(ele).fullCalendar('removeEvents');
    }

    //TODO: add the logic to support multiple input texts
    handleKeyup(event) {
        this.title = event.target.value;
    }
    
    //To close the modal form
    handleCancel(event) {
        this.openModal = false;
        this.openAppointmentForm = false; 
    }

   //To save the event
    handleSave(event) {
        let events = this.events;
        this.openSpinner = true;
        //format as per fullcalendar event object to create and render
        let newevent = {title : Google_Calendar_Summary, 
                        start : this.startDate, 
                        end: this.endDate};
        //Close the modal
        this.openModal = false;
        const ele = this.template.querySelector("div.fullcalendarjs");
        //To populate the event on fullcalendar object
        //Id should be unique and useful to remove the event from UI - calendar
        newevent.id = event.detail || event;
        
        //renderEvent is a fullcalendar method to add the event to calendar on UI
        //Documentation: https://fullcalendar.io/docs/v3/renderEvent
        $(ele).fullCalendar( 'renderEvent', newevent, true );
        
        //To display on UI with id from server
        this.events.push(newevent);

        //To close spinner and modal
        this.openSpinner = false;
        this.title = '';//to nullify the title
        //show toast message
        this.showNotification('', Google_Calendar_Summary, SUCCESS_VARIANT);
   }

    /**
     * @description method to show toast events
     */
    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    
    handleNewPatient(){
        this.openPatientForm = true;
        this.openOnlyAppointment = true;
        this.newpatient =true;
        this.activeSections = ['appointment', 'patient'];
    }
    handleExistingPatient(){
        this.openOnlyAppointment = false;
        this.newpatient = false;
    }

    // To toggle between New and Existing patient button brand colors
    get isnewpatient(){
        return this.newpatient ? 'brand' : 'neutral';
    }

    get isexistingpatient(){
        return this.newpatient ? 'neutral' : 'brand';
    }
    
    //create the event in physician google calendar
    handleSubmit(event){
        event.preventDefault();
        this.openInnerSpinner = true;
        let startTime = this.startDate;
		let endTime = this.endDate;
        let physicianEmail = this.selectedPhysicianEmail;
        createEvent({startTime:startTime,endTime: endTime, physicianEmail: physicianEmail})     
		.then(result => {
            let resultObj = JSON.parse(result);
			if(resultObj.id){
                const fields = event.detail.fields;
                fields.Start_Time__c = this.startDate + '+02:00';
                fields.End_Time__c = this.endDate + '+02:00';
                fields.Physician__c = this.selectedPhysicianId;
                fields.Reason_For_Appointment__c = this.title;
                fields.Google_Calendar_Id__c = resultObj.id;
                this.template.querySelector('lightning-record-edit-form').submit(fields);
			}
		})
		.catch(error => {
            this.showNotification(Google_Calendar_Appointment_Form_Title, error.body.message, ERROR_VARIANT);
        })
        .finally(() => {
            this.openInnerSpinner = false;
        })
    }
    
    //Add the event once the appointment has been created
    handleSuccess(event){
        this.handleSave(event.detail.fields.Google_Calendar_Id__c.value);	
    }
    
    //deleting the appointment record and in the appointment event in physician calendar 
    deleteAppointment(event){
        this.openInnerSpinner = true;
        deleteRecord(this.appointmentId)
        .then(() => {
            const ele = this.template.querySelector("div.fullcalendarjs");
            $(ele).fullCalendar( 'removeEvents', [this.calenderId] );
            this.openAppointmentForm = false;
            deleteCalendarEvents({physicianEmail : this.selectedPhysicianEmail,calendarId :this.calenderId})    
            .then(result => {
                this.showNotification(Google_Calendar_Appointment_Delete, error.body.message, SUCCESS_VARIANT);
            })
            .catch(error => {
                this.showNotification(Google_Calendar_Appointment_Delete_Title, error.body.message, ERROR_VARIANT);

            }); 
        })
        .catch(error => {
            this.showNotification(Google_Calendar_Appointment_Delete_Title, error.body.message, ERROR_VARIANT);
        })
        .finally(() => {
            this.openInnerSpinner = false;
        })  
    }

}