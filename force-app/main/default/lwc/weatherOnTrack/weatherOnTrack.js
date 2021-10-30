import { LightningElement, api } from 'lwc';
import getWeatherOnTrack from '@salesforce/apex/FormulaOneServices.getWeatherOnTrack';

export default class TrackWeather extends LightningElement {
    @api recordId;
    temp = '';


    async connectedCallback() {

        getWeatherOnTrack({
            raceId: this.recordId
        })
        .then(resp => {
            const data = JSON.parse(resp);
            const celsius = Math.round((data.temp - 32) / 1.8);
            this.temp = 'Temp: ' + celsius + '°C';       
        })
    }
}