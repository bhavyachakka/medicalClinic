import { LightningElement,api } from 'lwc';
const TILE_WRAPPER_SELECTED_CLASS ='selected';
import Google_Calendar_Fee from '@salesforce/label/c.Google_Calendar_Fee';

export default class PhysiciansDisplay extends LightningElement {

	@api
	physician;
	@api
	selectedPhysicianId;
	labelFee =Google_Calendar_Fee;
  
	// Getter for dynamically setting the tile class based on whether the
	// current physician is selected
	get tileClass() {
	return (this.selectedPhysicianId == this.physician.Id) ? TILE_WRAPPER_SELECTED_CLASS : "" ;

	}
	//Fires event with the Id & Email of the physician that has been selected 
	selectPhysician(event) {
	const selectEvent = new CustomEvent('physicianselect', {
				detail: {
				physicianId : this.physician.Id,
				physicianEmail : this.physician.Email__c
			}
			});
	this.dispatchEvent(selectEvent);   
	}
}