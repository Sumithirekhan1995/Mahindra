@isTest
public class CheckRecursiveTrigger_Test {
    @isTest
    public static void test1() {
        CheckRecursiveTrigger.runOnce();
        CheckRecursiveTrigger.runOnce();
        CheckRecursiveTrigger.runOnceMMFSL();
        CheckRecursiveTrigger.runOnceMMFSL();
        CheckRecursiveTrigger.runOnceIBB();
        CheckRecursiveTrigger.runOnceIBB();
        CheckRecursiveTrigger.runOnceCTI();
        CheckRecursiveTrigger.runOnceCTI();
        CheckRecursiveTrigger.runOnceLMS();
        CheckRecursiveTrigger.runOnceOppLMS();
        CheckRecursiveTrigger.runOnceCNB();
        CheckRecursiveTrigger.runOnceWhatsappMsg();
        CheckRecursiveTrigger.runOnceWhatsappMsg();
        CheckRecursiveTrigger.runOnceOppElision();
        CheckRecursiveTrigger.runOnceOppElision();
        CheckRecursiveTrigger.runOnceOzontel();
        CheckRecursiveTrigger.runOnceOzontel();  
    }
}