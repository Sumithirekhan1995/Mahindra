declare module "@salesforce/apex/SMSDisplayControllerWarranty.getTemplate" {
  export default function getTemplate(param: {recId: any}): Promise<any>;
}
declare module "@salesforce/apex/SMSDisplayControllerWarranty.getContacts" {
  export default function getContacts(param: {recId: any}): Promise<any>;
}
declare module "@salesforce/apex/SMSDisplayControllerWarranty.createSMSLog" {
  export default function createSMSLog(param: {recId: any, templateId: any, smsBody: any, phoneNumber: any}): Promise<any>;
}
