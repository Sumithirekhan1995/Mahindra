({
	doInit : function(component, event, helper) {
        console.log('bn');
		helper.doLoad(component, event);
        helper.doGetContacts(component, event);
	},
    onObjChange : function(component, event, helper){
        var objlabel = event.getParam("value");
        console.log('objLabel: '+objlabel);
        component.set("v.objLabel",objlabel);
        console.log('1');
        var objmp=component.get("v.objectMap");
        console.log('2'+objmp);
       
        console.log('MAP OUT PUT: '+objmp.get(objlabel));
        component.set('v.templateText', objmp.get(objlabel));
       
    },
    
    onClickSend : function(component, event, helper){
        console.log(component.get("v.checkboxValue"));
        console.log('creating sms log');
        
        var phoneNumber = component.get("v.selectedPhone");
        var templateId =  component.get("v.objLabel");
        var displayError = component.get("v.isError");
        
        if(phoneNumber == null){
            component.set("v.errorMessage","Please select the contact");
            component.find('objectPhoneVals').focus();
            displayError = true;
        } else if(templateId == null){
           	component.set("v.errorMessage","Please select the SMS template");
            component.find('objectVals').focus();
            displayError = true;
        } else if(templateId != null && phoneNumber != null){
            helper.createLog(component,event);
            displayError = false;
        }
        component.set("v.isError",displayError);
        
    },
    onPhoneChange : function(component, event, helper){
        var objlabel = event.getParam("value");
        component.set('v.selectedPhone', objlabel);
       
    }
})