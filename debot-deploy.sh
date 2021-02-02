#!/bin/bash

set -e
set -o pipefail

SafeMultisigWalletABI="../ton-labs-contracts/solidity/safemultisig/SafeMultisigWallet.abi.json"
stdlib="../TON-Solidity-Compiler/lib/stdlib_sol.tvm"

if [ -z ${9} ]; then

    echo 'EXAMPLE: ./debot-deploy.sh --payer-addr 0:5dcaaa93f50d148e66d4504457d008528b5ca0d1365146816a80b656520f748d --payer-keys ../keys/fld.keys.json --target-smc-abi wallet.abi.json --target-smc-addr `cat wallet.addr` walletDebot.sol'

else

    debot_name=`basename ${9} .sol`
    solc ${9}
    tvc=`tvm_linker compile $debot_name.code --lib $stdlib | grep 'Saved contract to file' | awk '{print $NF}'`
    echo $tvc
    debot_address=`tonos-cli genaddr $tvc $debot_name.abi.json --genkey $debot_name.keys.json | grep 'Raw address' | awk '{print $NF}'`
    # Change genkey to setkey if needed
    echo $debot_address > $debot_name.addr
    tonos-cli call "$2" submitTransaction "{\"dest\":\"$debot_address\",\"value\":10000000000,\"bounce\":false,\"allBalance\":false,\"payload\":\"\"}" --abi $SafeMultisigWalletABI --sign $4
    debotabi=`cat $debot_name.abi.json | xxd -ps -c 20000`
    targetabi=`cat ${6} | xxd -ps -c 20000`
    tonos-cli deploy $tvc "{\"debotAbi\":\"$debotabi\",\"targetAbi\":\"$targetabi\",\"targetAddr\":\"${8}\"}" --abi $debot_name.abi.json --sign $debot_name.keys.json

fi
