({
	getDrivers : function(component, event, helper) {
		const action = component.get("c.getTop5Drivers");
        // error handling
        action.setCallback(this, function(response) {
            const state = response.getState();
            
            if (state === 'SUCCESS') {
                component.set("v.isError", false);
                const drivers = response.getReturnValue();
                for (let driver of drivers) {
                    driver.url = `/lightning/r/Driver__c/${driver.Id}/view`;
                }
                component.set("v.drivers", drivers);
            } else if (state === 'ERROR') {
                component.set("v.isError", true);

                const errors = response.getError();
                if (errors) {
                    if (errors[0]) {
                        console.error(errors[0]);
                    }
                }
                
            }
        });
        
        $A.enqueueAction(action);
	}
})