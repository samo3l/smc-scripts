#!/bin/bash

set -e
set -o pipefail

if [ -z ${13} ]; then

    echo 'EXAMPLE: ./debot-deploy.sh --payer-addr 0:af1eec292203b858a374c06992e37d6a3df90b34e2c5362dc5f332cf41b4d53e --payer-keys ./keys.json --payer-abi ../ton-labs-contracts/solidity/safemultisig/SafeMultisigWallet.abi.json --stdlib ../TON-Solidity-Compiler/lib/stdlib_sol.tvm --traget-smc-abi wallet-new.abi.json --target-smc-addr 0:d1f5e216bb5d18847218ac11c8c2975f2d6ce274a327c95748bbc11179caad30 walletDebot.sol'

else

    debot_name=`basename ${13} .sol`
    solc ${13}
    tvc=`tvm_linker compile $debot_name.code --lib $8 | grep 'Saved contract to file' | awk '{print $NF}'`
    echo $tvc
    debot_address=`tonos-cli genaddr $tvc $debot_name.abi.json --genkey $debot_name.keys.json | grep 'Raw address' | awk '{print $NF}'`
    # Change genkey to setkey if needed
    echo $debot_address > $debot_name.addr
    tonos-cli call "$2" submitTransaction "{\"dest\":\"$debot_address\",\"value\":10000000000,\"bounce\":false,\"allBalance\":false,\"payload\":\"\"}" --abi $6 --sign $4
    debotabi=`cat $debot_name.abi.json | xxd -ps -c 20000`
    targetabi=`cat ${10} | xxd -ps -c 20000`
    tonos-cli deploy $tvc "{\"debotAbi\":\"$debotabi\",\"targetAbi\":\"$targetabi\",\"targetAddr\":\"${12}\"}" --abi $debot_name.abi.json --sign $debot_name.keys.json

fi
