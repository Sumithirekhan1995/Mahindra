public class DateTimeValidation {

    @InvocableMethod(label='Fetch Dates')
    public static List<List<String>> getDateTimeDetails(){
        
        //to get the local time
        System.debug('System Date' + System.now());
        Datetime now = Datetime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        Datetime local = now.addSeconds(offset/1000);
        System.debug('**Local**' + local);
        
        
        Date d = Date.today().addDays(2);
        DateTime toGetDays;
        Date UpcomingFiveDays;
        String Days;
        List<String> SetOfDates = new List<String>();
        List<List<String>> SendDates = new List<List<String>>();
        
        for(Integer i=1;i<6;i++){
            UpcomingFiveDays = Date.today().addDays(i);
            toGetDays = Date.today().addDays(i);
            Days = toGetDays.format('EEEE');
            System.debug('**Day**' +  Days);
            SetOfDates.add(String.valueOf(UpcomingFiveDays) + ' ' + Days);  
        }
        System.debug('***List****' + SetOfDates);
        SendDates.add(SetOfDates);
        return SendDates;
        
    }
}