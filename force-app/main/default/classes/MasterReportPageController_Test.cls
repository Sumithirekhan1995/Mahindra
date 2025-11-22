@isTest
public class MasterReportPageController_Test {

    @isTest
    public static void test1()
    {
        MasterReportPageController mrt = new MasterReportPageController();
        mrt.TillDateEcommerce();
        mrt.TillDateInbound();
        mrt.TillDateExotelData();
        mrt.TillDateTollFree();
        mrt.ZoneMTD();
        mrt.TillDateHISellerF1();
        mrt.TillDateHISellerF2();
        mrt.TillDateHISellerF3();
        mrt.TillDateHISellerSummary();
        mrt.NewZoneReport();
    }
}