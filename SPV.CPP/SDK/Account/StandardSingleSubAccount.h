// Copyright (c) 2012-2018 The Elastos Open Source Project
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#ifndef __ELASTOS_SDK_STANDARDSINGLESUBACCOUNT_H__
#define __ELASTOS_SDK_STANDARDSINGLESUBACCOUNT_H__

#include "SingleSubAccount.h"

namespace Elastos {
	namespace ElaWallet {

		class StandardSingleSubAccount : public SingleSubAccount {
		public:
			StandardSingleSubAccount(const MasterPubKey &masterPubKey, const CMBlock &votePubKey,
									 IAccount *account, uint32_t coinIndex);

			virtual Key DeriveMainAccountKey(const std::string &payPassword);

			virtual std::string GetMainAccountPublicKey() const;

			virtual std::vector<Address> GetAllAddresses(size_t addrsCount) const;

			virtual Key DeriveVoteKey(const std::string &payPasswd);

		protected:
			virtual WrapperList<Key, BRKey>
			DeriveAccountAvailableKeys(const std::string &payPassword,
									   const TransactionPtr &transaction);
		};

	}
}

#endif //__ELASTOS_SDK_STANDARDSINGLESUBACCOUNT_H__
