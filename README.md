### Pre-requirements

- tonos-cli
- solc
- tvm_linker
- solc stdlib
- msig abi
- msig wallet with tokens
- check vars(abi and stdlib path) in smc-update.sh smc-deploy.sh debot-deploy.sh

### Contract deploy

#### Usage
```
./smc-deploy.sh --payer-addr <wallet address to pay for init> --payer-keys <wallet keys path> <source file>
```

#### Example
```
./smc-deploy.sh --payer-addr 0:5dcaaa93f50d148e66d4504457d008528b5ca0d1365146816a80b656520f748d --payer-keys ../keys/fld.keys.json wallet.sol
```

### Contract update

#### Usage
```
./smc-update.sh --addr <contract to update> --sign <contract keys path> <source-file>
```

#### Example
```
./smc-update.sh --addr `cat wallet.addr` --sign wallet.keys.json --stdlib wallet.sol
```

### Debot deploy
```
./debot-deploy.sh --payer-addr 0:5dcaaa93f50d148e66d4504457d008528b5ca0d1365146816a80b656520f748d --payer-keys ../keys/fld.keys.json --target-smc-abi wallet.abi.json --target-smc-addr `cat wallet.addr` walletDebot.sol
```

### Debot code update
```
./smc-update.sh --addr `cat walletDebot.addr` --sign walletDebot.keys.json walletDebot.sol
```

### Run Debot
```
tonos-cli debot fetch `walletDebot.addr`
```

#### Decode hex string to text for testing
```
echo 74657374 | xxd -r -p
```
