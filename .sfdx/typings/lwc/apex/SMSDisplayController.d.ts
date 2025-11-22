declare module "@salesforce/apex/SMSDisplayController.getTemplate" {
  export default function getTemplate(param: {recId: any}): Promise<any>;
}
declare module "@salesforce/apex/SMSDisplayController.getContacts" {
  export default function getContacts(param: {recId: any}): Promise<any>;
}
declare module "@salesforce/apex/SMSDisplayController.createSMSLog" {
  export default function createSMSLog(param: {recId: any, templateId: any, smsBody: any, phoneNumber: any}): Promise<any>;
}
