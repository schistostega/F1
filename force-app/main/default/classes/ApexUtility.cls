public class ApexUtility {
    public static String getAllFieldsOfObject(String ObjectName) {
        List<String> fields = new List<String>(Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().keySet());
        return String.join(fields, ',');
    }
}
