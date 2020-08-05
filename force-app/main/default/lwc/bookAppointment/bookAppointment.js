import { LightningElement,api,track,wire} from 'lwc';
import getPhysicians from '@salesforce/apex/GoogleCalendarController.getPhysicians';
import getCalendarEvents from '@salesforce/apex/GoogleCalendarController.getCalendarEvents';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Google_Calendar_Display_Message from '@salesforce/label/c.Google_Calendar_Display_Message';
import Google_Calendar_Display_Physician_Message from '@salesforce/label/c.Google_Calendar_Display_Physician_Message';
import Google_Calendar_Book_Appointment_Title from '@salesforce/label/c.Google_Calendar_Book_Appointment_Title'
const ERROR_VARIANT = 'error';

export default class BookAppointment extends LightningElement {

    @api
    specializationId= '';
    selectedPhysicianId;
    selectedPhysicianEmail = '';
    error;
    openSpinner = false;
    @track
    physician;
    openCalendar = false;
    displayMessage = Google_Calendar_Display_Message;

    //Store the specializationId from the custom event
    searchPhysicians(event){
        this.specializationId =event.detail.specializationId;   
    }

    //To get the physicians based on specializationId from the getPhysicians method
    @wire(getPhysicians ,{specializationId: '$specializationId'})
        wiredPhysicians(result) {
            this.physician= result;   
    }
    
    //To fetch the physician event details from his calendar on physician select
    fetchPhysicianCalendar(event){
        this.openCalendar = true;
        this.openSpinner = true;
        this.selectedPhysicianId= event.detail.physicianId;
        this.selectedPhysicianEmail = event.detail.physicianEmail;
        //imperative call to getCalendarEvents to fet the physician events
        getCalendarEvents({ physicianEmail: this.selectedPhysicianEmail })
        .then(result => {
            if(JSON.parse(result).items){
                this.template.querySelector('c-fullcalendar').addEventsToCalendar(result);
            }else{
                // Toast event with message - Unable to retrieve calendar details,
                //please verify if the physician shared calendar or not
                this.template.querySelector('c-fullcalendar').removeEvents();
                this.displayMessage = Google_Calendar_Display_Physician_Message;
                this.openCalendar = false;              
            }
            
        })
        .catch(error => {
            this.error = error;
            //Toast error message
            //Unable to access google calendar, please ask administrator
            this.template.querySelector('c-fullcalendar').removeEvents();
            const evt = new ShowToastEvent({
                title:   Google_Calendar_Book_Appointment_Title,
                message:  error.body.message ,
                variant: ERROR_VARIANT,
            });
            this.dispatchEvent(evt);
        })
        .finally(() => {
            this.openSpinner = false;
        });
    }
}

