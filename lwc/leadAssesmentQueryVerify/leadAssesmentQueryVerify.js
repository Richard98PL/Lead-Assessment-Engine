import {api, LightningElement, track} from 'lwc';
import {CloseActionScreenEvent} from "lightning/actions";
import verifyQueriesAndActions from '@salesforce/apex/LeadAssessmentService.verifyQueriesAndActions';

export default class leadAssessmentQueryVerify extends LightningElement {
    @api recordId;

    @track simpleColumns = [
        { label : 'Query', fieldName : 'query', type: 'text', wrapText: true, hideDefaultActions: false},
        { label : 'Rows', fieldName : 'rowsReturned', type: 'text', wrapText: true, hideDefaultActions: true},
        { label : 'Validation', fieldName : 'validation', type: 'text', wrapText: true, hideDefaultActions: true,
          cellAttributes:{
            class: {
                fieldName: 'styleFormat'
                }
            }
        }
    ];

    @track complexColumns = [
        { label : 'Condition', fieldName: 'recordLink', type: 'url', hideDefaultActions: true, wrapText: true,
            typeAttributes: {
                label: {
                    fieldName: 'conditionName'
                },
                target : '_blank'}
        },
        { label : 'Query', fieldName : 'query', type: 'text', wrapText: true, hideDefaultActions: false},
        { label : 'Validation', fieldName : 'validation', type: 'text', wrapText: true, hideDefaultActions: true,
            cellAttributes:{
                class: {
                    fieldName: 'styleFormat'
                }
            }
        }
    ];

    @track actionsColumns = [
        { label : 'Action', fieldName: 'recordLink', type: 'url', hideDefaultActions: true, wrapText: true,
            typeAttributes: {
                label: {
                    fieldName: 'actionName'
                },
                target : '_blank'}
        },
        { label : 'Validation', fieldName : 'validation', type: 'text', wrapText: true, hideDefaultActions: true,
            cellAttributes:{
                class: {
                    fieldName: 'styleFormat'
                }
            }
        }
    ];

    @track simpleRows;
    @track complexRows;
    @track actionsRows;
    @track showSpinner = false;

    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    connectedCallback() {
        this.showSpinner = true;
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            if(this.recordId){
                this.verifyQueriesAndActionsInvoke();
            }
        }, 0);
    }

    verifyQueriesAndActionsInvoke(){
        verifyQueriesAndActions({recordId : this.recordId})
            .then(result => {
                this.parseResponse(result);
                this.showSpinner = false;
            })
            .catch(error => {
                console.log(error);
            });
    }

    parseResponse(data){
        let complexRows = [];
        let simpleRows = [];
        let actionsRows = [];
        JSON.parse(data).forEach(element =>{
            if(element.isSimple && element.type == 'Query'){
                simpleRows.push(element);
            }else if(!element.isSimple && element.type == 'Query'){
                complexRows.push(element);
            }else if(element.type == 'Action'){
                actionsRows.push(element);
            }
        });

        this.showSpinner = false;
        if(complexRows.length > 0){
            this.complexRows = complexRows;
        }
        if(simpleRows.length > 0){
            this.simpleRows = simpleRows;
        }
        if(actionsRows.length > 0){
            this.actionsRows = actionsRows;
        }
    }
}