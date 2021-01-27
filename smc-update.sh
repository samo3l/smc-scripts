#!/bin/bash

set -e
set -o pipefail

if [ -z $7 ]; then

    echo 'USAGE: ./smc-update.sh --addr <contract to update> --sign <contract keys path> --stdlib <stdlib_sol.tvm path> <new-source-file>'
    echo 'EXAMPLE: ./smc-update.sh --addr 0:fb17e26079c78425bc6db760f6d641346cd667cc6286f35121ab585765188bbe --sign wallet.keys.json --stdlib ../TON-Solidity-Compiler/lib/stdlib_sol.tvm wallet-new.sol'

else

    contract_name=`basename $7 .sol`
    solc $7
    tvc=`tvm_linker compile $contract_name.code --lib $6 | grep 'Saved contract to file' | awk '{print $NF}'`
    newcode=`tvm_linker decode --tvc $tvc | grep 'code:' | awk '{print $NF}'`
    tonos-cli call $2 setCode "{\"newcode\":\"$newcode\"}" --abi $contract_name.abi.json --sign $4

fi
