import { LightningElement, api, track } from 'lwc';
import getSAApprovalRequestsx from '@salesforce/apex/ODRIntegration.getSAApprovalRequestsx';
import postSAApprovalx from '@salesforce/apex/ODRIntegration.postSAApprovalx';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PharmanetPayload extends LightningElement {
  @api recordId;
  verified = false;
  loaded = false;
  data = null;
  hasData = false;
  isError = false;
  error = {};

  @track error;
  connectedCallback() {
    getSAApprovalRequestsx({recordId: this.recordId})
    .then(data => {
      console.log("PAY:", data);
      if (data && data.error == null) {
        if (data) {
          console.log("PharmanetPayload:", data);
          this.data = data;
        }
      } else {
        this.isError = true;
        this.error = data.error.errorMessage;
      }
      this.hasData = this.data.length > 0;
      console.log("hasData", this.hasData);
      this.loaded = true;
    })
  }

  handleClick(event) {
    console.log("SA APPROVAL", this.recordId);
    postSAApprovalx({recordId: this.recordId})
    .then(data => {
      // Iterate through all the errors
      console.log('data:', data);
      for(let i = 0;i<data.length;i++) {
        if (data[i].error) {
          const event = new ShowToastEvent({
            title: 'Pharmanet Error',
            message: data[i].error.errorMessage
          });
        } else {
          const event = new ShowToastEvent({
            title: 'Success',
            message: JSON.parse(data[i].statusMessage)
          });
        }
        this.dispatchEvent(event);
      }
    })
  }
}