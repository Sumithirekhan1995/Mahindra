public class DealerStockProcessController {
   
    
    //Method to parse Stock Data and upsert it
    public static Boolean processStockData(HttpResponse Response, String uniqueCode){
        try {
            System.debug('DealerStockProcessController.processStockData::');
            System.debug('Response: ' + response.getBody());
            List<Product2> StocksToUpsert = new List<Product2>();
            List<Photo__c> PhotosToUpsert = new List<Photo__c>();
            Set<String> dealerIdSet = new Set<String>();
            Map<String,Id> dealerMap = new Map<String,Id>();
            String dealerRtId = AccountConstants.dealerAccountRecordTypeId;
            
            StockFromMFC results = (StockFromMFC)JSON.deserialize(response.getBody(),StockFromMFC.class);
            
            // 11Oct2021:Sarthak:Start
            System.debug('StockFromMFC: ' + results);
            if(results.Stocks.size() == 0) {
                FinanceLeadCallout.notifyError('StockPullFromDMS', 'Response Stock Empty. Results: ' + results);
                LogService.createApiLogs('StockPullFromDMS', 'REQUEST_METHOD_GET', 'Response Stock Empty. response: ' + response, 'Failed' , 'Stock Pull API');
                return false;
            }
            // 11Oct2021:Sarthak:End
            
            for (cls_Stocks item: results.Stocks) {
                dealerIdSet.add(item.Dealer_Code);
            }
            System.debug('dealerIdSet: ' + dealerIdSet);
            for(Account acc : [select id, Code__c  from Account where Code__c in:dealerIdSet And RecordTypeId = :dealerRtId]){
                dealerMap.put(acc.Code__c, acc.Id);
            }
            System.debug('dealerMap: ' + dealerMap);
            
            // 6Dec2021:Sarthak ::  Added Array of Stocks to prevent record lock issue
            List<String> productIdsToBeUpdated = new List<String>();
            
            for (cls_Stocks item: results.Stocks) {
               
                productIdsToBeUpdated.add(String.valueOf(item.StockID));  // 6Dec2021:Sarthak
                
                Product2 stock = new Product2();
                stock.Name = item.Model + '-' + item.StockID;
                stock.IsActive = true;
                stock.Name_of_the_Dealer__c = item.Dealer_Name;
                if(dealerMap.get(item.Dealer_Code) != null)
                    stock.Dealer_Name__c = dealerMap.get(item.Dealer_Code);
                stock.Stock_ID__c = String.valueOf(item.StockID);
                stock.Make__c = item.Make;
                stock.Model__c = item.Model;
                stock.Variant__c = item.Variant;
                stock.Body_Type__c = item.BodyType;
                stock.Model_Year__c = String.valueOf(item.Manufacturing_Date.year());
                stock.Model_Month__c = String.valueOf(item.Manufacturing_Date.month());
                stock.Registration_Date__c = item.Registration_Date;
                stock.Registration_Number__c = item.Registration_Number;
                stock.Registration_City__c = item.Registration_City;
                stock.No_of_Owners__c = item.owners;
                stock.Insurance__c = item.Insurance;
                stock.Insurance_Expiry_Date__c = item.Insurance_Expiry_Date;
                stock.Expected_Price__c = item.Selling_Price;
                stock.Kilometer__c = item.Kilometers_Driven;
                if(item.Fuel != null)
                    stock.Fuel__c = item.Fuel;
                if(item.FuelType != null)
                    stock.Fuel__c = item.FuelType;
                stock.Color__c = item.colour;
                //stock.Comments__c = item.Comment;
                stock.MFC_Dealer_Code__c = item.Dealer_Code;
                stock.IsCertified__c = item.Is_Certified;
                stock.Warranty_Recommended__c = item.Warranty_recommended;
                stock.Stock_URL__c = item.stock_url;
                stock.DisplayUrl = item.photo_url;
                stock.TransmissionType__c = item.TransmissionType;
                stock.UniqueCode__c = uniqueCode;
                if(item.Photos != null){
                    stock.Photo_Count__c = item.Photos.count != null ? item.Photos.count : 0;
                    for(cls_Photo photo : item.Photos.Photo){
                        Photo__c newPhoto = new Photo__c();
                        newPhoto.Name = item.StockID + '-' + photo.Sn;
                        newPhoto.Serial_Number__c = photo.Sn;
                        newPhoto.Cover__c = photo.Cover;
                        newPhoto.Text__c = photo.Text;
                        newPhoto.Stock_ID__c = String.valueOf(item.StockID);
                        PhotosToUpsert.add(newPhoto);
                    }
                }
                StocksToUpsert.add(stock);
            }
            if(StocksToUpsert.isEmpty()) {
                return false;
            }
            System.debug('StocksToUpsert: ' + StocksToUpsert.size());
            
            // upserting products records
            Integer productUpdatedCount = 0;
            List<Api_Log__c> apiLogs = new List<Api_Log__c>();
            if(true) { 
                Schema.SObjectField field = Product2.fields.Stock_ID__c;
                Database.UpsertResult[] result = Database.upsert(StocksToUpsert, field, false);
                for(Database.UpsertResult res : result){
                    if(!res.isSuccess()){
                        System.debug('__failed at Product2 Database.upsert');
                        for(Database.Error err : res.getErrors()){
                            System.debug('Database.Error: ' + err);
                            String failedRec = err.getMessage()+ ' '+err.getFields();
                            apiLogs.add(LogService.createApiLogs(failedRec, 'Failed', 'Stock Records Failed'));
                        }
                    } else {
                        productUpdatedCount++;
                    }
                }
            }
            
            // upserting products photos records
            System.debug('PhotosToUpsert: ' + PhotosToUpsert.size());
            if(!PhotosToUpsert.isEmpty()){ 
                Schema.SObjectField field = Photo__c.fields.Name;
                Database.UpsertResult[] result = Database.upsert(PhotosToUpsert, field, false);
            }
            System.debug('productIdsToBeUpdated: ' + productIdsToBeUpdated);
            List<Product2> prodList = [Select Id from Product2 Where UniqueCode__c != :uniqueCode AND Stock_ID__c NOT IN :productIdsToBeUpdated AND IsActive = true];
            if(!prodList.isEmpty()) { 
                for(Product2 prod : prodList){
                    prod.IsActive = false;
                }
                // 11Oct2021:Sarthak:Start, Added prodList size check.
                System.debug('Product:IsActive = false, for Products ' + prodList.size());
                
                update prodList; // already there           
                // 11Oct2021:Sarthak:End
            }
            System.debug('UPDATED_PRODUCT_COUNT: ' + productUpdatedCount);
            
            if(!apiLogs.isEmpty()){
                LogService.createApiLogs(apiLogs);
            }
            return true;
        } catch(Exception e) {
            System.debug('Exception: ' + e);
            
            // 3Dec2021:Sarthak:Start
            String exceptionMsg = 'EXCEPTION: Type: ' + e.getTypeName() + ', Message: ' +  e.getMessage() + ' at Line: ' + e.getLineNumber();
            String statusMsg = e.getTypeName();           
            
            LogService.createApiLogs('StockPullFromDMS', 'REQUEST_METHOD_GET', exceptionMsg, 'Failed' , 'Stock Pull API');
            FinanceLeadCallout.notifyError('StockPullFromDMS', exceptionMsg);
            
            // 3Dec2021:Sarthak:End
            return false;
        } 
    }
    public static decimal convertToDecimal(String location){
        return null;
    }
    /****************************Dealer Wrapper - Begin*********************************/
    public class DealerFromMFC{
        public String status;	
        public String message;	
        public cls_data[] data;
        
        public DealerFromMFC parse(String json){
            return (DealerFromMFC) System.JSON.deserialize(json, DealerFromMFC.class);
        }
    }
    class cls_Data {	
        public String Code;	
        public String Name;	
        public String Address;	
        public String ContactName;	
        public String Pincode;	
        public String City;	
        public String State;	
        public String Mobile;	
        public String DealerContact;	
        public String Latitude;	
        public String Longitude;	
        public String Email;	
        public String SellingEmail;	
        public String AreaManagerName;
        public String AreaManagerMobileNumber;
        public String ZMName;
        public String ZMMobileNumber;
        public String ExotelNumber;
        
        // 16Nov2021:Sarthak:Start
        public String AreaManagerEmail;
        public String Zone;
        public String ZMEmail;
        public String StateHeadEmail;
        public String SMName;
        public String StateHeadMobileNumber;
        // 16Nov2021:Sarthak:End
        
        public cls_DealerSalesExecutives[] DealerSalesExecutives;	
        public cls_DealerProcurementExecutives[] DealerProcurementExecutives;	
    }	
    class cls_DealerSalesExecutives {	
        public String ExecutiveName;	
        public String ExecutiveMobile;	
    }	
    class cls_DealerProcurementExecutives {	
        public String ExecutiveName;	
        public String ExecutiveMobile;	
    }
    
    public class StockFromMFC{
        public cls_Stocks[] Stocks;
        public StockFromMFC parse(String json){
            return (StockFromMFC) System.JSON.deserialize(json, StockFromMFC.class);
        }
    }
    public class cls_Photo {
        public String Sn;	
        public Boolean Cover;
        public String Text;
    }
    public class cls_Photos {
        public cls_Photo[] Photo;
        public Decimal Count;
    }
    public class cls_Stocks {	
		public Integer StockID;	
		public String Make;	
		public String Model;	
		public String Variant;	
		public DateTime Manufacturing_Date;	
		public DateTime Registration_Date;	
		public String Registration_Number;	
		public Integer Selling_Price;	
		public String Dealer_Code;	
		public String Dealer_Name;	
		public String Registration_City;	
		public Integer Kilometers_Driven;	
		public String Is_Certified;	
        public String Warranty_recommended;
		public Integer owners;	
		public String Insurance;	
		public DateTime Insurance_Expiry_Date;	
		public DateTime Modified_Date;
		public String colour;
        public String Fuel;	
        public String BodyType;	
        public String FuelType;	
        public String stock_url;
        public String photo_url;
        public String TransmissionType;
        public cls_Photos Photos;
	}
   
}