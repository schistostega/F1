import { LightningElement, api } from 'lwc';
import getWinsOfDriver from '@salesforce/apex/FormulaOneServices.getWinsOfDriver';

const columns = [
    { label: 'Race Result Name', fieldName: 'Name', },
    { label: 'Grand Prix Url', fieldName: 'Grand_Prix_Link', type: 'url', typeAttributes: { label: { fieldName: 'Grand_Prix_Name' } } },
    { label: 'Is Fastest Lap', fieldName: 'Is_Fastest_Lap__c', type: 'boolean' },
];

export default class RelatedResultsList extends LightningElement {
    @api recordId;
    data = [];
    columns = columns;

    isError = false;
    isEmpty = false;

    async connectedCallback() {
        getWinsOfDriver({
            driverId: this.recordId
        })
        .then(resp => {
            if (resp.length === 0) {
                this.isEmpty = true;
                return;
            }

            for (let item of resp) {
                item.Grand_Prix_Name = item.Grand_Prix__r.Name;
                item.Grand_Prix_Link = `/lightning/r/Race__c/${item.Grand_Prix__r.Id}/view`;
            }
            
            this.data = resp;
        })
        .catch(err => {
            this.isError = true;
            console.error(err);
        });
    }    
}