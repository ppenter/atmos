package atmos_test

import (
	"testing"

	keepertest "github.com/ppenter/atmos/testutil/keeper"
	"github.com/ppenter/atmos/testutil/nullify"
	"github.com/ppenter/atmos/x/atmos"
	"github.com/ppenter/atmos/x/atmos/types"
	"github.com/stretchr/testify/require"
)

func TestGenesis(t *testing.T) {
	genesisState := types.GenesisState{
		Params: types.DefaultParams(),

		// this line is used by starport scaffolding # genesis/test/state
	}

	k, ctx := keepertest.AtmosKeeper(t)
	atmos.InitGenesis(ctx, *k, genesisState)
	got := atmos.ExportGenesis(ctx, *k)
	require.NotNil(t, got)

	nullify.Fill(&genesisState)
	nullify.Fill(got)

	// this line is used by starport scaffolding # genesis/test/assert
}
