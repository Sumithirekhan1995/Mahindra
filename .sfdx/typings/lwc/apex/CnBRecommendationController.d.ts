declare module "@salesforce/apex/CnBRecommendationController.getCarRecommendations" {
  export default function getCarRecommendations(param: {leaRecId: any}): Promise<any>;
}
declare module "@salesforce/apex/CnBRecommendationController.searchRecommendations" {
  export default function searchRecommendations(param: {searchParam: any, leaRecId: any}): Promise<any>;
}
declare module "@salesforce/apex/CnBRecommendationController.createLead" {
  export default function createLead(param: {selectedCars: any, recId: any, LeadSource: any}): Promise<any>;
}
declare module "@salesforce/apex/CnBRecommendationController.returnLead" {
  export default function returnLead(param: {leadRecId: any}): Promise<any>;
}
