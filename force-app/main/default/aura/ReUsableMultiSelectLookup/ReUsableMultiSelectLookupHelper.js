({
    searchHelper : function(component,event,getInputkeyWord) {
        // call the apex class method 
        var action = component.get("c.fetchLookUpValues");
        // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'ExcludeitemsList' : component.get("v.lstSelectedRecords"),
            'displayFieldAPIName' : component.get("v.fieldAPIName")
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Records Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Records Found...');
                } else {
                    component.set("v.Message", '');
                    // set searchResult list with return value from server.
                }
                
                
                console.log('recrods: ',storeResponse);
                var fieldName = component.get("v.fieldAPIName");
                console.log('field: ',fieldName);
                var obj = storeResponse;
                console.log('obj: ',obj);
                var items = [];
                
                for (var i = 0; i < obj.length; i++) {
                    var ob = obj[i];
                    console.log('obj ku4n: ',ob.Name);
                    var item = {
                        "Id": ob.Id,
                        "Name": ob[fieldName]
                    };
                    items.push(item);
                }
               
               var outputArray = []; 
          
                // Count variable is used to add the 
                // new unique value only once in the 
                // outputArray. 
                var count = 0; 
                  
                // Start variable is used to set true 
                // if a repeated duplicate value is  
                // encontered in the output array. 
                var start = false; 
                  
                for (var j = 0; j < items.length; j++) { 
                    for (var k = 0; k < outputArray.length; k++) { 
                        if ( items[j].Name == outputArray[k].Name) { 
                            start = true; 
                        } 
                    } 
                    count++; 
                    if (count == 1 && start == false) { 
                        outputArray.push(items[j]); 
                    } 
                    start = false; 
                    count = 0; 
                } 
                        
               console.log('item d: ',items);
                console.log('outputArray d: ',outputArray);
                component.set("v.listOfSearchRecords", outputArray); 
               //component.set("v.listOfSearchRecords", items); 
                
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
})