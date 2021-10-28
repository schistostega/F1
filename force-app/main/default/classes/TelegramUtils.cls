public with sharing class TelegramUtils {
    public static void sendMessage(String message) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(
            'https://api.telegram.org/bot' + Secrets.getBotToken() +
            '/sendMessage?chat_id=' + Secrets.getChatId() +
            '&parse_mode=Markdown&text=' + EncodingUtil.urlEncode(message, 'UTF-8')
        );
        req.setMethod('GET');

        new Http().send(req);
    }
}
