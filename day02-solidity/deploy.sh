#!/usr/bin/env bash
set -euo pipefail

# Usage: export BASE_URI, PRIVATE_KEY, RPC_SEPOLIA, optionally DEPLOY_METHOD (script|create)
BASE_URI=${BASE_URI:-"ipfs://VOTRE_CID/"}
DEPLOY_METHOD=${DEPLOY_METHOD:-"script"}

if [ -z "${PRIVATE_KEY:-}" ]; then
  echo "Error: PRIVATE_KEY not set"
  exit 1
fi
if [ -z "${RPC_SEPOLIA:-}" ]; then
  echo "Error: RPC_SEPOLIA not set"
  exit 1
fi

echo "Deploying PoolNFT with baseURI=$BASE_URI using method=$DEPLOY_METHOD"

if [ "$DEPLOY_METHOD" = "script" ]; then
  # Use the Foundry script which reads BASE_URI and PRIVATE_KEY via vm.env*
  export BASE_URI
  # PRIVATE_KEY must be provided as hex without 0x for vm.envUint conversion in script
  # If PRIVATE_KEY starts with 0x, strip it for vm.envUint
  PK="$PRIVATE_KEY"
  PK=${PK#0x}
  export PRIVATE_KEY="$PK"

  forge script script/DeployPoolNFT.s.sol:DeployPoolNFT \
    --rpc-url "$RPC_SEPOLIA" \
    --broadcast \
    -vvvv

else
  # Use forge create with constructor args (baseURI)
  forge create src/PoolNFT.sol:PoolNFT \
    --constructor-args "$BASE_URI" \
    --rpc-url "$RPC_SEPOLIA" \
    --private-key "$PRIVATE_KEY" \
    --broadcast \
    -vvvv
fi

echo "Done. Check the output above for deployed address."
