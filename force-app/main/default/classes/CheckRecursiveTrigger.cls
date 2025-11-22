// createdBy:Sarthak:10Sep
public class CheckRecursiveTrigger {
    
    private static Boolean isBatchFuture = false;
    
    public static void init() {
        isBatchFuture = System.isBatch() || System.isFuture();
    }
    
    private static boolean run = true;
    public static boolean runOnce(){
        System.debug('runOnce ' + run);
        init();
        if(run){
            run = false;
            return true;
        }else{
            return run;
        }
    }
    
    //13Sep2021:Sarthak:Start
    public static Boolean callMMFSL = true;
    public static Boolean runOnceMMFSL(){
        System.debug('runOnceMMFSL:' + callMMFSL);
        init();
        if(isBatchFuture) {
            System.debug('isBatchFuture');
            callMMFSL = false;
        }
        if(callMMFSL){
            callMMFSL = false;
            return true;
        } else {
            return callMMFSL;
        }
    }    
    
    public static Boolean callIBB = true;
    public static Boolean runOnceIBB(){
        System.debug('runOnceIBB:' + callIBB);
        init();
        if(isBatchFuture) {
            System.debug('isBatchFuture');
            callIBB = false;
        }
        if(callIBB) {
            callIBB = false;
            return true;
        } else {
            return callIBB;
        }
    }
    //13Sep2021:Sarthak:End  
    
    public static Boolean isLMSCallout = true;
    public static Boolean runOnceLMS(){
        System.debug('runOnceLMS: ' + isLMSCallout);
        init();
        if(isBatchFuture) {
            System.debug('isBatchFuture');
            isLMSCallout = false;
        }
        if(isLMSCallout){
            isLMSCallout = false;
            return true;
        } else {
            return isLMSCallout;
        }
    }
    
   // sumit start 
    public static Boolean isLMSOppCallout = true;
    public static Boolean runOnceOppLMS(){
        System.debug('runOnceOppLMS: ' + isLMSOppCallout);
        init();
        if(isBatchFuture) {
            System.debug('isBatchFuture');
            isLMSOppCallout = false;
        }
        if(isLMSOppCallout){
            isLMSOppCallout = false;
            return true;
        } else {
            return isLMSOppCallout;
        }
    }
    
    // Sumit Start CRM-1207
    public static Boolean isLMSReserveOppCallout = true;
    public static Boolean runOnceReserveOppLMS(){
        System.debug('runOnceReserveOppLMS: ' + isLMSReserveOppCallout);
        init();
        if(isBatchFuture) {
            System.debug('isBatchFuture');
            isLMSReserveOppCallout = false;
        }
        if(isLMSReserveOppCallout){
            isLMSReserveOppCallout = false;
            return true;
        } else {
            return isLMSReserveOppCallout;
        }
    }
    // Sumit End CRM-1207
       
    public static Boolean isCTICallout = true;
    public static Boolean runOnceCTI(){
        System.debug('runOnceCTI: ' + isCTICallout);
        init();
        if(isBatchFuture) {
            System.debug('isBatchFuture');
            isCTICallout = false;
        }
        if(isCTICallout){
            isCTICallout = false;
            return true;
        } else {
            return isCTICallout;
        }
    }
    
    public static Boolean isWhatsappMsgSent = true;
    public static Boolean runOnceWhatsappMsg(){
        System.debug('runOnceWhatsappMsg: ' + isWhatsappMsgSent);
        init();
        if(isBatchFuture) {
            System.debug('isBatchFuture');
            isWhatsappMsgSent = false;
        }
        if(isWhatsappMsgSent){
            isWhatsappMsgSent = false;
            return true;
        } else {
            return isWhatsappMsgSent;
        }
    }
    
    public static Boolean isOppElisionCallout = true;
    public static Boolean runOnceOppElision(){
        System.debug('isOppElisionCallout: ' + isOppElisionCallout);
        init();
        if(isBatchFuture) {
            System.debug('isBatchFuture');
            isOppElisionCallout = false;
        }
        if(isOppElisionCallout){
            isOppElisionCallout = false;
            return true;
        } else {
            return isOppElisionCallout;
        }
    }
    
    private static Boolean isOzontelCallout = true;
    public static Boolean runOnceOzontel(){
        System.debug('isOzontelCallout: ' + isOzontelCallout);
        init();
        if(isBatchFuture) {
            System.debug('isBatchFuture');
            isOzontelCallout = false;
        }
        if(isOzontelCallout){
            isOzontelCallout = false;
            return true;
        } else {
            return isOzontelCallout;
        }
    }
    //added by Mishal as a part of CRM-1040
    public static Boolean isCNBCallout = true;
    public static Boolean runOnceCNB(){
        System.debug('runOnceCNB: ' + isCNBCallout);
        init();
        if(isBatchFuture) {
            System.debug('isBatchFuture');
            isCNBCallout = false;
        }
        if(isCNBCallout){
            isCNBCallout = false;
            return true;
        } else {
            return isCNBCallout;
        }
    }
    
    public static Boolean isWarrantyCallout = true;
    public static Boolean runOnceWarranty(){
        System.debug('runOnceWarranty: ' + isWarrantyCallout);
        init();
        if(isBatchFuture) {
            System.debug('isBatchFuture');
            isWarrantyCallout = false;
        }
        if(isWarrantyCallout){
            isWarrantyCallout = false;
            return true;
        } else {
            return isWarrantyCallout;
        }
    } 
        
    // Sumit:: Start :: CRM-1311
        public static Boolean isRunOnce = true;
    public static Boolean RunOnces(){
        System.debug('isRunOnce: ' + isRunOnce);
        init();
        if(isBatchFuture) {
            System.debug('isBatchFuture');
            isRunOnce = false;
        }
        if(isRunOnce){
            isRunOnce = false;
            return true;
        } else {
            return isRunOnce;
        }
    }
    // Sumit :: End ::CRM-1311
    
}