<p align="center">
  <img height="100" height="auto" src="https://github.com/freshe4qa/initia/assets/85982863/0ef9e780-7f6b-41f6-bad1-2da6a18604f9">
</p>

# Artela Testnet — initiation-1

Official documentation:
>- [Validator setup instructions](https://docs.initia.xyz/run-initia-node/running-initia-node)

Explorer:
>- [https://explorer.testnet.initia.xyz](https://explorer.testnet.initia.xyz)

### Minimum Hardware Requirements
 - 4x CPUs; the faster clock speed the better
 - 8GB RAM
 - 100GB of storage (SSD or NVME)

### Recommended Hardware Requirements 
 - 8x CPUs; the faster clock speed the better
 - 16GB RAM
 - 1TB of storage (SSD or NVME)

## Set up your initia fullnode
```
wget https://raw.githubusercontent.com/freshe4qa/initia/main/initia.sh && chmod +x initia.sh && ./initia.sh
```

## Post installation

When installation is finished please load variables into system
```
source $HOME/.bash_profile
```

Synchronization status:
```
initiad status 2>&1 | jq .SyncInfo
```

### Create wallet
To create new wallet you can use command below. Don’t forget to save the mnemonic
```
initiad keys add $WALLET
```

Recover your wallet using seed phrase
```
initiad keys add $WALLET --recover
```

To get current list of wallets
```
initiad keys list
```

## Usefull commands
### Service management
Check logs
```
journalctl -fu initiad -o cat
```

Start service
```
sudo systemctl start initiad
```

Stop service
```
sudo systemctl stop initiad
```

Restart service
```
sudo systemctl restart initiad
```

### Node info
Synchronization info
```
initiad status 2>&1 | jq .SyncInfo
```

Validator info
```
initiad status 2>&1 | jq .ValidatorInfo
```

Node info
```
initiad status 2>&1 | jq .NodeInfo
```

Show node id
```
initiad tendermint show-node-id
```

### Wallet operations
List of wallets
```
initiad keys list
```

Recover wallet
```
initiad keys add $WALLET --recover
```

Delete wallet
```
initiad keys delete $WALLET
```

Get wallet balance
```
initiad query bank balances $INITIA_WALLET_ADDRESS
```

Transfer funds
```
initiad tx bank send $INITIA_WALLET_ADDRESS <TO_INITIA_WALLET_ADDRESS> 10000000uinit
```

### Voting
```
initiad tx gov vote 1 yes --from $WALLET --chain-id=$INITIA_CHAIN_ID
```

### Staking, Delegation and Rewards
Delegate stake
```
initiad tx staking delegate $INITIA_VALOPER_ADDRESS 10000000uinit --from=$WALLET --chain-id=$INITIA_CHAIN_ID --gas=auto
```

Redelegate stake from validator to another validator
```
initiad tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000uinit --from=$WALLET --chain-id=$INITIA_CHAIN_ID --gas=auto
```

Withdraw all rewards
```
initiad tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$INITIA_CHAIN_ID --gas=auto
```

Withdraw rewards with commision
```
initiad tx distribution withdraw-rewards $INITIA_VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$INITIA_CHAIN_ID
```

Unjail validator
```
initiad tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$INITIA_CHAIN_ID \
  --gas=auto
```
