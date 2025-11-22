({
	/**
	 * Map of pre-chat field label to pre-chat field name (can be found in Setup)
     * To before the chatbot start getting the fields values
	 */
    fieldLabelToName: {
        "First Name": "FirstName",
        "Last Name": "LastName",
        "Phone": "Phone", 
    },
    
    /**
	 * Event which fires the function to start a chat request (by accessing the chat API component)
	 *
	 * @param cmp - The component for this state.
	 */
    onStartButtonClick: function(cmp) {
        var prechatFieldComponents = cmp.find("prechatField");
        console.log('***',prechatFieldComponents);
        var fields;
        
        // Make an array of field objects for the library
        fields = this.createFieldsArray(prechatFieldComponents);
        var startChat = true; 
        //var letters = /^[A-Za-z]+[A-Za-z ]*$/;
        var letters = /^[A-Za-z ]{1,20}$/;
        var numbers = /^[6-9]{1}[0-9]{9}$/;
        console.log('before assign fields final display ***',fields);
        fields[0].value = cmp.get('v.firstNameAtt');
        fields[1].value = cmp.get('v.lastNameAtt');
        fields[2].value = cmp.get('v.phoneNumAtt');
        console.log('fields final display ***',fields);
        
        // If the pre-chat fields pass validation, start a chat
       if(cmp.find("prechatAPI").validateFields(fields).valid) {
            if(fields[0].value.match(letters) && startChat == true)
            {
                startChat = true;
                if(fields[1].value.match(letters) && startChat == true)
                {
                    startChat = true;
                    if(fields[2].value.match(numbers) && startChat == true)
                    {
                        startChat = true;
                    }else{
                        console.log('***inside second error**');
                        console.warn("did not pass validation!");
                        cmp.set('v.showErrorMessageFirstName',false);     
                        cmp.set('v.showErrorMessageForLastName',false); 
                        cmp.set('v.showErrorMessageForPhoneNumber',true);
                        
                        startChat = false;
                    }
                }else{
                    console.log('***inside second error**');
                    console.warn("did not pass validation!");
                    cmp.set('v.showErrorMessageFirstName',false); 
                    cmp.set('v.showErrorMessageForPhoneNumber',false);
                    cmp.set('v.showErrorMessageForLastName',true); 
                    
                    startChat = false;
                }
            }else{
                console.log('***inside first error**');
                startChat = false;
                console.log('**startChat**',startChat);
                console.warn("did not pass validation!");
                cmp.set('v.showErrorMessageForLastName',false); 
        		cmp.set('v.showErrorMessageForPhoneNumber',false);
                cmp.set('v.showErrorMessageFirstName',true);  
                
            }
            console.log('**startChat value**',startChat);
            
         
            if(startChat == true)
            {
              cmp.find("prechatAPI").startChat(fields);  
            }else
            {
                console.warn("Prechat fields did not pass validation!");
            }
            
        } else {
            console.warn("Prechat fields did not pass validation!");
        }
	},
    
    /**
	 * Create an array of field objects to start a chat from an array of pre-chat fields
	 * 
	 * @param fields - Array of pre-chat field Objects.
	 * @returns An array of field objects.
	 */
    createFieldsArray: function(fields) {
        if(fields.length) {
            return fields.map(function(fieldCmp) {
                return {
                    label: fieldCmp.get("v.label"),
                    value: fieldCmp.get("v.value"),
                    name: this.fieldLabelToName[fieldCmp.get("v.label")]
                };
            }.bind(this));
        } else {
            return [];
        }
    },
    
    /**
     * Create an array in the format $A.createComponents expects
     * 
     * Example:
     * [["componentType", {attributeName: "attributeValue", ...}]]
     * 
	 * @param prechatFields - Array of pre-chat field Objects.
	 * @returns Array that can be passed to $A.createComponents
     */
    getPrechatFieldAttributesArray: function(prechatFields) {
        // $A.createComponents first parameter is an array of arrays. Each array contains the type of component being created, and an Object defining the attributes.
        var prechatFieldsInfoArray = [];
        
        // For each field, prepare the type and attributes to pass to $A.createComponents
        prechatFields.forEach(function(field) {
            var componentName = (field.type === "inputSplitName") ? "inputText" : field.type;
            var componentInfoArray = ["ui:" + componentName];
            var attributes = {
                "aura:id": "prechatField",
                required: field.required,
                label: field.label,
                disabled: field.readOnly,
                maxlength: field.maxLength,
                class: field.className,
                value: field.value
            };
            
            // Special handling for options for an input:select (picklist) component
            if(field.type === "inputSelect" && field.picklistOptions) attributes.options = field.picklistOptions;
            
            // Append the attributes Object containing the required attributes to render this pre-chat field
            componentInfoArray.push(attributes);
            
            // Append this componentInfoArray to the fieldAttributesArray
            prechatFieldsInfoArray.push(componentInfoArray);
        });
        
        return prechatFieldsInfoArray;
    },
})