DebugLog
========

As Salesforce tests cannot access the Debug Log, this class can be used instead to store some debugging information that can be read by apex tests.

The DebugLog class is used to store key/value pairs. It stores all the values if a key is used more than once. All its methods are static, avoiding the need to instanciate the class and passing its reference around. Here are some scenarios showing how it can be used:

    // Keep track of what method has been called
    void path1() {
        DebugLog.addValue('path', 'path1');
        ...
    }
    
    void path2() {
        DebugLog.addValue('path', 'path2');
        ...
    }

    // Keep track if your code catches an exception
    // It will store the exception name as well as the stack trace
    try {
        ...
    } catch (Exception e) {
        DebugLog.addException(e);
    }
    
    // Keep track of what dynamic SOQL was called
    String soqlQuery = ...
    DebugLog.add('soql', soqlQuery);
    Database.execute(soqlQuery);

The apex tests can then access that data:

    // Checks that path1() was called
    System.assert(DebugLog.valueEquals('path', 'method1'));
    // Checks that only one path method was called
    System.assert(DebugLog.getNbValues('path') == 1);
    
    // Checks that no exception was raised and caught
    // Give details about the oldest exception if there is any
    String error = DebugLog.getOldestValue('exception');
    System.assert(error == null, error);

    // Checks that the key 'soql' is a SOQL query whose filters
    // contain both 'field1 = 5' and 'field2 = :data' (no matter
    // what the order) and only those filters
    error = DebugLog.SOQLWHEREEquals('soql', new String[] { 'field1=5', 'field2 = :data' });
    System.assert(error == null, error);
