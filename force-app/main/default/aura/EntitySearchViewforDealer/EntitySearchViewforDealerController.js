({
    init: function(component, event, helper) {
        
       
        
    },
    //Added by Aravindan Date : 14/5/2020
    setStockOrDealerToNull: function (component, event, helper){
        console.log('Testing' + event.getParam("searchType"));
        component.set("v.searchType", event.getParam("searchType"));
        console.log('Button Name' + event.getParam("ButtonName")); 
        component.set("v.pageOnLoadStock",false);
        component.set("v.pageOnLoadDealer",false);
        var ButtonName = event.getParam("ButtonName");
        console.log('fetch search Type Value ' + component.get('v.searchType'));
        if(ButtonName === 'reset')
        {
            console.log('entering into if condition');
            var emptyList = [];
            component.set("v.showDealerList",false);
            component.set("v.showStockList",false);
            component.set('v.productList',emptyList);
            component.set('v.dealerList',emptyList); 
        }
        else if(component.get("v.searchType") == 'Dealer'){
             component.set("v.showDealerList",true);
             component.set("v.showStockList",false);
             var emptyList = [];
            // component.set('v.dealerList',emptyList);
             component.set('v.productList',emptyList);
         }else{
             component.set("v.showDealerList",false);
             component.set("v.showStockList",true);
             var emptyList = [];
             component.set('v.dealerList',emptyList);
             //component.set('v.productList',emptyList);
             
         }
   
    },
    
    handleSearchEventChange: function (component, event, helper) { 
        console.log(event.getParam("fuel"));
        console.log('ssssssssssssssssssssssssssssss'+component.get("v.spinner"));
        var pageSize = component.get('v.pageSize');
        component.set("v.pageOnLoadStock",true);
        component.set("v.pageOnLoadDealer",true);
        component.set("v.recordId",event.getParam("LeadId"));
        component.set("v.spinner", true);
  
        var obj2={
            "spinner" : event.getParam("spinner"),
            "makeList" : event.getParam("make"),
            "modelList" : event.getParam("model"),
            "variantList" : event.getParam("variant"),
            "bodyList" : event.getParam("bodyType"),
            "fuelList" : event.getParam("fuel"),
            "colorList" : event.getParam("color"),
            "modelYearList" : event.getParam("modelYear"),
            "modelMonthList" : event.getParam("modelMonth"),
            "certifiedList" : event.getParam("certifed"),
            "dealerList" : event.getParam("dealerName"),
            "cityList" : event.getParam("city"),
            "pincodeList" : event.getParam("pincode"),
            "minKm" : event.getParam("minKmFilter"),
            "maxKm" : event.getParam("maxKmFilter"),
            "minBudget" : event.getParam("minBudgetFilter"),
            "maxBudget" : event.getParam("maxBudgetFilter")
            
        };
        console.log(obj2);
        console.log('STINGIFY ' +  JSON.stringify(obj2));
        component.set("v.searchType", event.getParam("searchType"));
        if(component.get("v.searchType") == 'Dealer'){
            component.set("v.showDealerList",true);
            component.set("v.showStockList",false);
            component.set("v.selectedMake", event.getParam("selectedMake"));
            component.set("v.selectedModel", event.getParam("selectedModel"));
        } else{
            component.set("v.showDealerList",false);
            component.set("v.showStockList",true);
        }
        console.log('obj2'+obj2);
        var action;
        if(component.get("v.searchType") == 'Stock'){
            action = component.get("c.getSearchResults");
        } else{
            action = component.get("c.getSearchDealerResults");
        }
        action.setParams({
            "filterList" : JSON.stringify(obj2)
        });
        action.setCallback(this, function(response){
            var state = response.getState(); // get the response state
            console.log('** State : '+state);
            if(state == 'SUCCESS') {
                console.log('sample: '+response.getReturnValue());
                console.log('component.get("v.searchType")' + component.get("v.searchType"));
                if(component.get("v.searchType") == 'Stock'){
                    component.set("v.productList1", response.getReturnValue());
                    component.set('v.totalSize', component.get('v.productList1').length);
                    
                    component.set('v.start',0);
                    component.set('v.end',pageSize-1);
                    var pList = component.get('v.productList1');
                    var paginationList = [];
                    var lastSize = 0;
                    for(var i=0; i< pageSize; i++)   
                    {
                        if(pList[i] != undefined){
                           pList[i].check = false;
                           paginationList.push(pList[i]); 
                        }
                        //paginationList.push(response.getReturnValue()[i]);
                        lastSize = i;
                    }
                    if(pList[lastSize+1] == undefined){
                     component.set("v.disableNext",true);
                   }
                    component.set('v.productList', paginationList); 
                    component.set('v.spinner',false);
                       
                }else{
                   component.set("v.dealerList1", response.getReturnValue());
                     component.set('v.totalSize', component.get('v.dealerList1').length);
                    component.set('v.start',0);
                    component.set('v.end',pageSize-1);
                    var lastSize = 0;
                    var paginationList = [];
                    for(var i=0; i< pageSize; i++)   
                    {
                        console.log('RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR'+response.getReturnValue()[i]);
                        if(response.getReturnValue()[i] != undefined)
                        paginationList.push(response.getReturnValue()[i]);
                        lastSize = i;
                    } 
                    if(response.getReturnValue()[lastSize+1] == undefined){
                     component.set("v.disableNextDealer",true);
                   }
                    component.set('v.dealerList', paginationList); 
                    component.set('v.spinner',false);
                    
                }
                
                console.log(response.getReturnValue().length);
               
            }
        });
        $A.enqueueAction(action);
    },
    handleSelectAllProduct: function(component, event, helper) {
        var getID;
        if(component.get("v.searchType") == 'Stock'){
            getID = component.get("v.productList");
        }else{
            getID = component.get("v.dealerList");
        }
        
        var checkvalue = component.find("selectAll").get("v.value");        
        var checkProduct = component.find("checkProduct"); 
        if(checkvalue == true){
            for(var i=0; i<checkProduct.length; i++){
                checkProduct[i].set("v.value",true);
            }
        }
        else{ 
            for(var i=0; i<checkProduct.length; i++){
                checkProduct[i].set("v.value",false);
            }
        }
    },
    handleSelectedProducts: function(component, event, helper) {
        var selectedProducts = [];
        var checkvalue = component.find("checkProduct");
        var productList = component.get("v.productList1");
       	var count = 0;
        console.log('productList'+productList);
        
        /*if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value") == true) {
                count = count + 1;
                selectedProducts.push(checkvalue.get("v.text"));
            }
        }else{
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {
                    count = count + 1;
                    selectedProducts.push(checkvalue[i].get("v.text"));
                }
            }
        }*/
        for(var i =0; i < productList.length;i++){
            if(productList[i].check == true){
                selectedProducts.push(productList[i].Id);
            }
        }
        console.log('selectedProducts'+selectedProducts);
        if( selectedProducts.length < 1)
        {
            component.set('v.ifNotSelected',true);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error Message',
                message:'No records Selected',
               // messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
        else{
        console.log('selectedProducts-' + selectedProducts);
        var action = component.get("c.createLeadDispatches");
        action.setParams({
            "LeadId" : component.get("v.recordId"),
            "productIds" : selectedProducts
        });
        action.setCallback(this, function(response){
            var state = response.getState(); // get the response state
            console.log('State : '+state);
            if(state == 'SUCCESS') {
                console.log("records saved");
                window.location.reload();
            }
        });
        $A.enqueueAction(action);
        }
    },
    handleSelectedDealers: function(component, event, helper) {
        var selectedDealers = [];
        var checkvalue = component.find("checkProduct");
       var dealerList = component.get("v.dealerList1");
         /*if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value") == true) {
                selectedDealers.push(checkvalue.get("v.text"));
            }
        }else{
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {
                    selectedDealers.push(checkvalue[i].get("v.text"));
                }
            }
        } */
        
        for(var i =0; i < dealerList.length;i++){
            if(dealerList[i].check == true){
                selectedDealers.push(dealerList[i].Id);
            }
        }
        if( selectedDealers.length < 1)
        {
            component.set('v.ifNotSelected',true);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error Message',
                message:'No records Selected',
               // messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }else{
        console.log('selectedDealers-' + selectedDealers);
        var action = component.get("c.createDealerLeadDispatches");
        action.setParams({
            "LeadId" : component.get("v.recordId"),
            "dealerIds" : selectedDealers,
            "selectedMake" : component.get("v.selectedMake"),
            "selectedModel" : component.get("v.selectedModel")
        });
        action.setCallback(this, function(response){
            var state = response.getState(); // get the response state
            console.log('State : '+state);
            if(state == 'SUCCESS') {
                console.log("records saved");
                window.location.reload();
            }
        });
        $A.enqueueAction(action);
        }
    },
    
    next : function(component, event, helper)
    {
        var pList = component.get('v.productList1');
        var end = component.get('v.end');
        var start = component.get('v.start');
        var pageSize = component.get('v.pageSize');
        var paginationList = [];
        var counter = 0;
        var lastSize = 0;
        for(var i=end+1; i<end+pageSize+1; i++) 
        {
            if(pList.length > end && pList[i] !==undefined)   
            {
                paginationList.push(pList[i]);
                counter ++ ;
            }
            lastSize = i;
        }
        if(pList.length > end && pList[lastSize+1] == undefined){
                component.set("v.disableNext",true);
            }
        start = start + counter; 
        end = end + counter;
        component.set('v.start',start);
        component.set('v.end',end);
        component.set('v.productList', paginationList);
        
    },
    previous : function(component, event, helper)
    {
        var pList = component.get('v.productList1');
        var end = component.get('v.end');
        var start = component.get('v.start');
        var pageSize = component.get('v.pageSize');
        var paginationList = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++) 
        {
            if(i > -1)   
            { 
                paginationList.push(pList[i]);
                counter++;
            }
            else {
                start++;
            }
        }
        start = start-counter;
        end = end-counter;
        component.set('v.start',start);
        component.set('v.end',end);
        component.set('v.productList', paginationList);
        component.set('v.disableNext', false);
    },
     nextDealer : function(component, event, helper)
    {
       // debugger;
        var pList = component.get('v.dealerList1');
        var end = component.get('v.end');
        var start = component.get('v.start');
        var pageSize = component.get('v.pageSize');
        var paginationList = [];
        var counter = 0;
        var lastSize = 0;
        for(var i=end+1; i<end+pageSize+1; i++) 
        {
            if(pList.length > end && pList[i] !==undefined)   
            {
                paginationList.push(pList[i]);
                counter ++ ;
            }
            lastSize = i;
        }
        console.log('pList[lastSize+1]'+ pList[lastSize+1]);
        if(pList[lastSize+1] == undefined){
           component.set("v.disableNextDealer",true);
        }
        console.log('end'+end);
        console.log('start'+start);
        
        start = start + counter;
        end = end + counter;
        component.set('v.start',start);
        component.set('v.end',end);
        console.log('end'+end);
        console.log('start'+start);
        console.log('total Size'+ component.get('v.pageSize'));
        console.log(' paginationList ' + paginationList);
        component.set('v.dealerList', paginationList);
        
    },
    previousDealer : function(component, event, helper)
    {
        var pList = component.get('v.dealerList1');
        var end = component.get('v.end');
        var start = component.get('v.start');
        var pageSize = component.get('v.pageSize');
        var paginationList = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++) 
        {
            if(i > -1)   
            { 
                paginationList.push(pList[i]);
                counter++;
            }
            else {
                start++;
            }
        }
        start = start-counter;
        end = end-counter;
        component.set('v.start',start);
        component.set('v.end',end);
        component.set('v.dealerList', paginationList);
        component.set('v.disableNextDealer', false);
    },

    makeTrue : function(component, event, helper){
      
        var myName = event.getSource().get("v.name");
        console.log('Event.'+myName);
		var proList = component.get("v.productList1");
        
        for(var i=0 ;i<proList.length;i++){
            if(proList[i].id == myName){
                proList[i].check = true;
                break;
            }
        }
        component.set("v.productList1",proList);
        
    },
     makeTrueDealer : function(component, event, helper){
      
        var myName = event.getSource().get("v.name");
        console.log('Event.'+myName);
		var DealerList = component.get("v.dealerList1");
        
        for(var i=0 ;i<DealerList.length;i++){
            if(DealerList[i].id == myName){
                DealerList[i].check = true;
                break;
            }
        }
        component.set("v.dealerList1",DealerList);
        
    }

})