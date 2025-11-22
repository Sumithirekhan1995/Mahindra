({
	doLoad : function(component, event) {
		var recordId = component.get("v.recordId");
        console.log('a');
        var action = component.get("c.getTemplate");
        console.log('b');
        action.setParams({
            recId : recordId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var wap = response.getReturnValue();
                if(wap != null && wap != undefined){
                    //component.set("v.templateText",wap.Template);
                    var arrObj=[];
                    let objectMap = new Map();
                    for(var i=0; i<wap.length; i++){
                        
                        arrObj.push({label: wap[i].templateName,value: wap[i].templateId});
                        objectMap.set(wap[i].templateId, wap[i].templateBody);
                     
                    }
                        component.set("v.objectNames", arrObj);
                    component.set("v.objectMap",objectMap);
                }
            }
        });
        $A.enqueueAction(action);
	},
    doGetContacts : function(component, event) {
		var recordId = component.get("v.recordId");
        console.log('a');
        var action = component.get("c.getContacts");
        console.log('b');
        action.setParams({
            recId : recordId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var wap = response.getReturnValue();
                if(wap != null && wap != undefined){
                    var arrObj=[];
                    let objectMap = new Map();
                    for(var i=0; i<wap.length; i++){
                        
                        arrObj.push({label: wap[i].contactName +' '+wap[i].contactType,value: wap[i].phoneNumber});
                        //contactMap.set(wap[i].phoneNumber, wap[i].templateBody);
                     
                    }
                    console.log('arrObj: '+arrObj);
                     component.set("v.contactNames", arrObj);
                    //component.set("v.objectMap",objectMap);
                }
            }
        });
        $A.enqueueAction(action);
	},
    createLog : function(component,event){
        console.log('calling apex');
        /*var smsCheck = false;
        var waCheck = false;
        var msgType = component.get("v.checkboxValue");
        for(var i=0;i<msgType.length;i++){
            if(msgType[i] == 'SMS'){
                smsCheck = true;
            }
            if(msgType[i] == 'Whatsapp'){
                waCheck = true;
            }
        }*/
        var action = component.get("c.createSMSLog");
        console.log('b');
        action.setParams({
            recId : component.get("v.recordId"),
            templateId : component.get("v.objLabel"),
            smsBody : component.get("v.templateText"),
            phoneNumber : component.get("v.selectedPhone")//,
            //sms : smsCheck,
            //wa : waCheck
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                console.log('apex success');
                
                if(response.getReturnValue() == 'Success'){
                    $A.get('e.force:refreshView').fire();
                    this.showToast(component, event, 'SMS Sent!', 'Success','Success');
                }
            }
        });
        $A.enqueueAction(action);
    },
    showToast:function(component,event,str,type,title) {
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":type,
            "title": title,
            "message": str

        });
        toastEvent.fire();
        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
		dismissActionPanel.fire();
    }
})