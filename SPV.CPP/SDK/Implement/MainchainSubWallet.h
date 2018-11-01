// Copyright (c) 2012-2018 The Elastos Open Source Project
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#ifndef __ELASTOS_SDK_MAINCHAINSUBWALLET_H__
#define __ELASTOS_SDK_MAINCHAINSUBWALLET_H__

#include "Interface/IMainchainSubWallet.h"
#include "SubWallet.h"

namespace Elastos {
	namespace ElaWallet {

		class MainchainSubWallet : public IMainchainSubWallet, public SubWallet {
		public:
			~MainchainSubWallet();

			virtual nlohmann::json CreateDepositTransaction(
					const std::string &fromAddress,
					const std::string &toAddress,
					const uint64_t amount,
					const nlohmann::json &sidechainAccounts,
					const nlohmann::json &sidechainAmounts,
					const nlohmann::json &sidechainIndices,
					const std::string &memo,
					const std::string &remark);

			virtual nlohmann::json CreateRegisterProducerTransaction(
					const std::string &fromAddress,
					const std::string &toAddress,
					const std::string &publicKey,
					const std::string &nickName,
					const std::string &url,
					const std::string &location);

			virtual nlohmann::json CreateCancelProducerTransaction(
					const std::string &fromAddress,
					const std::string &toAddress,
					const std::string &publicKey);

			virtual nlohmann::json CreateVoteProducerTransaction(
					const std::string &fromAddress,
					const std::string &toAddress,
					uint64_t stake,
					const nlohmann::json &pubicKeys);

		protected:
			friend class MasterWallet;

			MainchainSubWallet(const CoinInfo &info,
							   const MasterPubKeyPtr &masterPubKey,
							   const ChainParams &chainParams,
							   const PluginTypes &pluginTypes,
							   MasterWallet *parent);

			virtual nlohmann::json GetBasicInfo() const;

			virtual boost::shared_ptr<Transaction> createTransaction(TxParam *param) const;

			virtual void verifyRawTransaction(const TransactionPtr &transaction);

			virtual TransactionPtr completeTransaction(const TransactionPtr &transaction, uint64_t actualFee);

		};

	}
}

#endif //__ELASTOS_SDK_MAINCHAINSUBWALLET_H__
