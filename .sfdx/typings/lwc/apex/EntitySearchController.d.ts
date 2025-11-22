declare module "@salesforce/apex/EntitySearchController.getSearchResults" {
  export default function getSearchResults(param: {filterList: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/EntitySearchController.fetchVariantValues" {
  export default function fetchVariantValues(param: {modelValueString: any}): Promise<any>;
}
declare module "@salesforce/apex/EntitySearchController.getSearchDealerResults" {
  export default function getSearchDealerResults(param: {filterList: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/EntitySearchController.createOpportunity" {
  export default function createOpportunity(param: {LeadId: any, productIds: any}): Promise<any>;
}
declare module "@salesforce/apex/EntitySearchController.createDealerOpportunity" {
  export default function createDealerOpportunity(param: {LeadId: any, dealerIds: any, selectedMake: any, selectedModel: any}): Promise<any>;
}
declare module "@salesforce/apex/EntitySearchController.getDependentMap" {
  export default function getDependentMap(param: {objDetail: any, contrfieldApiName: any, depfieldApiName: any}): Promise<any>;
}
