#!/bin/bash

set -e
set -o pipefail

SafeMultisigWalletABI="../ton-labs-contracts/solidity/safemultisig/SafeMultisigWallet.abi.json"
stdlib="../TON-Solidity-Compiler/lib/stdlib_sol.tvm"

if [ -z $5 ]; then

    echo 'USAGE: ./smc-deploy.sh --payer-addr <wallet address to pay for init> --payer-keys <wallet keys path> <source file>'
    echo 'EXAMPLE: ./smc-deploy.sh --payer-addr 0:5dcaaa93f50d148e66d4504457d008528b5ca0d1365146816a80b656520f748d --payer-keys ../keys/fld.keys.json --abi wallet.sol'

else

    contract_name=`basename $5 .sol`
    solc $5
    tvc=`tvm_linker compile $contract_name.code --lib $stdlib | grep 'Saved contract to file' | awk '{print $NF}'`
    echo $tvc
    contract_address=`tonos-cli genaddr $tvc $contract_name.abi.json --genkey $contract_name.keys.json | grep 'Raw address' | awk '{print $NF}'`
    # Change gen key to set key if needed
    echo $contract_address > $contract_name.addr
    tonos-cli call "$2" submitTransaction "{\"dest\":\"$contract_address\",\"value\":1000000000,\"bounce\":false,\"allBalance\":false,\"payload\":\"\"}" --abi $SafeMultisigWalletABI --sign $4
    tonos-cli deploy --abi $contract_name.abi.json --sign $contract_name.keys.json $tvc {}

fi
