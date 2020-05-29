package org.elastos.wallet.ela.ui.proposal.presenter;


import android.text.TextUtils;

import org.elastos.wallet.ela.base.BaseFragment;
import org.elastos.wallet.ela.net.RetrofitManager;
import org.elastos.wallet.ela.rxjavahelp.BaseEntity;
import org.elastos.wallet.ela.rxjavahelp.NewPresenterAbstract;
import org.elastos.wallet.ela.rxjavahelp.ObservableListener;
import org.elastos.wallet.ela.ui.crvote.bean.CRListBean;
import org.elastos.wallet.ela.ui.proposal.bean.ProposalSearchEntity;
import org.elastos.wallet.ela.ui.vote.bean.VoteListBean;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Iterator;
import java.util.List;

import io.reactivex.Observable;
import io.reactivex.Observer;

public class ProposalDetailPresenter extends NewPresenterAbstract {
    public void proposalDetail(int id, BaseFragment baseFragment) {

        Observable observable = RetrofitManager.webApiCreate().getProposalDetail(id);
        Observer observer = createObserver(baseFragment, "proposalDetail");
        subscriberObservable(observer, observable, baseFragment);
    }

    public void createVoteCRCProposalTransaction(String walletId, String votes, String invalidCandidates, BaseFragment baseFragment) {
        Observer observer = createObserver(baseFragment, "createVoteCRCProposalTransaction");
        Observable observable = createObservable(new ObservableListener() {
            @Override
            public BaseEntity subscribe() {
                return baseFragment.getMyWallet().createVoteCRCProposalTransaction(walletId, votes, invalidCandidates);
            }
        });
        subscriberObservable(observer, observable, baseFragment);
    }

    public void getVoteInfo(String walletId, String type, BaseFragment baseFragment) {
        Observer observer = createObserver(baseFragment, "getVoteInfo", type);
        Observable observable = createObservable(new ObservableListener() {
            @Override
            public BaseEntity subscribe() {
                return baseFragment.getMyWallet().getVoteInfo(walletId, type);
            }
        });
        subscriberObservable(observer, observable, baseFragment);
    }


    public JSONObject getCRUnactiveData(List<CRListBean.DataBean.ResultBean.CrcandidatesinfoBean> list) {

        JSONArray candidates = new JSONArray();
        if (list != null && list.size() > 0) {
            for (int i = 0; i < list.size(); i++) {
                CRListBean.DataBean.ResultBean.CrcandidatesinfoBean bean = list.get(i);
                if (!bean.getState().equals("Active")) {
                    candidates.put(bean.getDid());
                }
            }
        }
        return getActiveJson("CRC", candidates);
    }

    public JSONObject getCRCImpeachmentUnactiveData(List<CRListBean.DataBean.ResultBean.CrcandidatesinfoBean> list) {

        JSONArray candidates = new JSONArray();
        if (list != null && list.size() > 0) {
            for (int i = 0; i < list.size(); i++) {
                CRListBean.DataBean.ResultBean.CrcandidatesinfoBean bean = list.get(i);
                if (!bean.getState().equals("Active")) {
                    candidates.put(bean.getDid());
                }
            }
        }
        return getActiveJson("CRCImpeachment", candidates);
    }

    public JSONObject getDepositUnactiveData(List<VoteListBean.DataBean.ResultBean.ProducersBean> list) {

        JSONArray candidates = new JSONArray();
        if (list != null && list.size() > 0) {
            for (int i = 0; i < list.size(); i++) {
                VoteListBean.DataBean.ResultBean.ProducersBean bean = list.get(i);
                if (!bean.getState().equals("Active")) {
                    candidates.put(bean.getOwnerpublickey());
                }
            }
        }
        return getActiveJson("Delegate", candidates);
    }

    /**
     * 提取 origin 里的key 组成 key的JSONObject
     *
     * @param origin
     * @return
     */
    public JSONArray getJsonKeys(JSONObject origin) {
        JSONArray target = new JSONArray();
        if (origin != null) {
            Iterator it = origin.keys();
            while (it.hasNext()) {
                target.put(it.next());

            }
        }
        return target;
    }

    public JSONObject getCRLastVote(JSONObject origin) {
        return getActiveJson("CRC", getJsonKeys(origin));
    }

    public JSONObject getActiveJson(String type, JSONArray jsonArray) {
        JSONObject unActiveVote = new JSONObject();

        try {
            unActiveVote.put("Type", type);
            unActiveVote.put("Candidates", jsonArray);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return unActiveVote;
    }



    public JSONObject conversVote(String voteInfo, String targetType) {
        if (!TextUtils.isEmpty(voteInfo) && !voteInfo.equals("null") && !voteInfo.equals("[]")) {
            try {

                JSONArray lastVoteInfo = new JSONArray(voteInfo);
                for (int i = 0; i < lastVoteInfo.length(); i++) {
                    JSONObject jsonObject = lastVoteInfo.getJSONObject(i);
                    String type = jsonObject.getString("Type");

                    if (targetType.equals(type)) {
                        return jsonObject.getJSONObject("Votes");
                    }

                }

            } catch (JSONException e) {
                e.printStackTrace();


            }
        }
        return null;
    }

    public JSONArray conversUnactiveVote(String remove, String voteInfo, List<VoteListBean.DataBean.ResultBean.ProducersBean> depositList,
                                         List<CRListBean.DataBean.ResultBean.CrcandidatesinfoBean> crcList, List<ProposalSearchEntity.DataBean.ListBean> voteList) {
        JSONArray otherUnActiveVote = new JSONArray();

        if (!TextUtils.isEmpty(voteInfo) && !voteInfo.equals("null") && !voteInfo.equals("[]")) {

            try {
                JSONArray lastVoteInfo = new JSONArray(voteInfo);
                for (int i = 0; i < lastVoteInfo.length(); i++) {
                    JSONObject jsonObject = lastVoteInfo.getJSONObject(i);
                    String type = jsonObject.getString("Type");

                    if (type.equals(remove)) {
                        break;
                    }
                    JSONObject votes = jsonObject.getJSONObject("Votes");
                    Iterator it = votes.keys();
                    JSONArray candidates = new JSONArray();
                    switch (type) {
                        case "Delegate":
                            while (it.hasNext()) {
                                String key = (String) it.next();
                                if (depositList == null || depositList.size() == 0) {
                                    candidates.put(key);
                                    break;
                                }
                                for (VoteListBean.DataBean.ResultBean.ProducersBean bean : depositList) {
                                    if (bean.getOwnerpublickey().equals(key) && !bean.getState().equals("Active")) {
                                        candidates.put(key);
                                        break;
                                    }
                                }
                            }

                            break;
                        case "CRC":
                        case "CRCImpeachment":
                            while (it.hasNext()) {
                                String key = (String) it.next();
                                if (crcList == null || crcList.size() == 0) {
                                    candidates.put(key);
                                    break;
                                }
                                for (CRListBean.DataBean.ResultBean.CrcandidatesinfoBean bean : crcList) {
                                    if (bean.getDid().equals(key) && !bean.getState().equals("Active")) {
                                        candidates.put(key);
                                        break;
                                    }
                                }
                            }

                            break;
                        case "CRCProposal":
                            while (it.hasNext()) {
                                String key = (String) it.next();
                                if (crcList == null || crcList.size() == 0) {
                                    candidates.put(key);
                                    break;
                                }
                                for (ProposalSearchEntity.DataBean.ListBean bean : voteList) {
                                    if (bean.getProposalHash().equals(key)) {
                                        candidates.put(key);
                                        break;
                                    }
                                }
                            }
                            break;


                    }
                    otherUnActiveVote.put(getActiveJson(type, candidates));
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }

        }
        return otherUnActiveVote;
    }

    /**
     * @param lastVote 上传投票的信息  key value
     * @param amount   新数据的
     * @throws JSONException
     */
    public JSONObject getPublishDataFromLastVote(JSONObject lastVote, String amount, List<ProposalSearchEntity.DataBean.ListBean> searchBeanList) {
        JSONObject newVotes = new JSONObject();
        try {
            Iterator it = lastVote.keys();
            while (it.hasNext()) {
                String key = (String) it.next();
                for (int i = 0; i < searchBeanList.size(); i++) {
                    if (searchBeanList.get(i).getProposalHash().equals(key)) {
                        newVotes.put(key, amount);
                        break;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return newVotes;
    }
}