#!/bin/bash

while true
do

# Logo

echo -e '\e[40m\e[91m'
echo -e '  ____                  _                    '
echo -e ' / ___|_ __ _   _ _ __ | |_ ___  _ __        '
echo -e '| |   |  __| | | |  _ \| __/ _ \|  _ \       '
echo -e '| |___| |  | |_| | |_) | || (_) | | | |      '
echo -e ' \____|_|   \__  |  __/ \__\___/|_| |_|      '
echo -e '            |___/|_|                         '
echo -e '\e[0m'

sleep 2

# Menu

PS3='Select an action: '
options=(
"Install"
"Create Wallet"
"Create Validator"
"Exit")
select opt in "${options[@]}"
do
case $opt in

"Install")
echo "============================================================"
echo "Install start"
echo "============================================================"

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export INITIA_CHAIN_ID=initiation-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

# update
sudo apt update && sudo apt upgrade -y

# packages
apt install curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y

# install go
if ! [ -x "$(command -v go)" ]; then
ver="1.21.3" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile
fi

# download binary
cd $HOME && rm -rf initia
git clone https://github.com/initia-labs/initia.git
cd initia
git checkout v0.2.14
make install

# config
#initiad config chain-id $INITIA_CHAIN_ID
#initiad config keyring-backend test

# init
initiad init $NODENAME --chain-id $INITIA_CHAIN_ID

# download genesis and addrbook
curl -Ls https://snapshots.kjnodes.com/initia-testnet/genesis.json > $HOME/.initia/config/genesis.json
curl -Ls https://snapshots.kjnodes.com/initia-testnet/addrbook.json > $HOME/.initia/config/addrbook.json

# set minimum gas price
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.15uinit,0.01uusdc\"|" $HOME/.initia/config/app.toml

# set peers and seeds
SEEDS="3f472746f46493309650e5a033076689996c8881@initia-testnet.rpc.kjnodes.com:17959"
PEERS="a1de81504903d857695804f34e5bc1c1b9fc734a@84.46.242.232:27656,fc37e22ae9405cf00a775a014366d428376e47b3@37.27.48.77:29656,7b154ee09e2951855ec5d9f82e4ea9a418fd0d54@194.180.176.246:27656,0b95a857ad0d8a4ab3aa68df2c9cfe6aeca71137@195.26.249.54:27656,d5519e378247dfb61dfe90652d1fe3e2b3005a5b@65.109.68.190:17956,07b627ea619769312fa9c852f40fa29daeb916cb@161.97.138.215:656,7e07c1d69e3f726d985614728c601b759f008e52@213.199.57.83:27656,24a57fb7ac6bd4bffdd168e7dcb124e3cfb1b1cc@65.108.132.163:27656,e114eb5d7d5877ea4b55c2833bc426f15b7065b2@144.91.107.151:26656,8b0e3e893500e5684208fa3aa957e0d7dc0d590b@164.68.127.26:26656,0b7b49eb50574397a9668f4b384da663ffddbd38@195.26.249.63:27656,4f9b24bbe1d8a108f4f856d4125a7a6457b1b8cd@142.132.199.231:27656,fe19d84d88e615dc100bac74dd743400b4d082d1@195.26.249.58:27656,d17ee18866f8665b065acd9c3fcad115d4c15ec1@107.189.159.17:26656,00189d81f898492c4e809ad86a8fa4d5be4bbf47@185.130.226.240:27656,7481e81e7f97ae3fbb64e369eda09111de15a7cc@185.130.227.105:27656,023ae541c9872b472d83def3866aa2f2e8e404d4@152.42.220.129:27656,32a0eb0cfbfd3a48fa5db5ae5270c6d8b097b8d5@195.26.252.57:27656,d1259ad88b1f6d41ebb852dd7a58f0254b11de40@43.134.127.208:27656,3d36d9a8f489439267c81650341574d3172931ff@43.163.9.244:27656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.initia/config/config.toml

# disable indexing
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.initia/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.initia/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.initia/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.initia/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.initia/config/app.toml
sed -i "s/snapshot-interval *=.*/snapshot-interval = 0/g" $HOME/.initia/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.initia/config/config.toml

# create service
sudo tee /etc/systemd/system/initiad.service > /dev/null <<EOF
[Unit]
Description=initiad Daemon
After=network-online.target
[Service]
User=$USER
ExecStart=$(which initiad) start
Restart=always
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# reset
initiad tendermint unsafe-reset-all --home $HOME/.initia --keep-addr-book
curl -L https://snapshots.kzvn.xyz/initia/initiation-1_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.initia

# start service
sudo systemctl daemon-reload
sudo systemctl enable initiad
sudo systemctl restart initiad

break
;;

"Create Wallet")
initiad keys add $WALLET
echo "============================================================"
echo "Save address and mnemonic"
echo "============================================================"
INITIA_WALLET_ADDRESS=$(initiad keys show $WALLET -a)
INITIA_VALOPER_ADDRESS=$(initiad keys show $WALLET --bech val -a)
echo 'export INITIA_WALLET_ADDRESS='${INITIA_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export INITIA_VALOPER_ADDRESS='${INITIA_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile

break
;;

"Create Validator")
initiad tx mstaking create-validator \
--amount 1000000uinit \
--pubkey $(initiad tendermint show-validator) \
--moniker $NODENAME \
--chain-id initiation-1 \
--commission-rate 0.05 \
--commission-max-rate 0.20 \
--commission-max-change-rate 0.05 \
--from wallet \
--gas-adjustment 1.4 \
--gas=300000 \
--gas-prices 0.15uinit \
-y
 
  
break
;;

"Exit")
exit
;;
*) echo "invalid option $REPLY";;
esac
done
done
