@isTest
public class DebugLogTest{
    // Test when the log has not been initialized
    testMethod static void test1() {
        System.assert(DebugLog.getValue('key') == null);
        System.assert(DebugLog.getOldestValue('key') == null);
        System.assert(DebugLog.getAllValues('key') == null);
        System.assert(DebugLog.getNbValues('key') == 0);
        System.assert(DebugLog.containsKey('key') == false);
        System.assertEquals(DebugLog.valueContains('key', '3'), null);
        System.assert(DebugLog.SOQLWhereEquals('key', new List<String>()) == 'Unknown key');
    }
    
      // Test when the log has been initialized but no value was added
     testMethod static void test2() {
        DebugLog.reset();
        System.assert(DebugLog.getValue('key') == null);
        System.assert(DebugLog.getOldestValue('key') == null);
        System.assert(DebugLog.getAllValues('key') == null);
        System.assert(DebugLog.getNbValues('key') == 0);
        System.assert(DebugLog.containsKey('key') == false);
        System.assertEquals(DebugLog.valueContains('key', '3'), null);
        System.assert(DebugLog.SOQLWhereEquals('key', new List<String>()) == 'Unknown key');
    }
    
    // Test when a value has been added
    testMethod static void test3() {
        DebugLog.addValue('key', 'value1');
        DebugLog.addValue('key', 'value2');
        DebugLog.addValue('key', 'value3');        
        System.assert(DebugLog.getValue('key') == 'value3');
        System.assert(DebugLog.getOldestValue('key') == 'value1');
        System.assert(DebugLog.getAllValues('key') == new String[] { 'value3', 'value2', 'value1' } );
        System.assert(DebugLog.getNbValues('key') == 3);
        System.assert(DebugLog.valueEquals('key', 'value3'));
        System.assert(DebugLog.valueContains('key', '3'));
        System.assert(DebugLog.containsKey('key'));
    }
    
    // Test exception
    testMethod static void test4() {
        try {
            integer a = 1 / 0;
        } catch (Exception e) {
            DebugLog.addException(e);
        }
        
        System.assert(DebugLog.valueContains('exception', 'Divide by 0'));
    }
    
    // Test SOQL filter
    testMethod static void test5() {
        DebugLog.addValue('soql', 'SELECT Id, Name FROM MyObject__c WHERE Name = \'Joe O\\\'Donnell\' AND  Age>18');
        System.assert(DebugLog.SOQLWHEREEquals('soql', new String[] { 'age > 18', 'name=\'joe o\\\'donnell\'' }) == null);
        System.assert(DebugLog.SOQLWHEREEquals('soql', new String[] { 'name=\'joe o\\\'donnell\'' }) == '[Age>18] not part of the expected filters, ');
        System.assert(DebugLog.SOQLWHEREEquals('soql', new String[] { 'age > 18', 'name=\'joe o\\\'donnell\'', 'field=5' }) == '[field=5] not in SOQL query, ');
    }
}
