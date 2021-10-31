import { LightningElement, api } from 'lwc';
import getWeatherOnTrack from '@salesforce/apex/FormulaOneServices.getWeatherOnTrack';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TrackWeather extends LightningElement {
    @api recordId;
    temp = '';


    async connectedCallback() {

        getWeatherOnTrack({
            raceId: this.recordId
        })
        .then(resp => {
            const data = JSON.parse(resp);

            if (data.statusCode !== 200) {
                this.temp = 'x(';

                const message = data.message ?? 'Try to reload page. If error still remain, contact your administrator.';

                const evt = new ShowToastEvent({
                    title: 'Error Occured',
                    message: 'Sorry, error has been occured. ' + message,
                    variant: 'error',
                });
                this.dispatchEvent(evt);

                return;
            }

            const celsius = Math.round((data.temp - 32) / 1.8);
            this.temp = 'Temp: ' + celsius + '°C';       
        })
        .catch(err => {
            this.temp = 'x(';

            const evt = new ShowToastEvent({
                title: 'Error Occured',
                message: 'Sorry, error has been occured. Try to reload page. If error still remain, contact your administrator.',
                variant: 'error',
            });
            this.dispatchEvent(evt);

            console.error(err);
        });
    }
}