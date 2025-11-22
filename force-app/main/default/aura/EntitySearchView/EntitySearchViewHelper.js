({
    loadList1: function(component) {  
        component.set("v.HideSpinnerRelevant", true);        
        var relevant = component.get("v.relevantSelect");
        var recordId = component.get("v.recordId");       
        var mBumi = component.get("v.bumi"); 
        var discount = component.get("v.discount");
        var ProjectSelect = component.get("v.ProjectSelect");      
        var PhaseSelect = component.get("v.PhaseSelect");      
        var LotSelect = component.get("v.LotSelect");    
        
        var bedRoomFilter = parseInt(component.get("v.bedRoomFilter"));
        var bathRoomFilter = parseInt(component.get("v.bathRoomFilter"));
        var sizeMFilter = parseInt(component.get("v.sizeMFilter"));     
        var sizeFilter = parseInt(component.get("v.sizeFilter"));     
        var budgetFilter = parseInt(component.get("v.budgetFilter")); 
        var mBedRoomFilter = parseInt(component.get("v.mBedRoomFilter"));     
        var mBathRoomFilter = parseInt(component.get("v.mBathRoomFilter"));    
        var mSizeMFilter = parseInt(component.get("v.mSizeMFilter"));   
        var mSizeFilter = parseInt(component.get("v.mSizeFilter")); 
        var mBudgetFilter = parseInt(component.get("v.mBudgetFilter"));
        
        var isGlobal = component.get("v.isGlobal");
        var LotStatus = component.get("v.LotStatus");
        
        var ProjectName = component.get("v.selectedProjectName");
        var PhaseName = component.get("v.selectedPhaseName");
        var LotName = component.get("v.selectedLotName");
        
        console.log('LotName'+LotName);
        console.log('LotStatus'+LotStatus);
        console.log('PhaseName'+PhaseName);
        
        var noId;
        var LowLevelList = [];
        var PhaseLevelList = [];
        var HighLevelList = [];
        //  var arrayOfMapKeys = [];
        
        
        var discountSelect = [];
        
        if(mBumi != component.get("v.defaultBumi"))
        {
            component.set("v.relevantSelect", []);
        }
        
        if(mBedRoomFilter < bedRoomFilter)
        {
            mBedRoomFilter = bedRoomFilter;
            component.set("v.mBedRoomFilter", bedRoomFilter);
        }
        
        if(mBathRoomFilter < bathRoomFilter)
        {
            mBathRoomFilter = bathRoomFilter;
            component.set("v.mBathRoomFilter", bathRoomFilter);
        }
        
        if(mSizeMFilter < sizeMFilter)
        {
            mSizeMFilter = sizeMFilter;
            component.set("v.mSizeMFilter", sizeMFilter);
        }
        
        if(mSizeFilter < sizeFilter)
        {
            mSizeFilter = sizeFilter;
            component.set("v.mSizeFilter", sizeFilter);
        }
        
        if(mBudgetFilter < budgetFilter)
        {
            mBudgetFilter = budgetFilter;
            component.set("v.mBudgetFilter", budgetFilter);
        }
        
        console.log("is Global ? "+isGlobal);
        
        var action = component.get("c.searchProperty");
        if(recordId)
        {       
            action.setParams({
                mOppId: recordId,
                bedRoomFilter: bedRoomFilter,
                bathRoomFilter: bathRoomFilter,
                sizeMFilter: sizeMFilter,
                sizeFilter: sizeFilter,
                budgetFilter: budgetFilter,
                mBedRoomFilter: mBedRoomFilter,
                mBathRoomFilter: mBathRoomFilter,
                mSizeMFilter: mSizeMFilter,
                mSizeFilter: mSizeFilter,
                mBudgetFilter: mBudgetFilter,
                mBumi: mBumi,
                mProjectId: ProjectSelect,
                mPhaseId: PhaseSelect,
                mLotId: LotSelect,
                lotStatus : LotStatus,
                isGlobal: isGlobal
            });
        }
        else
        {      
            action.setParams({
                mOppId: noId,
                bedRoomFilter: bedRoomFilter,
                bathRoomFilter: bathRoomFilter,
                sizeMFilter: sizeMFilter,
                sizeFilter: sizeFilter,
                budgetFilter: budgetFilter,
                mBedRoomFilter: mBedRoomFilter,
                mBathRoomFilter: mBathRoomFilter,
                mSizeMFilter: mSizeMFilter,
                mSizeFilter: mSizeFilter,
                mBudgetFilter: mBudgetFilter,
                mBumi: mBumi,
                mProjectId: ProjectSelect,
                mPhaseId: PhaseSelect,
                mLotId: LotSelect,
                lotStatus : LotStatus,
                isGlobal: isGlobal
            });
        }
        
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == 'SUCCESS')
            {	
                var result = response.getReturnValue();
                //QuickBooking
                if(component.get("v.displayButtonGenerateProposal") == false)
                {
                    if(LotSelect)
                    {
                        for(var i = 0; i<result.length; i++)
                        {
                            for(var j = 0; j<relevant.length;j++)
                            {
                                if(relevant[j] == result[i].Product2Id)
                                {
                                    result[i].Checkbox = true;
                                }
                            }
                        }                    
                    }
                }
                else if(component.get("v.isGlobal"))
                {
                    if(PhaseSelect)
                    {
                        PhaseLevelList.push(PhaseName);
                    }
                    else if(ProjectSelect)
                    {
                        var AllPhaseLevel = [];
                        for(var i = 0; i<result.length; i++)
                        {
                            
                            if(ProjectName == result[i].ProjectName)
                            {
                                AllPhaseLevel.push(result[i].PhaseName);
                                
                            }
                        }
                        
                        function onlyUnique(value, index, self) { 
                            return self.indexOf(value) === index;
                        }
                        
                        // usage example:
                        PhaseLevelList = AllPhaseLevel.filter(onlyUnique);
                        
                        
                    }
                        else{
                            var AllPhaseLevel =[];
                            for(var i = 0; i<result.length; i++)
                            {
                                AllPhaseLevel.push(result[i].PhaseName);
                            }
                          function onlyUnique(value, index, self) { 
                            return self.indexOf(value) === index;
                        }
                        // usage example:
                        PhaseLevelList = AllPhaseLevel.filter(onlyUnique);
                        }
                    if(PhaseLevelList.length>0)
                    {
                        for(var i = 0; i<PhaseLevelList.length; i++)
                        {
                            var HighLevelPhase = {};
                            HighLevelPhase.Phase = PhaseLevelList[i];
                            HighLevelPhase.Lot = [];
                            for(var j = 0; j<result.length; j++)
                            {
                                if(result[j].PhaseName == PhaseLevelList[i])
                                {
                                    HighLevelPhase.Lot.push(result[j]);
                                }
                            }
                            console.log('Lot Length: '+HighLevelPhase.Lot.length);
                            HighLevelList.push(HighLevelPhase);
                        }
                    }
                    component.set("v.PropertyHighLevelList",HighLevelList);
                }
                    else
                    {
                        if(relevant.length>0)
                        {                   
                            for(var i = 0; i<result.length; i++)
                            {
                                for(var j = 0; j<relevant.length;j++)
                                {
                                    if(relevant[j] == result[i].Product2Id)
                                    {
                                        result[i].Checkbox = true;
                                    }
                                }
                            }
                        }
                        if(result.length>0)
                        {
                            component.set("v.lotExisted", true);
                        }
                        else
                        {
                            component.set("v.discountSelect", []);
                            if(discount.length>0)
                            {
                                for(var i = 0; i<discount.length; i++)
                                {
                                    if(discount[i].Checkbox == true && discount[i].DiscountCategory != "Bumi")
                                    {
                                        discount[i].Checkbox = false;
                                    }
                                    if(discount[i].DiscountCategory == "Bumi")
                                    {
                                        discountSelect.push(discount[i].DiscountId);
                                    }
                                }
                                component.set("v.discount", discount);
                                component.set("v.discountSelect", discountSelect);
                            }
                            component.set("v.lotExisted", false);
                            
                        }
                    }
                console.log('result'+result);
                component.set("v.relevant", result);
                //component.set("v.relevant", []);
                
                if(recordId)
                {
                    component.set("v.TitleName",'Relevant Property ('+result.length+')');
                }
                else
                {
                    component.set("v.TitleName",'Matched Properties ('+result.length+')');
                }
            }
            component.set("v.HideSpinnerRelevant", false);
            
        });
        $A.enqueueAction(action); 
    }
})