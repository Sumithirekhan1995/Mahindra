/**
 * @File Name          : EntitySearchFilterHelper.js
 * @Description        : 
 * @Author             : Kunal Nadkarni
 * @Group              : 
 * @Last Modified By   : Kunal Nadkarni
 * @Last Modified On   : 4/17/2020, 10:10:44 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/17/2020   Kunal Nadkarni     Initial Version
**/
({
    SendSearchValue: function(component,event,helper)
    {  
        
        var UpdateSearchValues = $A.get("e.c:SearchRelevantEntityEvent");           
        var make = component.get("v.selectedMakeLookUpRecords");
        var model = component.get("v.selectedModelLookUpRecords");
        var variant = component.get("v.selectedVariantLookUpRecords");
        var bodyType = component.get("v.selectedBodyTypeLookUpRecords");
        var fuelType = component.get("v.selectedFuelLookUpRecords");
       // var fuelType = this.getSpecificValue(component.get("v.selectedFuelLookUpRecords"));
        var color = this.getSpecificValue(component.get("v.selectedColorLookUpRecords"));
        var modelYear = component.get("v.selectedModelYearLookUpRecords");
        var modelMonth = component.get("v.selectedModelMonthLookUpRecords");
        var certified = component.get("v.selectedCertifiedLookUpRecords");
       // var modelYear = this.getSpecificValue(component.get("v.selectedModelYearLookUpRecords"));
       // var modelMonth = this.getSpecificValue(component.get("v.selectedModelMonthLookUpRecords"));
       // var certified = this.getSpecificValue(component.get("v.selectedCertifiedLookUpRecords"));
        
        
        var minKmFilter = parseInt(component.get("v.minKmFilter"));
        var maxKmFilter = parseInt(component.get("v.maxKmFilter"));
        var minBudgetFilter = parseInt(component.get("v.minBudgetFilter"));
        var maxBudgetFilter = parseInt(component.get("v.maxBudgetFilter"));
        var selectedMake = component.get("v.selectedMake")
        var selectedModel = component.get("v.selectedModel")
        
        var dealerName = this.getSpecificValue(component.get("v.selectedDealerLookUpRecords"));
        var city = this.getSpecificValue(component.get("v.selectedCityLookUpRecords"));
        var pincode = this.getSpecificValue(component.get("v.selectedPincodeLookUpRecords"));
        var LeadRecordId = component.get("v.recordId");
        var searchType = component.get("v.searchType");
        
        console.log("hello!! ");
        console.log("hello 2!! ");
        console.log("make!! ",make);
        console.log("model!! ",model);
        console.log("dealerName!! ",dealerName);
        
        console.log("city!! ",city);
        console.log("pincode!! ",pincode);
        console.log("fuelType!! ",fuelType);
        
        console.log("MaxKilometer" , maxKmFilter);
        console.log("maxBudgetFilter",maxBudgetFilter)
    
        UpdateSearchValues.setParams({
            spinner : true,
          	make: make,
            model: model,
            variant : variant,
            bodyType: bodyType,
            fuel:fuelType,
            color:color,
            modelYear:modelYear,
            modelMonth:modelMonth,
            certifed:certified,
            city: city,
            pincode: pincode,
            dealerName: dealerName,
            minBudgetFilter: minBudgetFilter,
            maxBudgetFilter: maxBudgetFilter,
            minKmFilter: minKmFilter,
            maxKmFilter: maxKmFilter,
            LeadId : LeadRecordId,
            searchType : searchType,
            selectedMake : selectedMake,
            selectedModel : selectedModel
        });
        UpdateSearchValues.fire();
        
        

        var updateCarouselAttr = $A.get("e.c:CarouselComponentEvent");   
        updateCarouselAttr.setParams({
            projectName: "TestName"/*component.get("v.oldProjectNameTemp")*/,
            phaseName: "OldTestName"/*component.get("v.oldPhaseNameTemp")*/,
            cardTitle: "Phase Images" 
        });
        updateCarouselAttr.fire();
        console.log("bye!!");
    },
    
    getSpecificValue : function(itemList){
        var objList = [];
        console.log('old items: ',itemList);
        for(var i=0; i < itemList.length; i++){
            objList.push(itemList[i].Name);
        }
        console.log('new list: ',objList);
        return objList;
    },
    fetchPicklistValues: function(component,objDetails,controllerField, dependentField) {
        // call the server side function  
        var action = component.get("c.getDependentMap");
        // pass paramerters [object definition , contrller field name ,dependent field name] -
        // to server side function 
        action.setParams({
            'objDetail' : objDetails,
            'contrfieldApiName': controllerField,
            'depfieldApiName': dependentField 
        });
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var StoreResponse = response.getReturnValue();
                
                // once set #StoreResponse to depnedentFieldMap attribute 
                component.set("v.depnedentFieldMap",StoreResponse);
                
                // create a empty array for store map keys(@@--->which is controller picklist values) 
                var listOfkeys = []; // for store all map keys (controller picklist values)
                var ControllerField = []; // for store controller picklist value to set on lightning:select. 
                
                // play a for loop on Return map 
                // and fill the all map key on listOfkeys variable.
                for (var singlekey in StoreResponse) {
                    listOfkeys.push(singlekey);
                }
                
                //set the controller field value for lightning:select
                if (listOfkeys != undefined && listOfkeys.length > 0) {
                    ControllerField.push('--- None ---');
                }
                
                for (var i = 0; i < listOfkeys.length; i++) {
                    ControllerField.push(listOfkeys[i]);
                }  
                // set the ControllerField variable values to country(controller picklist field)
                component.set("v.listControllingValues", ControllerField);
            }else{
                alert('Something went wrong. Please contact your system administrator');
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchDepValues: function(component, ListOfDependentFields) {
        // create a empty array var for store dependent picklist values for controller field  
        var dependentFields = [];
        dependentFields.push('--- None ---');
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        // set the dependentFields variable values to store(dependent picklist field) on lightning:select
        component.set("v.listDependingValues", dependentFields);
        
    },
    
    //Added By Aravindan
    sendNullValues:function(component,event,ButtonName){ 
        component.set('v.selectedPincodeLookUpRecords',[]);
        var UpdateSearchValues = $A.get("e.c:setNull");
        var searchType1 = component.get('v.searchType');
        var ButtonNameReceived = ButtonName;
        console.log('Helper Search searchType' + searchType1);
        UpdateSearchValues.setParams({
            searchType : searchType1,
            ButtonName : ButtonNameReceived
        });
        UpdateSearchValues.fire();
  
    },
    //Added By: Aravindan A Date:18-05-2020
    returnListofYears :function(component,event,ButtonName){ 
       
        var dt = new Date();
        var currentYear = dt.getFullYear();
        var add = currentYear + 30;
        var listy = new Array((currentYear + 1) - (currentYear - 100)).fill().map((d, i)=> i + (currentYear - 100));
        var listOfYears = listy.reverse();
        component.set('v.ListOfYears',listOfYears);
    }
})