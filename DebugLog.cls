public class DebugLog {
    static Map<String, List<String>> log;
    
    public static void reset() {
        log = new Map<String, List<String>>();
    }
    
    public static void addValue(String key, String value) {
        if (log == null) reset();
        List<String> values = log.get(key);
        if (values == null) {
            values = new String[] { value };
            log.put(key, values);
        }
        else values.add(0, value);
    }
    
    public static void addException(Exception e) {
        addValue('exception', e.getMessage() + ' - ' + e.getStackTraceString());
    }
    
    public static List<String> getAllValues(String key) {
        if (log == null) return null;
        return log.get(key);
    }
    
    public static string getValue(String key) {
        List<String> values = DebugLog.getAllValues(key);
        if (values == null) return null;
        return values[0];
    }

    public static Integer getNbValues(String key) {
        List<String> values = DebugLog.getAllValues(key);
        if (values == null) return 0;
        return values.size();
    }
    
    public static string getOldestValue(String key) {
        List<String> values = DebugLog.getAllValues(key);
        if (values == null) return null;
        return values[values.size() - 1];
    }
    
    public static Boolean valueEquals(String key, String value) {
        return (getValue(key) == value);
    }
    
    public static Boolean valueContains(String key, String partialvalue) {
        String value = getValue(key);
        if (value == null) return null;
        return value.contains(partialvalue);
    }
    
    public static Boolean containsKey(String key) {
        if (log == null) return false;
        return log.containsKey(key);
    }
    
    // Transforms a SOQL filter in a manner
    static String normalizeSOQLFilter(String filter) {
        String result = '';
        Integer idxFrom=0, idxUpto = filter.indexOf('\'');
        Boolean insideQuotes = false;
        while (idxUpto >= 0) {
            if (idxUpto == 0 || filter.substring(idxUpto-1, idxUpto) != '\\') {
                if (insideQuotes) {
                    result += '\'' + filter.substring(idxFrom, idxUpto) + '\'';
                } else {
                    result += filter.substring(idxFrom, idxUpto).replace(' ', '');
                }
                insideQuotes = !insideQuotes;
                idxFrom = idxUpto + 1;
            }
            idxUpto = filter.indexOf('\'', idxUpto + 1);
        }
        
        if (insideQuotes) {
            result += '\'' + filter.substring(idxFrom) + '\'';
        } else {
            result += filter.substring(idxFrom).replace(' ', '');
        }
        
        return result.toLowerCase();
    }

    // Considers the value being a SOQL query
    // If one considers the SOQL query to be in the form:
    // SELECT ... FROM ... WHERE filter1 AND filter2 ... AND filtern
    // checks that the SOQL contains ALL and ONLY the desired filters
    public static String SOQLWHEREEquals(String key, List<String> filters) {
        if (log == null) return 'Unknown key';
        if (!log.containsKey(key)) return 'Unknown key';
        String normalizedFilter, soql = log.get(key)[0];
        Integer idx = soql.indexOf(' WHERE ');
        if (idx < 0) return 'No WHERE statement in the SOQL query';
        String errors = '';
        soql = soql.substring(idx + 7);
        Set<String> SOQLfilters = new Set<String>();
        Map<String, String> unnormalize = new Map<String, String>();
        for (String SOQLfilter : soql.split(' AND ')) {
            normalizedFilter= normalizeSOQLFilter(SOQLfilter);
            SOQLfilters.add(normalizedFilter);
            unnormalize.put(normalizedFilter, SOQLFilter.trim());
        }
        
        for (String filter : filters) {
            if (!SOQLfilters.remove(normalizeSOQLFilter(filter))) 
                errors += '[' + filter.trim() + '] not in SOQL query, ';
        }
        
        for (String filterRemaining : SOQLfilters) errors += '[' + unnormalize.get(filterRemaining ) + '] not part of the expected filters, ';
        
        if (errors == '') return null;
        return errors;
    }
}
