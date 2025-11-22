({
    init: function(component, event, helper) {
        helper.returnListofYears(component);
        console.log('Init method entry');
        component.set("v.loaded", false);
        var leadId = component.get("v.recordId");
        component.set("v.SearchPressed", false);  
        
        var items = [];
        for (var i = 0; i < 500; i++) {
            var item = {
                "label": i + " Option",
                "value": i.toString()
            };
            items.push(item);
        }
        component.set("v.dealerNameOptions", items);
        
        component.set("v.loaded", true);
        component.set("v.HideSpinnerRelevant", false);
        var controllingFieldAPI = component.get("v.controllingFieldAPI");
        var dependingFieldAPI = component.get("v.dependingFieldAPI");
        var objDetails = component.get("v.objDetail");
        // call the helper function
        helper.fetchPicklistValues(component,objDetails,controllingFieldAPI, dependingFieldAPI);
        console.log('Init method exit');
    },    
    onControllerFieldChange: function(component, event, helper) {     
        var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        
        if (controllerValueKey != '--- None ---') {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
          // 	component.set("v.listDependingValues",[]);
            if(ListOfDependentFields.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields);    
            }else{
                component.set("v.bDisabledDependentFld" , true); 
                component.set("v.listDependingValues", ['--- None ---']);
            }  
            
        } else {
            component.set("v.listDependingValues", ['--- None ---']);
            component.set("v.selectedMakeLookUpRecords",[]);
            component.set("v.bDisabledDependentFld" , true);
        }
        
        component.set('v.selectedModelLookUpRecords',[]);
    },
    sliderUpdated: function(component, event, helper) {
        component.set("v.loaded", false);
        if(event.getParam("name") == 'Km')
        {
            component.set ("v.minKmFilter", event.getParam("minRange"));
            component.set ("v.maxKmFilter", event.getParam("maxRange"));
            console.log('minKmFilter: '+component.get("v.minKmFilter"));
        }
        if(event.getParam("name") == 'Budget')
        {
            component.set ("v.minBudgetFilter", event.getParam("minRange"));
            component.set ("v.maxBudgetFilter", event.getParam("maxRange"));
        }
        component.set("v.loaded", true);  
        
    },
    
    isRefreshed: function(component, event, helper) {
        component.set("v.HideSpinnerRelevant",event.getParam("updateBooking"));
        component.set("v.HideSpinnerRelevant",false);
    }, 
    
    goSearchProperties : function(component,event,helper){      
        component.set("v.SearchPressed", true);
        component.set("v.spinner",true);
        console.log('selected Model: ',component.get("v.selectedModel"));
        console.log('selected Make: ',component.get("v.selectedMake"));
        console.log('selected Certified : ' + component.get("v.selectedCertifiedLookUpRecords"));
        console.log('selected Fuel : ' + component.get("v.selectedFuelLookUpRecords"));
        console.log('selected TransmissionType : ' + component.get("v.selectedTransmissionTypeLookUpRecords"));
        console.log('selected ModelMonth :' + component.get("v.selectedModelMonthLookUpRecords"));
        console.log('selected ModelYear : ' + component.get("v.selectedModelYearLookUpRecords"));
        //console.log('selected state :' +component.get("v.selectedStateLookUpRecords"));
        helper.SendSearchValue(component); 
        
    },
    searchStock : function(component,event,helper){
        component.set("v.searchType","Stock"); 
        
         component.set("v.SearchPressed", true);
        component.set("v.spinner",true);
        console.log('selected Model: ',component.get("v.selectedModel"));
        console.log('selected Make: ',component.get("v.selectedMake"));
        console.log('selected Certified : ' + component.get("v.selectedCertifiedLookUpRecords"));
        console.log('selected Fuel : ' + component.get("v.selectedFuelLookUpRecords"));
        console.log('selected TransmissionType : ' + component.get("v.selectedTransmissionTypeLookUpRecords"));
        console.log('selected ModelMonth :' + component.get("v.selectedModelMonthLookUpRecords"));
        console.log('selected ModelYear : ' + component.get("v.selectedModelYearLookUpRecords"));
        //console.log('selected state :' +component.get("v.selectedStateLookUpRecords"));
        helper.SendSearchValue(component); 
    },
   searchDealer : function(component,event,helper){ 
        component.set("v.searchType","Dealer");
         console.log('Hello');
          component.set("v.SearchPressed", true);
        component.set("v.spinner",true);
        console.log('selected Model: ',component.get("v.selectedModel"));
        console.log('selected Make: ',component.get("v.selectedMake"));
        console.log('selected Certified : ' + component.get("v.selectedCertifiedLookUpRecords"));
        console.log('selected Fuel : ' + component.get("v.selectedFuelLookUpRecords"));
        console.log('selected TransmissionType : ' + component.get("v.selectedTransmissionTypeLookUpRecords"));
        console.log('selected ModelMonth :' + component.get("v.selectedModelMonthLookUpRecords"));
        console.log('selected ModelYear : ' + component.get("v.selectedModelYearLookUpRecords"));
        //console.log('selected state :' +component.get("v.selectedStateLookUpRecords"));
        helper.SendSearchValue(component); 
        console.log('Hello1');
    },    
        
    //Added by Aravindan A Date : 14/5/2020
    clear : function(component,event,helper){
       // window.location.reload();
      // $A.get('e.force:refreshView').fire();
     	component.set('v.selectedMakeLookUpRecords',[]);
        component.set('v.selectedModelLookUpRecords',[]);
        component.set('v.selectedVariantLookUpRecords',[]);
        component.set('v.selectedBodyTypeLookUpRecords',[]);
        component.set('v.selectedFuelLookUpRecords',[]);
        component.set('v.selectedTransmissionTypeLookUpRecords',[]);
        component.set('v.selectedColorLookUpRecords',[]);
        component.set('v.selectedModelYearLookUpRecords',[]);
        component.set('v.selectedModelMonthLookUpRecords',[]);
        component.set('v.selectedCertifiedLookUpRecords',[]);
        component.set('v.selectedPincodeLookUpRecords',[]);
        component.set('v.selectedCityLookUpRecords',[]);
        component.set('v.selectedStateLookUpRecords',[]);
        console.log('working till here');
        var ButtonName = event.getSource().getLocalId();
        helper.sendNullValues(component,event,ButtonName);
        
        //console.log('button lAbel' + event.getSource().getLocalId());
       // helper.sendNullValues(component);

       /* console.log('maxKmFilter111111111111111111' + component.get('v.maxKmFilter'));
        
        component.set('v.maxKmFilter',NUMBER(50000));
        component.set('v.maxBudgetFilter',NUMBER(500000));
        component.set('v.minBudgetFilter',NUMBER(0));
        component.set('v.minKmFilter',NUMBER(0)); */
        
        
    }, //Added by: Aravindan A on 18/5/2020
    clear1 : function(component,event,helper){
       // window.location.reload();
      // $A.get('e.force:refreshView').fire();
      // v.selectedModel v.selectedMake
      	component.set('v.selectedMake',[]);
        component.set('v.selectedModel',[]);
     	component.set('v.selectedDealerLookUpRecords',[]);
        component.set('v.selectedCityLookUpRecords',[]);
        component.set('v.selectedPincodeLookUpRecords',[]);
        var ButtonName = event.getSource().getLocalId();
        helper.sendNullValues(component,event,ButtonName);
    },
    
    handleChange: function (component, event, helper) {
        //Do something with the change handler 
        //alert(event.getParam('value'));
        component.set("v.searchType", event.getParam('value'));
        console.log("seached for: ",component.get("v.searchType"));
                      
    },
    tabOneActive: function(component, event, helper){
        component.set("v.searchType","Stock"); 
       
        console.log('Calling Helper Method' + component.get('v.searchType'));
        helper.sendNullValues(component);
    },
    tabTwoActive: function(component, event, helper){
        component.set("v.searchType","Dealer");
        console.log('Calling Helper Method' + component.get('v.searchType'));
        helper.sendNullValues(component);
       
    },
    makeTrueForVAriant : function(component, event, helper){
        var modelValue1 = component.find("ModelValue").get("v.value"); 
        if(modelValue1 == '--- None ---'){
            component.set("v.selectedModelLookUpRecords",[]);
        }else{
            if (typeof modelValue1 === "object" && modelValue1 && modelValue1[0]) {
                modelValue1 = modelValue1[0];
            }
            var action = component.get("c.fetchVariantValues");  
            console.log('modelValue1 = ' + modelValue1);
            action.setParams({
                'modelValueString' : modelValue1
               
            });
             action.setCallback(this, function(response){
                var state = response.getState(); // get the response state
                console.log('** State : '+state);
                if(state == 'SUCCESS') {
                    component.set('v.variantDisplay',false);
                    console.log(response.getReturnValue());
                    component.set('v.listDependingValuesVariants',response.getReturnValue());
                    
                }else{
                    console.log('Error from class');
                } 
             });
             $A.enqueueAction(action);
        }
        
    }

    
})