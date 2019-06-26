//
//  ElaSubWalletCallback.h
//  elastos wallet
//
//  Created by  on 2019/1/21.
//

#import <UIKit/UIKit.h>
#include <stdint.h>
#include "json.hpp"
#include "string"
#import "ISubWalletCallback.h"
NS_ASSUME_NONNULL_BEGIN

namespace Elastos {
    namespace ElaWallet {class ElaSubWalletCallback : public  ISubWalletCallback {
    public:
        
        void OnTransactionStatusChanged(
                                                const std::string &txid,
                                                const std::string &status,
                                                const nlohmann::json &desc,
                                                uint32_t confirms);
        
        /**
         * Callback method fired when block begin synchronizing with a peer. This callback could be used to show progress.
         */
        void OnBlockSyncStarted();
        
        /**
         * Callback method fired when best block chain height increased. This callback could be used to show progress.
         * @param currentBlockHeight is the of current block when callback fired.
         * @param estimatedHeight is max height of blockchain.
         * @param lastBlockTime timestamp of the last block.
         */
         void OnBlockSyncProgress(uint32_t currentBlockHeight, uint32_t estimatedHeight, time_t lastBlockTime);
        
        /**
         * Callback method fired when block end synchronizing with a peer. This callback could be used to show progress.
         */
         void OnBlockSyncStopped();
        
        /**
         * Callback method fired when balance changed.
         * @param asset ID.
         * @param balance after changed.
         */
        void OnBalanceChanged(const std::string &asset, const std::string &balance);
        
        /**
         * Callback method fired when tx published.
         * @param hash of published tx.
         * @param result in json format.
         */
         void OnTxPublished(const std::string &hash, const nlohmann::json &result);
        
        /**
         * Callback method fired when a new asset registered.
         * @param asset ID.
         * @param information of asset.
         */
        void OnAssetRegistered(const std::string &asset, const nlohmann::json &info);
        
        ElaSubWalletCallback(const std::string &callBackInfo);
        
        ~ElaSubWalletCallback();
    private:
        std::string _callBackInfo;
        
        
    };
        
        
    }
    
}
NS_ASSUME_NONNULL_END
