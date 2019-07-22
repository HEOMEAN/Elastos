package org.elastos.wallet.ela.utils;


import org.elastos.wallet.ela.MyApplication;

public class Constant {

    public static final String REQUEST_BASE_URL = getBaseUrl();

    public static final String CONTACTSHOW = "contact_show";
    public static final String CONTACTADD = "contact_add";
    public static final String CONTACTEDIT = "contact_edit";
    public static final String INNER = "inner";//油钱包列表打开
    public static final String SIDEWITHDRAW = "sideWithdraw";//侧链充值
    public static final String TRANFER = "transfer";//普通充值
    public static final String Email="wallet@elastos.org";
    public static final String UpdateLog="https://download.elastos.org/app/release-notes/ela-wallet/index.html";
    public static final String FRAGMENTTAG = "commonwebview";

    private static String getBaseUrl() {
        String baseUrl = "https://unionsquare.elastos.org/";
        switch (MyApplication.chainID) {

            case 1:
                baseUrl = "https://52.81.8.194:442/";
                break;
            case 2:
                baseUrl = "https://54.223.244.60/";
                break;

        }
        return baseUrl;

    }

}
