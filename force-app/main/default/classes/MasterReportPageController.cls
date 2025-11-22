public class MasterReportPageController {
    public MasterReportPageController() {
        
    }
    public PageReference TillDateInbound() {
        PageReference pageRef = new PageReference('/apex/TillDateInbound?reportType=Till Date Inbound');
        pageRef.setRedirect(false);
        return pageRef;
    }
    public PageReference TillDateExotelData() {
        PageReference pageRef = new PageReference('/apex/TillDateExotelData?reportType=Till Date Car and Bike Exotel Data');
        //PageReference pageRef = Page.TillDateExotelData;
        pageRef.setRedirect(false);
        return pageRef;
    }
    public PageReference TillDateTollFree() {
        PageReference pageRef = new PageReference('/apex/TillDateTollFree?reportType=Till Date Toll Free');
        //PageReference pageRef = Page.TillDateExotelData;
        pageRef.setRedirect(false);
        return pageRef;
    }
    public PageReference ZoneMTD() {
        PageReference pageRef = new PageReference('https://mfcw.lightning.force.com/lightning/r/Report/00O5j000004lFlIEAU/view');
        pageRef.setRedirect(false);
        return pageRef;
    }
    public PageReference TillDateEcommerce() {
        //PageReference pageRef = new PageReference('https://mfcw--uat.lightning.force.com/lightning/r/Report/00O1s000000GrP0EAK/view?queryScope=userFolders');
        
        PageReference pageRef = new PageReference('/apex/TillDateEcomm');
        pageRef.setRedirect(false);
        return pageRef;
    }
    public PageReference TillDateHISellerF1() {
        PageReference pageRef = new PageReference('/apex/TillDateHISellerOutbound?reportType=Format1');
        pageRef.setRedirect(false);
        return pageRef;
    }
    public PageReference TillDateHISellerF2() {
        PageReference pageRef = new PageReference('/apex/TillDateHISellerOutbound?reportType=Format2');
        pageRef.setRedirect(false);
        return pageRef;
    }
    public PageReference TillDateHISellerF3() {
        PageReference pageRef = new PageReference('/apex/TillDateHISellerOutbound?reportType=Format3');
        pageRef.setRedirect(false);
        return pageRef;
    }
    public PageReference TillDateHISellerSummary() {
        PageReference pageRef = new PageReference('/apex/TillDateHISellerOutbound?reportType=Summary');
        pageRef.setRedirect(false);
        return pageRef;
    }
    
    public PageReference NewZoneReport() {
        PageReference pageRef = new PageReference('/apex/NewZoneReport');
        pageRef.setRedirect(false);
        return pageRef;
    }
    
    
}