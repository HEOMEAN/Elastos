package org.elastos.trinity.runtime;

import android.content.Context;
import android.content.res.AssetManager;
import android.net.Uri;
import android.util.Base64;

import com.fasterxml.jackson.databind.ObjectMapper;

import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.protocol.HTTP;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import io.jsonwebtoken.JwtBuilder;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
//import org.apache.tomcat.util.codec.binary.Base64;

import org.apache.http.HttpEntity;
import org.apache.http.client.HttpClient;
import org.json.JSONTokener;

public class IntentManager {
    public static final int MAX_INTENT_NUMBER = 20;

    private LinkedHashMap<String, ArrayList<IntentInfo>> intentList = new LinkedHashMap();
    private LinkedHashMap<Long, IntentInfo> intentContextList = new LinkedHashMap();
    private LinkedHashMap<String, ArrayList<Long>> intentIdList = new LinkedHashMap();

    private LinkedHashMap<String, IntentPermission> permissionList = new LinkedHashMap();
    private Context context = null;

    private AppManager appManager;

    private static IntentManager intentManager;


    public static final String JWT_SECRET = "secret";

    final static String[] trinityScheme = {
            "elastos://",
            "https://scheme.elastos.org/",
    };

    IntentManager(AppManager appManager) {
        this.appManager = appManager;
        this.context = appManager.activity;

        try {
            parseIntentPermission();
        } catch (Exception e) {
            e.printStackTrace();
        }
        IntentManager.intentManager = this;
    }

    public static IntentManager getShareInstance() {
        return IntentManager.intentManager;
    }

    public static boolean checkTrinityScheme(String url) {
        for (int i = 0; i < trinityScheme.length; i++) {
            if (url.startsWith(trinityScheme[i])) {
                return true;
            }
        }
        return false;
    }

    private void putIntentToList(String app_id, IntentInfo info) {
        ArrayList<IntentInfo> infos = intentList.get(app_id);
        if (infos == null) {
            infos = new ArrayList<IntentInfo>();
            intentList.put(app_id, infos);
        }
        infos.add(info);
    }

    public void setIntentReady(String id)  throws Exception {
        ArrayList<IntentInfo> infos = intentList.get(id);
        if ((infos == null) || (infos.size() < 1)) {
            return;
        }

        for (int i = 0; i < infos.size(); i++) {
            IntentInfo info = infos.get(i);
            sendIntent(info);
        }
        infos.clear();
        intentList.remove(id);
    }

    public int getIntentCount(String id)  throws Exception {
        ArrayList<IntentInfo> infos = intentList.get(id);
        if ((infos == null) || (infos.size() < 1)) {
            return 0;
        }

        return infos.size();
    }

    private synchronized void putIntentContext(IntentInfo info) {
        IntentInfo intentInfo = intentContextList.get(info.intentId);
        while (intentInfo != null) {
            info.intentId++;
            intentInfo = intentContextList.get(info.intentId);
        }

        intentContextList.put(info.intentId, info);
        ArrayList<Long> ids = intentIdList.get(info.fromId);
        if (ids != null) {
            while (ids.size() > MAX_INTENT_NUMBER) {
                long intentId = ids.get(0);
                ids.remove(0);
                intentContextList.remove(intentId);
            }
        }
        else {
            ids = new ArrayList<Long>();
            intentIdList.put(info.fromId, ids);
        }
        ids.add(info.intentId);
    }

    public String[] getIntentFilter(String action) throws Exception {
        String[] ids = appManager.dbAdapter.getIntentFilter(action);
        ArrayList<String>list = new ArrayList<String>();

        for (int i = 0; i < ids.length; i++) {
            if (this.getIntentReceiverPermission(action, ids[i])) {
                list.add(ids[i]);
            }
        }

        if (list.isEmpty()) {
            throw new Exception(action + " isn't support!");
        }

        ids = new String[list.size()];
        return list.toArray(ids);
    }

    public void sendIntent(IntentInfo info) throws Exception {
        if (info.toId == null) {
            String[] ids = getIntentFilter(info.action);

            if (!this.getIntentSenderPermission(info.action, info.fromId)) {
                throw new Exception(info.action + " isn't permission!");
            }

            info.toId = ids[0];
        }

        WebViewFragment fragment = appManager.findFragmentById(info.toId);
        if ((fragment != null) && (fragment.basePlugin.isIntentReady())) {
            putIntentContext(info);
            appManager.start(info.toId);
            fragment.basePlugin.onReceiveIntent(info);
        }
        else {
            putIntentToList(info.toId, info);
            appManager.start(info.toId);
        }
    }

    public JSONObject parseJWT(String jwt) throws Exception {
        // Remove the Signature from the received JWT for now, we don't handle this.
        // TODO: extract the JWT issuer field from the JWT, resolve its DID from the DID sidechain, and
        // verify the JWT using the public key. JWT will have to be signed by the app developer's DID's private key.
        String[] splitToken = jwt.split("\\.");
        String unsignedToken = splitToken[0] + "." + splitToken[1] + ".";

        /*DefaultJwtParser parser = new DefaultJwtParser();
        Jwt<?, ?> parsedJwt = parser.parse(unsignedToken);
        Claims claims = (Claims) parsedJwt.getBody();*/

        String jwtPayload = splitToken[1];
        byte[] b64PayloadBytes = Base64.decode(jwtPayload, Base64.URL_SAFE);
        String b64Payload = new String(b64PayloadBytes, "UTF-8");

        JSONObject jwtPayloadJson = new JSONObject(b64Payload);

        return jwtPayloadJson;
    }

    final String[] removeJWTParams = {
            "appid",
            "iss",
            "iat",
            "exp",
            "redirecturl",
            "callbackurl"
    };

    public void getParamsByJWT(String jwt, IntentInfo info) throws Exception {
        JSONObject jwtPayload = parseJWT(jwt);

        jwtPayload.put("type", "jwt");
        info.params = jwtPayload.toString();

        if (jwtPayload.has("iss")) {
            info.aud = jwtPayload.getString("iss").toString();
        }
        if (jwtPayload.has("appid")) {
            info.req = jwtPayload.getString("appid").toString();
        }
        if (jwtPayload.has(IntentInfo.REDIRECT_URL)) {
            info.redirecturl = jwtPayload.getString(IntentInfo.REDIRECT_URL).toString();
        }
        else if (jwtPayload.has(IntentInfo.CALLBACK_URL)) {
            info.callbackurl = jwtPayload.getString(IntentInfo.CALLBACK_URL).toString();
        }
        info.type = IntentInfo.JWT;
    }


    public void getParamsByUri(Uri uri, IntentInfo info) throws Exception {
        Set<String> set = uri.getQueryParameterNames();
        JSONObject json = new JSONObject();
        for (String key : set) {
            String value = uri.getQueryParameter(key);
            if (key.equals(IntentInfo.REDIRECT_URL)) {
                info.redirecturl = value;
            }
            else if (key.equals(IntentInfo.CALLBACK_URL)) {
                info.callbackurl = value;
            }
            else if (key.equals(IntentInfo.REDIRECT_APP_URL)) {
                info.redirectappurl = value;
            }
            else {
                if (key.equals("iss")) {
                    info.aud = value;
                }
                else if (key.equals("appid")) {
                    info.req = value;
                }

                Object obj = new JSONTokener(value).nextValue();
                json.put(key, obj);
            }
        }
        info.type = IntentInfo.URL;
        info.params = json.toString();
    }

    public IntentInfo parseIntentUri(Uri uri, String fromId) throws Exception {
        IntentInfo info = null;
        String url = uri.toString();
        if (url.startsWith("elastos://") && !url.startsWith("elastos:///")) {
            url = "elastos:///" + url.substring(10);
            uri = Uri.parse(url);
        }
        List<String> list = uri.getPathSegments();
        if (list.size() > 0) {
            String[] paths = new String[list.size()];
            list.toArray(paths);
            String action = paths[0];
            Set<String> set = uri.getQueryParameterNames();
            long currentTime = System.currentTimeMillis();

            info = new IntentInfo(action, null, fromId, null, currentTime, null);
            if (set.size() > 0) {
                getParamsByUri(uri, info);
            }
            else if (list.size() == 2) {
                getParamsByJWT(paths[1], info);
            }
        }
        return info;
    }

    public void sendIntentByUri(Uri uri, String fromId) throws Exception {
        IntentInfo info = parseIntentUri(uri, fromId);
        if (info != null && info.params != null) {
            sendIntent(info);
        }
    }

    public void doIntentByUri(Uri uri) {
        try {
            sendIntentByUri(uri, "system");
        } catch (Exception e) {
//            try {
//                IntentInfo info = parseIntentUri(uri);
//                String err = "{\"jwt\":\"Error:" + e.getLocalizedMessage() + "\"";
//                sendJWTResponse(null, info, err);
//            } catch (Exception ex) {
//                ex.printStackTrace();
//            }
            e.printStackTrace();
        }
    }


    public String createJWTRespone(IntentInfo info, String result) throws Exception {
        SignatureAlgorithm signatureAlgorithm = SignatureAlgorithm.HS256;

        ObjectMapper mapper = new ObjectMapper();
        Map<String, Object> claims = mapper.readValue(result, Map.class);

        JwtBuilder builder = Jwts.builder()
                .setHeaderParam("type", "JWT")
                .claim("iss", claims.get("iss"))
                .claim("exp", claims.get("exp"))
                .claim("presentation", claims.get("presentation"))
                .claim("req", info.req)
                .claim("method", info.action)
//                .setId(UUID.randomUUID())
                .setIssuedAt(new Date())
                .setAudience(info.aud)
                .signWith(signatureAlgorithm, JWT_SECRET);

        return builder.compact();
    }

    public String createUrlRespone(IntentInfo info, String result) throws Exception {
        JSONObject ret = new JSONObject(result);
        if (info.req != null) {
            ret.put("req", info.req);
        }
        if (info.aud != null) {
            ret.put("aud", info.aud);
        }
        ret.put("iat", (int)(System.currentTimeMillis()/1000));
        ret.put("method", info.action);
        return ret.toString();
    }

    public void postCallback(String name, String value, String callbackurl) throws Exception {
        HttpClient httpClient = new DefaultHttpClient();
        HttpPost httpPost = new HttpPost(callbackurl);
        List<NameValuePair> paramList = new ArrayList<NameValuePair>(2);
        paramList.add(new BasicNameValuePair(name, value));
        HttpEntity entity = new UrlEncodedFormEntity(paramList, HTTP.UTF_8);
        httpPost.setEntity(entity);
        HttpResponse httpResponse = httpClient.execute(httpPost);
        if (httpResponse != null
                && httpResponse.getStatusLine().getStatusCode() == 200) {
        }
        else {
            String err = "Send callbackurl error";
            if (httpResponse != null) {
                err += ": " + httpResponse.getStatusLine().getStatusCode();
            }
            err += ".";

            throw new Exception(err);
        }

    }

    private String getResultUrl(String url, String result) {
        String param = "?result=";
        if (url.contains("?")) {
            param = "&result=";
        }
        return url + param + Uri.encode(result);
    }


    public void sendIntentResponse(AppBasePlugin basePlugin, String result, long intentId, String fromId) throws Exception {
        IntentInfo info = intentContextList.get(intentId);
        if (info == null) {
            throw new Exception(intentId + " isn't support!");
        }

        WebViewFragment fragment = null;
        if (info.fromId != null) {
            fragment = appManager.findFragmentById(info.fromId);
            if (fragment != null) {
                appManager.start(info.fromId);
            }
        }

        if (info.type == IntentInfo.API) {
            if (fragment != null) {
                info.params = result;
                info.fromId = fromId;
                fragment.basePlugin.onReceiveIntentResponse(info);
            }
        }
        else if (info.redirectappurl != null && fragment != null && fragment.basePlugin.isUrlApp()) {
            String url = getResultUrl(info.redirectappurl, result);
            fragment.loadUrl(url);
        }
        else {
            String url = info.redirecturl;
            if (url == null) {
                url = info.callbackurl;
            }

            if (url != null) {
                if (info.type == IntentInfo.JWT) {
                    String jwt = createJWTRespone(info, result);
                    if (IntentManager.checkTrinityScheme(url)) {
                        url = url + "/" + jwt;
                        sendIntentByUri(Uri.parse(url), info.fromId);
                    } else {
                        if (info.redirecturl != null) {
                            url = info.redirecturl + "/" + jwt;
                            basePlugin.webView.showWebPage(url, true, false, null);
                        } else if (info.callbackurl != null) {
                            postCallback("jwt", jwt, info.callbackurl);
                        }
                    }
                }
                else if (info.type == IntentInfo.URL){
                    String ret = createUrlRespone(info, result);
                    if (IntentManager.checkTrinityScheme(url)) {
                        url = getResultUrl(url, ret);
                        sendIntentByUri(Uri.parse(url), info.fromId);
                    } else {
                        if (info.redirecturl != null) {
                            url = getResultUrl(url, ret);
                            basePlugin.webView.showWebPage(url, true, false, null);
                        } else if (info.callbackurl != null) {
                            postCallback("result", ret, info.callbackurl);
                        }
                    }
                }
            }

        }

        intentContextList.remove(intentId);
    }

    public void parseIntentPermission() throws Exception {
        AssetManager manager = context.getAssets();
        InputStream inputStream = manager.open("www/config/permission/intent.json");

        JSONObject json = Utility.getJsonFromFile(inputStream);

        Iterator intents = json.keys();
        while (intents.hasNext()) {
            String intent = (String) intents.next();
            IntentPermission intentPermission = new IntentPermission(intent);

            JSONObject jintent = json.getJSONObject(intent);
            JSONArray array = jintent.getJSONArray("sender");
            for (int i = 0; i < array.length(); i++) {
                String appId = array.getString(i);
                intentPermission.addSender(appId);
            }
            array = jintent.getJSONArray("receiver");
            for (int i = 0; i < array.length(); i++) {
                String appId = array.getString(i);
                intentPermission.addReceiver(appId);
            }

            permissionList.put(intent, intentPermission);
        }
    }

    public boolean getIntentSenderPermission(String intent, String appId) {
        IntentPermission intentPermission = permissionList.get(intent);
        if (intentPermission == null) {
            return true;
        }

        return intentPermission.senderIsAllow(appId);
    }

    public boolean getIntentReceiverPermission(String intent, String appId) {
        IntentPermission intentPermission = permissionList.get(intent);
        if (intentPermission == null) {
            return true;
        }

        return intentPermission.receiverIsAllow(appId);
    }
}
