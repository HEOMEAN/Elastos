package blockchain

import (
	"errors"

	"github.com/elastos/Elastos.ELA/config"
	"github.com/elastos/Elastos.ELA/core"
	"github.com/elastos/Elastos.ELA/log"

	"github.com/elastos/Elastos.ELA.Utility/common"
)

type ArbitratorsConfig struct {
	ArbitratorsCount uint32
	CandidatesCount  uint32
	MajorityCount    uint32
}

type ArbitratorsListener interface {
	OnNewElection()
}

type Arbitrators interface {
	NewBlocksListener

	GetArbitrators() [][]byte
	GetCandidates() [][]byte
	GetNextArbitrators() [][]byte
	GetNextCandidates() [][]byte

	GetOnDutyArbitrator() []byte
	GetNextOnDutyArbitrator(offset uint32) []byte

	HasArbitersMajorityCount(num uint32) bool
	HasArbitersMinorityCount(num uint32) bool

	RegisterListener(listener ArbitratorsListener)
	UnregisterListener(listener ArbitratorsListener)
}

type arbitrators struct {
	config           ArbitratorsConfig
	dutyChangedCount uint32

	currentArbitrators [][]byte
	candidates         [][]byte

	nextArbitrators [][]byte
	nextCandidates  [][]byte

	listener ArbitratorsListener
}

func (a *arbitrators) OnBlockReceived(b *core.Block, confirmed bool) {
	if confirmed {
		a.onChainHeightIncreased()
	}
}

func (a *arbitrators) OnConfirmReceived(p *core.DPosProposalVoteSlot) {
	a.onChainHeightIncreased()
}

func (a *arbitrators) GetArbitrators() [][]byte {
	return a.currentArbitrators
}

func (a *arbitrators) GetCandidates() [][]byte {
	return a.candidates
}

func (a *arbitrators) GetNextArbitrators() [][]byte {
	return a.nextArbitrators
}

func (a *arbitrators) GetNextCandidates() [][]byte {
	return a.nextCandidates
}

func (a *arbitrators) GetOnDutyArbitrator() []byte {
	return a.GetNextOnDutyArbitrator(uint32(0))
}

func (a *arbitrators) GetNextOnDutyArbitrator(offset uint32) []byte {
	arbitrators := a.GetArbitrators()
	height := DefaultLedger.Store.GetHeight()
	index := (height + offset) % uint32(len(arbitrators))
	arbitrator := arbitrators[index]

	return arbitrator
}

func (a *arbitrators) HasArbitersMajorityCount(num uint32) bool {
	return num >= a.config.MajorityCount
}

func (a *arbitrators) HasArbitersMinorityCount(num uint32) bool {
	return num > a.config.ArbitratorsCount-a.config.MajorityCount
}

func (a *arbitrators) RegisterListener(listener ArbitratorsListener) {
	a.listener = listener
}

func (a *arbitrators) UnregisterListener(listener ArbitratorsListener) {
	a.listener = nil
}

func (a *arbitrators) onChainHeightIncreased() {
	if a.isNewElection() {
		a.changeCurrentArbitrators()

		if err := a.updateNextArbitrators(); err != nil {
			log.Error("Update arbitrators error: ", err)
		}

		if a.listener != nil {
			a.listener.OnNewElection()
		}
	} else {
		a.dutyChangedCount++
	}
}

func (a *arbitrators) isNewElection() bool {
	return a.dutyChangedCount == a.config.ArbitratorsCount-1
}

func (a *arbitrators) changeCurrentArbitrators() {
	a.currentArbitrators = a.nextArbitrators
	a.candidates = a.nextCandidates
	a.dutyChangedCount = 0
}

func (a *arbitrators) updateNextArbitrators() error {
	producers, err := a.parseProducersDesc()
	if err == nil {
		return err
	}

	if uint32(len(producers)) < a.config.ArbitratorsCount {
		return errors.New("Producers count less than arbitrators count.")
	}

	a.nextArbitrators = producers[:a.config.ArbitratorsCount]
	a.sortArbitrators()

	if uint32(len(producers)) < a.config.ArbitratorsCount+a.config.CandidatesCount {
		a.nextCandidates = producers[a.config.ArbitratorsCount:]
	} else {
		a.nextCandidates = producers[a.config.ArbitratorsCount : a.config.ArbitratorsCount+a.config.CandidatesCount]
	}

	return nil
}

func (a *arbitrators) sortArbitrators() {
	//todo sort arbitrators
}

func (a *arbitrators) parseProducersDesc() ([][]byte, error) {
	//todo parse by get vote results instead
	if len(config.Parameters.Arbiters) == 0 {
		return nil, errors.New("arbiters not configured")
	}

	var arbitersByte [][]byte
	for _, arbiter := range config.Parameters.Arbiters {
		arbiterByte, err := common.HexStringToBytes(arbiter)
		if err != nil {
			return nil, err
		}
		arbitersByte = append(arbitersByte, arbiterByte)
	}

	return arbitersByte, nil
}

func NewArbitrators(arbitratorsConfig ArbitratorsConfig) Arbitrators {
	if arbitratorsConfig.MajorityCount > arbitratorsConfig.ArbitratorsCount {
		log.Error("Majority count should less or equal than arbitrators count.")
		return nil
	}

	return &arbitrators{
		config: arbitratorsConfig,
	}
}
