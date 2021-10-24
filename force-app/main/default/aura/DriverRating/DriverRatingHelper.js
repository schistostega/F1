({
	getDrivers : function(component, event, helper) {
		const action = component.get("c.getTop5Drivers");
        action.setCallback(this, function(response) {
            component.set("v.drivers", response.getReturnValue());
        });
        
        $A.enqueueAction(action);
	}
})