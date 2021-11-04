import { LightningElement, api } from 'lwc';
import getWinsOfDriver from '@salesforce/apex/FormulaOneServices.getWinsOfDriver';
import { NavigationMixin } from 'lightning/navigation';

const columns = [
    { label: 'Race Result Name', fieldName: 'Name', },
    { label: 'Grand Prix Url', fieldName: 'Grand_Prix_Link', type: 'url', typeAttributes: { label: { fieldName: 'Grand_Prix_Name' } } },
    { label: 'Is Fastest Lap', fieldName: 'Is_Fastest_Lap__c', type: 'boolean' },
];

export default class RelatedResultsList extends NavigationMixin(LightningElement) {
    @api recordId;
    data = [];
    columns = columns;

    isError = false;
    isEmpty = false;

    async connectedCallback() {
        try {
            const resp = await getWinsOfDriver({driverId: this.recordId});

            if (resp.length === 0) {
                this.isEmpty = true;
                return;
            }
    
            for (let item of resp) {      
                let url = await this[NavigationMixin.GenerateUrl]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: item.Grand_Prix__r.Id,
                        actionName: 'view',
                    },
                });
                item.Grand_Prix_Link = url;
                item.Grand_Prix_Name = item.Grand_Prix__r.Name;
            }
            
            this.data = resp;
        } catch (err) {
            this.isError = true;
            console.error(err);
        }
    }    
}