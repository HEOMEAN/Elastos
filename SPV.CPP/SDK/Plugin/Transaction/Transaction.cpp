// Copyright (c) 2012-2018 The Elastos Open Source Project
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.


#include "Program.h"
#include "Attribute.h"
#include "TransactionInput.h"
#include "TransactionOutput.h"
#include "Transaction.h"
#include "SDK/Plugin/Transaction/Payload/CoinBase.h"
#include "SDK/Plugin/Transaction/Payload/RechargeToSideChain.h"
#include "SDK/Plugin/Transaction/Payload/WithdrawFromSideChain.h"
#include "SDK/Plugin/Transaction/Payload/Record.h"
#include "SDK/Plugin/Transaction/Payload/RegisterAsset.h"
#include "SDK/Plugin/Transaction/Payload/SideChainPow.h"
#include "SDK/Plugin/Transaction/Payload/TransferCrossChainAsset.h"
#include "SDK/Plugin/Transaction/Payload/TransferAsset.h"
#include "SDK/Plugin/Transaction/Payload/ProducerInfo.h"
#include "SDK/Plugin/Transaction/Payload/CancelProducer.h"
#include "SDK/Plugin/Transaction/Payload/ReturnDepositCoin.h"
#include "SDK/Plugin/Transaction/Payload/CRInfo.h"
#include "SDK/Plugin/Transaction/Payload/UnregisterCR.h"
#include <SDK/Wallet/UTXO.h>
#include <SDK/Wallet/Wallet.h>

#include <SDK/Common/Utils.h>
#include <SDK/Common/Log.h>
#include <SDK/Common/ErrorChecker.h>
#include <SDK/Common/hash.h>

#include <boost/make_shared.hpp>
#include <cstring>

#define STANDARD_FEE_PER_KB 10000
#define DEFAULT_PAYLOAD_TYPE  transferAsset
#define TX_LOCKTIME          0x00000000

namespace Elastos {
	namespace ElaWallet {

		Transaction::Transaction() :
				_version(TxVersion::Default),
				_lockTime(TX_LOCKTIME),
				_blockHeight(TX_UNCONFIRMED),
				_payloadVersion(0),
				_fee(0),
				_payload(nullptr),
				_type(DEFAULT_PAYLOAD_TYPE),
				_isRegistered(false),
				_txHash(0),
				_timestamp(0) {
			_payload = InitPayload(_type);
		}

		Transaction::Transaction(uint8_t type, const PayloadPtr &payload) :
			_version(TxVersion::Default),
			_lockTime(TX_LOCKTIME),
			_blockHeight(TX_UNCONFIRMED),
			_payloadVersion(0),
			_fee(0),
			_type(type),
			_isRegistered(false),
			_txHash(0),
			_timestamp(0),
			_payload(payload) {
		}

		Transaction::Transaction(const Transaction &tx) {
			this->operator=(tx);
		}

		Transaction &Transaction::operator=(const Transaction &orig) {
			_isRegistered = orig._isRegistered;
			_txHash = orig.GetHash();

			_version = orig._version;
			_lockTime = orig._lockTime;
			_blockHeight = orig._blockHeight;
			_timestamp = orig._timestamp;

			_type = orig._type;
			_payloadVersion = orig._payloadVersion;
			_fee = orig._fee;

			_payload = InitPayload(orig._type);

			*_payload = *orig._payload;

			_inputs.clear();
			for (size_t i = 0; i < orig._inputs.size(); ++i) {
				_inputs.push_back(InputPtr(new TransactionInput(*orig._inputs[i])));
			}

			_outputs.clear();
			for (size_t i = 0; i < orig._outputs.size(); ++i) {
				_outputs.push_back(OutputPtr(new TransactionOutput(*orig._outputs[i])));
			}

			_attributes.clear();
			for (size_t i = 0; i < orig._attributes.size(); ++i) {
				_attributes.push_back(AttributePtr(new Attribute(*orig._attributes[i])));
			}

			_programs.clear();
			for (size_t i = 0; i < orig._programs.size(); ++i) {
				_programs.push_back(ProgramPtr(new Program(*orig._programs[i])));
			}

			return *this;
		}

		Transaction::~Transaction() {
		}

		bool Transaction::IsRegistered() const {
			return _isRegistered;
		}

		bool &Transaction::IsRegistered() {
			return _isRegistered;
		}

		void Transaction::ResetHash() {
			_txHash = 0;
		}

		const uint256 &Transaction::GetHash() const {
			if (_txHash == 0) {
				ByteStream stream;
				SerializeUnsigned(stream);
				_txHash = sha256_2(stream.GetBytes());
			}
			return _txHash;
		}

		void Transaction::SetHash(const uint256 &hash) {
			_txHash = hash;
		}

		const Transaction::TxVersion &Transaction::GetVersion() const {
			return _version;
		}

		void Transaction::SetVersion(const TxVersion &version) {
			_version = version;
		}

		uint8_t Transaction::GetTransactionType() const {
			return _type;
		}

		void Transaction::Reinit() {
			Cleanup();
			_type = DEFAULT_PAYLOAD_TYPE;
			_payload = InitPayload(_type);

			_version = TxVersion::Default;
			_lockTime = TX_LOCKTIME;
			_blockHeight = TX_UNCONFIRMED;
			_payloadVersion = 0;
			_fee = 0;
		}

		const std::vector<OutputPtr> &Transaction::GetOutputs() const {
			return _outputs;
		}

		void Transaction::FixIndex() {
			for (uint16_t i = 0; i < _outputs.size(); ++i)
				_outputs[i]->SetFixedIndex(i);
		}

		OutputPtr Transaction::OutputOfIndex(uint16_t fixedIndex) const {
			std::vector<OutputPtr>::const_iterator it;
			for (it = _outputs.cbegin(); it != _outputs.cend(); ++it) {
				if ((*it)->FixedIndex() == fixedIndex)
					return (*it);
			}

			return nullptr;
		}

		void Transaction::SetOutputs(const std::vector<OutputPtr> &outputs) {
			_outputs = outputs;
		}

		void Transaction::AddOutput(const OutputPtr &output) {
			_outputs.push_back(output);
		}

		void Transaction::RemoveOutput(const OutputPtr &output) {
			for (std::vector<OutputPtr>::iterator it = _outputs.begin(); it != _outputs.end(); ) {
				if (output == (*it)) {
					it = _outputs.erase(it);
					break;
				} else {
					++it;
				}
			}
		}

		const std::vector<InputPtr> &Transaction::GetInputs() const {
			return _inputs;
		}

		std::vector<InputPtr>& Transaction::GetInputs() {
			return _inputs;
		}

		void Transaction::AddInput(const InputPtr &Input) {
			_inputs.push_back(Input);
		}

		bool Transaction::ContainInput(const uint256 &hash, uint32_t n) const {
			for (size_t i = 0; i < _inputs.size(); ++i) {
				if (_inputs[i]->TxHash() == hash && n == _inputs[i]->Index()) {
					return true;
				}
			}

			return false;
		}

		uint32_t Transaction::GetLockTime() const {

			return _lockTime;
		}

		void Transaction::SetLockTime(uint32_t t) {

			_lockTime = t;
		}

		uint32_t Transaction::GetBlockHeight() const {
			return _blockHeight;
		}

		void Transaction::SetBlockHeight(uint32_t height) {
			_blockHeight = height;
		}

		time_t Transaction::GetTimestamp() const {
			return _timestamp;
		}

		void Transaction::SetTimestamp(time_t t) {
			_timestamp = t;
		}

		size_t Transaction::EstimateSize() const {
			size_t i, txSize = 0;
			ByteStream stream;

			if (_version >= TxVersion::V09)
				txSize += 1;

			// type, payloadversion
			txSize += 2;

			// payload
			txSize += _payload->EstimateSize(_payloadVersion);

			txSize += stream.WriteVarUint(_attributes.size());
			for (i = 0; i < _attributes.size(); ++i)
				txSize += _attributes[i]->EstimateSize();

			txSize += stream.WriteVarUint(_inputs.size());
			for (i = 0; i < _inputs.size(); ++i)
				txSize += _inputs[i]->EstimateSize();

			txSize += stream.WriteVarUint(_outputs.size());
			for (i = 0; i < _outputs.size(); ++i)
				txSize += _outputs[i]->EstimateSize();

			txSize += sizeof(_lockTime);

			txSize += stream.WriteVarUint(_programs.size());
			for (i = 0; i < _programs.size(); ++i)
				txSize += _programs[i]->EstimateSize();

			return txSize;
		}

		nlohmann::json Transaction::GetSignedInfo() const {
			nlohmann::json info;
			uint256 md = GetShaData();

			for (size_t i = 0; i < _programs.size(); ++i) {
				info.push_back(_programs[i]->GetSignedInfo(md));
			}
			return info;
		}

		bool Transaction::IsSigned() const {
			if (_type == rechargeToSideChain || _type == coinBase)
				return true;

			if (_programs.size() == 0)
				return false;

			uint256 md = GetShaData();

			for (size_t i = 0; i < _programs.size(); ++i) {
				if (!_programs[i]->VerifySignature(md))
					return false;
			}

			return true;
		}

		bool Transaction::IsCoinBase() const {
			return _type == coinBase;
		}

		bool Transaction::IsValid() const {
			if (!IsSigned()) {
				Log::error("verify tx signature fail");
				return false;
			}

			for (size_t i = 0; i < _attributes.size(); ++i) {
				if (!_attributes[i]->IsValid()) {
					Log::error("tx attribute is invalid");
					return false;
				}
			}

			if (_payload == nullptr || !_payload->IsValid()) {
				Log::error("tx payload invalid");
				return false;
			}

			if (_outputs.size() == 0) {
				Log::error("tx without output");
				return false;
			}

			for (size_t i = 0; i < _outputs.size(); ++i) {
				if (!_outputs[i]->IsValid()) {
					Log::error("tx output is invalid");
					return false;
				}
			}

			return true;
		}

		uint64_t Transaction::GetMinOutputAmount() {

			return TX_MIN_OUTPUT_AMOUNT;
		}

		const IPayload *Transaction::GetPayload() const {
			return _payload.get();
		}

		IPayload *Transaction::GetPayload() {
			return _payload.get();
		}

		void Transaction::SetPayload(const PayloadPtr &payload) {
			_payload = payload;
		}

		void Transaction::AddAttribute(const AttributePtr &attribute) {
			_attributes.push_back(attribute);
		}

		const std::vector<AttributePtr> &Transaction::GetAttributes() const {
			return _attributes;
		}

		bool Transaction::AddUniqueProgram(const ProgramPtr &program) {
			for (size_t i = 0; i < _programs.size(); ++i) {
				if (_programs[i]->GetCode() == program->GetCode()) {
					return false;
				}
			}

			_programs.push_back(program);

			return true;
		}

		void Transaction::AddProgram(const ProgramPtr &program) {
			_programs.push_back(program);
		}

		const std::vector<ProgramPtr> &Transaction::GetPrograms() const {
			return _programs;
		}

		void Transaction::ClearPrograms() {
			_programs.clear();
		}

		void Transaction::Serialize(ByteStream &ostream, bool extend) const {
			SerializeUnsigned(ostream, extend);

			ostream.WriteVarUint(_programs.size());
			for (size_t i = 0; i < _programs.size(); i++) {
				_programs[i]->Serialize(ostream, extend);
			}
		}

		void Transaction::SerializeUnsigned(ByteStream &ostream, bool extend) const {
			if (_version >= TxVersion::V09) {
				ostream.WriteByte(_version);
			}
			ostream.WriteByte(_type);

			ostream.WriteByte(_payloadVersion);

			ErrorChecker::CheckCondition(_payload == nullptr, Error::Transaction,
										 "payload should not be null");

			_payload->Serialize(ostream, _payloadVersion);

			ostream.WriteVarUint(_attributes.size());
			for (size_t i = 0; i < _attributes.size(); i++) {
				_attributes[i]->Serialize(ostream);
			}

			ostream.WriteVarUint(_inputs.size());
			for (size_t i = 0; i < _inputs.size(); i++) {
				_inputs[i]->Serialize(ostream);
			}

			ostream.WriteVarUint(_outputs.size());
			for (size_t i = 0; i < _outputs.size(); i++) {
				_outputs[i]->Serialize(ostream, _version, extend);
			}

			ostream.WriteUint32(_lockTime);
		}

		bool Transaction::Deserialize(const ByteStream &istream, bool extend) {
			Reinit();

			uint8_t flagByte = 0;
			if (!istream.ReadByte(flagByte)) {
				Log::error("deserialize flag byte error");
				return false;
			}

			if (flagByte >= TxVersion::V09) {
				_version = static_cast<TxVersion>(flagByte);
				if (!istream.ReadByte(_type)) {
					Log::error("deserialize type error");
					return false;
				}
			} else {
				_version = TxVersion::Default;
				_type = flagByte;
			}

			if (!istream.ReadByte(_payloadVersion))
				return false;

			_payload = InitPayload(_type);

			if (_payload == nullptr) {
				Log::error("new _payload with _type={} when deserialize error", _type);
				return false;
			}
			if (!_payload->Deserialize(istream, _payloadVersion))
				return false;

			uint64_t attributeLength = 0;
			if (!istream.ReadVarUint(attributeLength))
				return false;

			for (size_t i = 0; i < attributeLength; i++) {
				AttributePtr attribute(new Attribute());
				if (!attribute->Deserialize(istream)) {
					Log::error("deserialize tx attribute[{}] error", i);
					return false;
				}
				_attributes.push_back(attribute);
			}

			uint64_t inCount = 0;
			if (!istream.ReadVarUint(inCount)) {
				Log::error("deserialize tx inCount error");
				return false;
			}

			_inputs.reserve(inCount);
			for (size_t i = 0; i < inCount; i++) {
				InputPtr input(new TransactionInput());
				if (!input->Deserialize(istream)) {
					Log::error("deserialize tx input [{}] error", i);
					return false;
				}
				_inputs.push_back(input);
			}

			uint64_t outputLength = 0;
			if (!istream.ReadVarUint(outputLength)) {
				Log::error("deserialize tx output len error");
				return false;
			}

			if (outputLength > UINT16_MAX) {
				Log::error("deserialize tx: too much outputs: {}", outputLength);
				return false;
			}

			_outputs.reserve(outputLength);
			for (size_t i = 0; i < outputLength; i++) {
				OutputPtr output(new TransactionOutput());
				if (!output->Deserialize(istream, _version, extend)) {
					Log::error("deserialize tx output[{}] error", i);
					return false;
				}

				if (!extend) {
					output->SetFixedIndex((uint16_t) i);
				}
				_outputs.push_back(output);
			}

			if (!istream.ReadUint32(_lockTime)) {
				Log::error("deserialize tx lock time error");
				return false;
			}

			uint64_t programLength = 0;
			if (!istream.ReadVarUint(programLength)) {
				Log::error("deserialize tx program length error");
				return false;
			}

			for (size_t i = 0; i < programLength; i++) {
				ProgramPtr program(new Program());
				if (!program->Deserialize(istream, extend)) {
					Log::error("deserialize program[{}] error", i);
					return false;
				}
				_programs.push_back(program);
			}

			ByteStream stream;
			SerializeUnsigned(stream);
			_txHash = sha256_2((stream.GetBytes()));

			return true;
		}

		nlohmann::json Transaction::ToJson() const {
			nlohmann::json j;

			j["IsRegistered"] = _isRegistered;

			j["TxHash"] = GetHash().GetHex();
			j["Version"] = _version;
			j["LockTime"] = _lockTime;
			j["BlockHeight"] = _blockHeight;
			j["Timestamp"] = _timestamp;

			std::vector<nlohmann::json> inputsJson(_inputs.size());
			for (size_t i = 0; i < _inputs.size(); ++i) {
				inputsJson[i] = _inputs[i]->ToJson();
			}
			j["Inputs"] = inputsJson;

			j["Type"] = _type;
			j["PayloadVersion"] = _payloadVersion;
			j["PayLoad"] = _payload->ToJson(_payloadVersion);

			std::vector<nlohmann::json> attributesJson(_attributes.size());
			for (size_t i = 0; i < _attributes.size(); ++i) {
				attributesJson[i] = _attributes[i]->ToJson();
			}
			j["Attributes"] = attributesJson;

			std::vector<nlohmann::json> programsJson(_programs.size());
			for (size_t i = 0; i < _programs.size(); ++i) {
				programsJson[i] = _programs[i]->ToJson();
			}
			j["Programs"] = programsJson;

			std::vector<nlohmann::json> outputsJson(_outputs.size());
			for (size_t i = 0; i < _outputs.size(); ++i) {
				outputsJson[i] = _outputs[i]->ToJson(_version);
			}
			j["Outputs"] = outputsJson;

			j["Fee"] = _fee;

			return j;
		}

		void Transaction::FromJson(const nlohmann::json &j) {
			Reinit();

			try {
				_isRegistered = j["IsRegistered"];

				uint8_t version = j["Version"].get<uint8_t>();
				_version = static_cast<TxVersion>(version);
				_lockTime = j["LockTime"].get<uint32_t>();
				_blockHeight = j["BlockHeight"].get<uint32_t>();
				_timestamp = j["Timestamp"].get<uint32_t>();

				std::vector<nlohmann::json> inputJsons = j["Inputs"];
				for (size_t i = 0; i < inputJsons.size(); ++i) {
					InputPtr input(new TransactionInput());
					input->FromJson(inputJsons[i]);
					_inputs.push_back(input);
				}

				_type = j["Type"].get<uint8_t>();
				_payloadVersion = j["PayloadVersion"];
				_payload = InitPayload(_type);

				if (_payload == nullptr) {
					Log::error("_payload is nullptr when convert from json");
				} else {
					_payload->FromJson(j["PayLoad"], _payloadVersion);
				}

				std::vector<nlohmann::json> attributesJson = j["Attributes"];
				for (size_t i = 0; i < attributesJson.size(); ++i) {
					AttributePtr attribute(new Attribute());
					attribute->FromJson(attributesJson[i]);
					_attributes.push_back(attribute);
				}

				std::vector<nlohmann::json> programsJson = j["Programs"];
				for (size_t i = 0; i < programsJson.size(); ++i) {
					ProgramPtr program(new Program());
					program->FromJson(programsJson[i]);
					_programs.push_back(program);
				}

				std::vector<nlohmann::json> outputsJson = j["Outputs"];
				for (size_t i = 0; i < outputsJson.size(); ++i) {
					OutputPtr output(new TransactionOutput());
					output->FromJson(outputsJson[i], _version);
					_outputs.push_back(output);
				}

				_fee = j["Fee"].get<uint64_t>();

				_txHash.SetHex(j["TxHash"].get<std::string>());
			} catch (const nlohmann::detail::exception &e) {
				ErrorChecker::ThrowLogicException(Error::Code::JsonFormatError, "tx from json: " +
																				std::string(e.what()));
			}
		}

		uint64_t Transaction::CalculateFee(uint64_t feePerKb) {
			return ((EstimateSize() + 999) / 1000) * feePerKb;
		}

		uint64_t Transaction::GetTxFee(const WalletPtr &wallet) {
			uint64_t fee = 0;
			BigInt inputAmount(0), outputAmount(0);

			for (size_t i = 0; i < _inputs.size(); ++i) {
				const TransactionPtr &tx = wallet->TransactionForHash(_inputs[i]->TxHash());
				if (tx == nullptr) continue;
				inputAmount += tx->GetOutputs()[_inputs[i]->Index()]->Amount();
			}

			for (size_t i = 0; i < _outputs.size(); ++i) {
				outputAmount += _outputs[i]->Amount();
			}

			if (inputAmount >= outputAmount)
				fee = (inputAmount - outputAmount).getUint64();

			return fee;
		}

		nlohmann::json Transaction::GetSummary(const WalletPtr &wallet, uint32_t confirms, bool detail) {
			std::string addr;
			nlohmann::json summary, outputPayload;
			std::vector<nlohmann::json> outputPayloads;
			std::string direction = "Received";
			BigInt inputAmount(0), outputAmount(0), changeAmount(0);
			uint64_t fee = 0;
			std::map<std::string, BigInt>::iterator it;

			std::map<std::string, BigInt> inputList;
			for (InputArray::iterator in = _inputs.begin(); in != _inputs.end(); ++in) {
				TransactionPtr tx = wallet->TransactionForHash((*in)->TxHash());
				if (tx) {
					const OutputPtr o = tx->OutputOfIndex((*in)->Index());
					if (o && wallet->ContainsAddress(o->Addr()) && !wallet->IsDepositAddress(o->Addr())) {
						const BigInt &spentAmount = o->Amount();
						addr = o->Addr().String();

						if (detail) {
							if (inputList.find(addr) == inputList.end()) {
								inputList[addr] = spentAmount;
							} else {
								inputList[addr] += spentAmount;
							}
						}

						// sent or moved
						direction = "Sent";
						inputAmount += spentAmount;
					}
				} else {
					UTXOPtr cb = wallet->CoinBaseTxForHash((*in)->TxHash());
					if (cb && cb->Index() == (*in)->Index()) {
						const BigInt &spentAmount = cb->Output()->Amount();
						addr = Address(cb->Output()->ProgramHash()).String();

						if (detail) {
							if (inputList.find(addr) == inputList.end()) {
								inputList[addr] = spentAmount;
							} else {
								inputList[addr] += spentAmount;
							}
						}

						direction = "Sent";
						inputAmount += spentAmount;
					}
				}
			}

			nlohmann::json inputJson;
			if (direction == "Sent") {
				for (it = inputList.begin(); it != inputList.end(); ++it) {
					inputJson[it->first] = it->second.getDec();
				}
			}

			bool containAddress;
			std::map<std::string, BigInt> outputList;
			for (OutputArray::iterator o = _outputs.begin(); o != _outputs.end(); ++o) {
				const BigInt &oAmount = (*o)->Amount();
				addr = (*o)->Addr().String();

				if ((*o)->GetType() == TransactionOutput::VoteOutput) {
					outputPayload = (*o)->GetPayload()->ToJson();
					outputPayload["Amount"] = oAmount.getDec();
					outputPayloads.push_back(outputPayload);
				}

				containAddress = wallet->ContainsAddress((*o)->Addr());
				if (containAddress && !wallet->IsDepositAddress((*o)->Addr())) {
					changeAmount += oAmount;
				} else {
					outputAmount += oAmount;
				}

				if (detail && (direction == "Sent" || (direction != "Sent" && containAddress))) {
					if (outputList.find(addr) == outputList.end()) {
						outputList[addr] = oAmount;
					} else {
						outputList[addr] += oAmount;
					}
				}
			}

			nlohmann::json outputJson;
			for (it = outputList.begin(); it != outputList.end(); ++it) {
				outputJson[it->first] = it->second.getDec();
			}

			if (direction == "Sent" && outputAmount == BigInt(0)) {
				direction = "Moved";
			}

			if (inputAmount > (outputAmount + changeAmount)) {
				fee = (inputAmount - outputAmount - changeAmount).getUint64();
			} else {
				fee = 0;
			}

			BigInt amount(0);
			if (direction == "Received") {
				amount = changeAmount;
			} else if (direction == "Sent") {
				amount = outputAmount;
			} else {
				amount = 0;
			}

			summary["TxHash"] = GetHash().GetHex();
			summary["Status"] = confirms <= 6 ? "Pending" : "Confirmed";
			summary["ConfirmStatus"] = confirms <= 6 ? std::to_string(confirms) : "6+";
			summary["Timestamp"] = GetTimestamp();
			summary["Direction"] = direction;
			summary["Amount"] = amount.getDec();
			summary["Type"] = GetTransactionType();
			summary["Height"] = GetBlockHeight();
			if (detail) {
				std::string memo;
				for (size_t i = 0; i < _attributes.size(); ++i) {
					if (_attributes[i]->GetUsage() == Attribute::Usage::Memo) {
						const bytes_t &memoData = _attributes[i]->GetData();
						memo = std::string((char *)memoData.data(), memoData.size());
						try {
							nlohmann::json memoJson = nlohmann::json::parse(memo);
							if (memoJson.is_object() && memoJson.find("msg") != memoJson.end()) {
								memo.clear();
							}
						} catch (const nlohmann::detail::exception &e) {
							if (memo.find("type:") != std::string::npos &&
								memo.find("text") != std::string::npos &&
								memo.find("ciphertext") == std::string::npos &&
								memo.find("msg:") != std::string::npos) {
								memo = memo.substr(memo.find("msg:") + 4);
							}
						}
						break;
					}
				}

				summary["Fee"] = fee;
				summary["Memo"] = memo;
				summary["Inputs"] = inputJson;
				summary["Outputs"] = outputJson;
				summary["Payload"] = _payload->ToJson(_payloadVersion);
				summary["OutputPayload"] = outputPayloads;

				std::vector<nlohmann::json> attributes;
				for (int i = 0; i < _attributes.size(); ++i) {
					attributes.push_back(_attributes[i]->ToJson());
				}
				summary["Attribute"] = attributes;
			}

			return summary;
		}

		uint256 Transaction::GetShaData() const {
			ByteStream stream;
			SerializeUnsigned(stream);
			return uint256(sha256(stream.GetBytes()));
		}

		PayloadPtr Transaction::InitPayload(uint8_t type) {
			PayloadPtr payload = nullptr;

			if (type == coinBase) {
				payload = PayloadPtr(new CoinBase());
			} else if (type == registerAsset) {
				payload = PayloadPtr(new RegisterAsset());
			} else if (type == transferAsset) {
				payload = PayloadPtr(new TransferAsset());
			} else if (type == record) {
				payload = PayloadPtr(new Record());
			} else if (type == deploy) {
				//todo add deploy _payload
				//_payload = boost::shared_ptr<PayloadDeploy>(new PayloadDeploy());
			} else if (type == sideChainPow) {
				payload = PayloadPtr(new SideChainPow());
			} else if (type == rechargeToSideChain) { // side chain payload
				payload = PayloadPtr(new RechargeToSideChain());
			} else if (type == withdrawFromSideChain) {
				payload = PayloadPtr(new WithdrawFromSideChain());
			} else if (type == transferCrossChainAsset) {
				payload = PayloadPtr(new TransferCrossChainAsset());
			} else if (type == registerProducer || type == updateProducer) {
				payload = PayloadPtr(new ProducerInfo());
			} else if (type == cancelProducer) {
				payload = PayloadPtr(new CancelProducer());
			} else if (type == returnDepositCoin) {
				payload = PayloadPtr(new ReturnDepositCoin());
			} else if (type == registerCR || type == updateCR) {
				payload = PayloadPtr(new CRInfo());
			} else if (type == unregisterCR) {
				payload = PayloadPtr(new UnregisterCR());
			} else if (type == returnCRDepositCoin) {
				payload = PayloadPtr(new ReturnDepositCoin());
			}

			return payload;
		}

		void Transaction::Cleanup() {
			_inputs.clear();
			_outputs.clear();
			_attributes.clear();
			_programs.clear();
			_payload.reset();
		}

		uint8_t Transaction::GetPayloadVersion() const {
			return _payloadVersion;
		}

		void Transaction::SetPayloadVersion(uint8_t version) {
			_payloadVersion = version;
		}

		uint64_t Transaction::GetFee() const {
			return _fee;
		}

		void Transaction::SetFee(uint64_t f) {
			_fee = f;
		}

		bool Transaction::IsEqual(const Transaction *tx) const {
			return (tx == this || _txHash == tx->GetHash());
		}

		uint32_t Transaction::GetConfirms(uint32_t walletBlockHeight) const {
			if (_blockHeight == TX_UNCONFIRMED)
				return 0;

			return walletBlockHeight >= _blockHeight ? walletBlockHeight - _blockHeight + 1 : 0;
		}

	}
}
