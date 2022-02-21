package keeper_test

import (
	"testing"

	testkeeper "github.com/ppenter/atmos/testutil/keeper"
	"github.com/ppenter/atmos/x/atmos/types"
	"github.com/stretchr/testify/require"
)

func TestGetParams(t *testing.T) {
	k, ctx := testkeeper.AtmosKeeper(t)
	params := types.DefaultParams()

	k.SetParams(ctx, params)

	require.EqualValues(t, params, k.GetParams(ctx))
}
