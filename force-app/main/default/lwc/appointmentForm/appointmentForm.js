import { LightningElement, api } from 'lwc';
import createEvent from '@salesforce/apex/GoogleCalendarController.createEvent';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Google_Calendar_Appointment_Form_Title from '@salesforce/label/c.Google_Calendar_Appointment_Form_Title'
const ERROR_VARIANT = 'error';

export default class AppointmentForm extends LightningElement {

	@api
	startDate;
	@api
	endDate;
	@api
	selectedPhysicianId;
	@api
	selectedPhysicianEmail;
	@api
	appointmentReason;
	openInnerSpinner = false;//To open the spinner elememt when the appointment is submitted
	calendarId;//To store the calendarId
	 
	//Create vent in physician calendar on submission of appointment form
	handleSubmit(event){
		this.openInnerSpinner =true;
		event.preventDefault();
		let startTime = this.startDate;
		let endTime = this.endDate;
		let physicianEmail = this.selectedPhysicianEmail;
		this.createEventInGoogleCalendar(startTime,endTime,physicianEmail,event);

	}

	//Create appointment upon patient record creation
	handleSuccess(event){
		console.log('success');
		const fields = {};
		fields.Start_Time__c = this.startDate + '+02:00';
		fields.End_Time__c = this.endDate + '+02:00';
		fields.Patient__c = event.detail.id;
		fields.Physician__c = this.selectedPhysicianId;
		fields.Reason_For_Appointment__c = this.appointmentReason;
		fields.Google_Calendar_Id__c = this.calendarId;
		const recordInput = { apiName: 'Appointment__c', fields };
		//create appointment record in salesforce
		createRecord(recordInput)
		.then(result => {
			console.log(result);
			//dispatch event to render the event on fullcalendar js and close the modal
			this.dispatchEvent(
				new CustomEvent('calendarevent', {detail : this.calendarId})
			 );
		})
		.catch(error => {
			this.dispatchEvent(
				new ShowToastEvent({
					title: 'Google_Calendar_Appointment_Form_Title',
					message: error.body.message,
					variant: ERROR_VARIANT,
				}),
			);
		});

		
	}
	
	//create event in physician calendar
	@api
	createEventInGoogleCalendar(startTime, endTime, physicianEmail, event){
		console.log('inside appointment js create event');
		createEvent({startTime:startTime,endTime: endTime, physicianEmail: physicianEmail}) 
		//creating the new patient record once the event is created in physician calendar    
		.then(result => {
			let resultObj = JSON.parse(result);
			if(resultObj.id){
				this.calendarId = resultObj.id;
				console.log(this.calendarId);
				const fields = event.detail.fields;
				if(fields.Full_Name__c){
					this.template.querySelector('lightning-record-edit-form').submit(fields);
				}
			}
		})
		.catch(error => {
			this.dispatchEvent(
				new ShowToastEvent({
					title: Google_Calendar_Appointment_Form_Title,
					message: error.body.message,
					variant: ERROR_VARIANT,
				}),
			);
		})
		.finally(() => {
			this.openInnerSpinner = false;
		})
	}
}