package spv

import (
	"bytes"
	"errors"

	"github.com/elastos/Elastos.ELA.SideChain/types"

	"github.com/elastos/Elastos.ELA.SPV/bloom"
	spv "github.com/elastos/Elastos.ELA.SPV/interface"
	"github.com/elastos/Elastos.ELA/crypto"
	"github.com/elastos/Elastos.ELA/common"
	"github.com/elastos/Elastos.ELA/common/config"
	ela "github.com/elastos/Elastos.ELA/core/types"
	elapayload "github.com/elastos/Elastos.ELA/core/types/payload"
)

type Config struct {
	// DataDir is the data path to store db files peer addresses etc.
	DataDir string

	// The chain parameters within network settings.
	ChainParams *config.Params

	// PermanentPeers are the peers need to be connected permanently.
	PermanentPeers []string

	// GenesisAddress is the address generated by the side chain genesis block.
	GenesisAddress string
}

type Service struct {
	spv.SPVService
	chainParams *config.Params
}

func NewService(cfg *Config) (*Service, error) {
	spvCfg := spv.Config{
		DataDir:        cfg.DataDir,
		ChainParams:    cfg.ChainParams,
		PermanentPeers: cfg.PermanentPeers,
		OnRollback:     nil, // Not implemented yet
	}

	service, err := spv.NewSPVService(&spvCfg)
	if err != nil {
		return nil, err
	}

	err = service.RegisterTransactionListener(&listener{
		address: cfg.GenesisAddress,
		service: service,
	})
	if err != nil {
		return nil, err
	}

	return &Service{
		SPVService:  service,
		chainParams: cfg.ChainParams,
	}, nil
}

func (s *Service) VerifyTransaction(tx *types.Transaction) error {
	payload, ok := tx.Payload.(*types.PayloadRechargeToSideChain)
	if !ok {
		return errors.New("[VerifyTransaction] Invalid payload PayloadRechargeToSideChain")
	}

	switch tx.PayloadVersion {
	case types.RechargeToSideChainPayloadVersion0:

		proof := new(bloom.MerkleProof)
		mainChainTransaction := new(ela.Transaction)

		reader := bytes.NewReader(payload.MerkleProof)
		if err := proof.Deserialize(reader); err != nil {
			return errors.New("[VerifyTransaction] RechargeToSideChain payload deserialize failed")
		}

		reader = bytes.NewReader(payload.MainChainTransaction)
		if err := mainChainTransaction.Deserialize(reader); err != nil {
			return errors.New("[VerifyTransaction] RechargeToSideChain mainChainTransaction deserialize failed")
		}

		if err := s.SPVService.VerifyTransaction(*proof, *mainChainTransaction); err != nil {
			return errors.New("[VerifyTransaction] SPV module verify transaction failed.")
		}

	case types.RechargeToSideChainPayloadVersion1:

		_, err := s.GetTransaction(&payload.MainChainTransactionHash)
		if err != nil {
			return errors.New("[VerifyTransaction] Main chain transaction not found")
		}

	default:
		return errors.New("[VerifyTransaction] invalid payload version.")
	}

	return nil
}

func (s *Service) verifyCRCArbiter(publicKey []byte) error {
	for _, v := range s.chainParams.CRCArbiters {
		CRC, err := common.HexStringToBytes(v)
		if err != nil {
			return err
		}
		if bytes.Equal(CRC, publicKey) {
			return nil
		}
	}
	return errors.New("CRC arbiter expected")
}

func (s *Service) CheckCRCArbiterSignature(sideChainPowTx *ela.Transaction) error {
	payload, ok := sideChainPowTx.Payload.(*elapayload.SideChainPow)
	if !ok {
		return errors.New("[checkCRCArbiterSignature], invalid sideChainPow tx")
	}
	if len(sideChainPowTx.Programs[0].Code) != 35 {
		return errors.New("[checkCRCArbiterSignature], invalid program")
	}
	publicKey := sideChainPowTx.Programs[0].Code[1:34]
	if err := s.verifyCRCArbiter(publicKey); err != nil {
		return err
	}

	buf := new(bytes.Buffer)
	if err := payload.SerializeUnsigned(buf, elapayload.SideChainPowVersion); err != nil {
		return err
	}
	pubKey, err := crypto.DecodePoint(publicKey)
	if err != nil {
		return err
	}

	return crypto.Verify(*pubKey, buf.Bytes(), payload.Signature)
}

type listener struct {
	address string
	service spv.SPVService
}

func (l *listener) Address() string {
	return l.address
}

func (l *listener) Type() ela.TxType {
	return ela.TransferCrossChainAsset
}

func (l *listener) Flags() uint64 {
	return spv.FlagNotifyInSyncing
}

func (l *listener) Notify(id common.Uint256, proof bloom.MerkleProof, tx ela.Transaction) {
	l.service.SubmitTransactionReceipt(id, tx.Hash())
}
