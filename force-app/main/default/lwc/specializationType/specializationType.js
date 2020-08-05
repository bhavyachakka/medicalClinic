import { LightningElement, wire ,track } from 'lwc';
import getspecializationTypes from '@salesforce/apex/GoogleCalendarController.getspecializationTypes';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Google_Specialization_ErrorMessage from '@salesforce/label/c.Google_Specialization_ErrorMessage';
import Google_Calendar_Select_Specialization from '@salesforce/label/c.Google_Calendar_Select_Specialization';
const ERROR_VARIANT = 'error';

export default class BoatSearchForm extends LightningElement {
	
    selectedTypeId = '';
    error = undefined;
    @track
    searchOptions;
    labelSpecialization=Google_Calendar_Select_Specialization;
    
    //To get all the specialization records
    @wire(getspecializationTypes)
        specializationTypes({ error, data }) {
        if (data) {
            this.searchOptions = data.map(type => {
               return { label: type.Name , value: type.Id };
            });
          	this.searchOptions.unshift({ label: 'All Types', value: '' });
        } else if (error) {
            this.searchOptions = undefined;
            this.error = error;
            this.dispatchEvent(
              new ShowToastEvent({
                title: Google_Specialization_ErrorMessage,
                message: error.body.message,
                variant: ERROR_VARIANT,
              }),
          );
        }
    }
    
    // Fires event that the search option has changed.
    handleSearchOptionChange(event) {
        this.selectedTypeId = event.target.value;
        const searchEvent = new CustomEvent('search', { detail: { specializationId :this.selectedTypeId }});
        this.dispatchEvent(searchEvent);
    }
}