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
sudo rm -rf /usr/local/go
curl -L https://go.dev/dl/go1.21.6.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
source .bash_profile

# download binary
cd $HOME && rm -rf initia
git clone https://github.com/initia-labs/initia
cd initia
git checkout v0.2.15
make install

# config
initiad config set client chain-id initiation-1
initiad config set client keyring-backend test

# init
initiad init $NODENAME --chain-id initiation-1

# download genesis and addrbook
curl -L https://snapshots-testnet.nodejumper.io/initia-testnet/genesis.json > $HOME/.initia/config/genesis.json
curl -L https://snapshots-testnet.nodejumper.io/initia-testnet/addrbook.json > $HOME/.initia/config/addrbook.json

# set minimum gas price
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.15uinit,0.01uusdc\"|" $HOME/.initia/config/app.toml

# set peers and seeds
SEEDS="2eaa272622d1ba6796100ab39f58c75d458b9dbc@34.142.181.82:26656,c28827cb96c14c905b127b92065a3fb4cd77d7f6@testnet-seeds.whispernode.com:25756,cd69bcb00a6ecc1ba2b4a3465de4d4dd3e0a3db1@initia-testnet-seed.itrocket.net:51656,093e1b89a498b6a8760ad2188fbda30a05e4f300@35.240.207.217:26656,2c729d33d22d8cdae6658bed97b3097241ca586c@195.14.6.129:26019"
PEERS="10b173a6c692fc1d258c10689e7adbc6d0b22ce3@162.55.242.213:55656,b4778656f255169b8b1d660b6af3a0df68d68e65@176.57.189.36:15656,ed8de4a33ce911a831a3051beec2d6b3cfc73051@178.18.252.113:26656,f4e17f407bdae3aaccec2315e98caf422fbbd993@161.97.136.152:26656,f5156525910ffa1ac86fe5f7f412d116017e6644@167.86.73.38:26656,32756a5b2576d48561d20e93544290019418d2a2@45.8.132.174:26656,bda3cd491307b42b33c4ec2bdc86281639261340@109.123.247.209:51656,179f6c659d742bae9fef7751194164cf1dee42b1@82.208.20.66:26656,9466874524152b0454da76463f30dc544faaae80@158.220.112.196:26656,79d78fdbd7bc49e9648b24b40bfa97eea89357d9@38.242.217.43:26656,5c2a752c9b1952dbed075c56c600c3a79b58c395@46.4.25.224:26686,10296651566535f5e70c0dd0c4c7a79a0279d833@161.97.152.133:26656,c5bb9608bad82e4cadb04a82377f9f277002ba05@135.181.170.61:26656,b9f53ace3978ab546b6b90eb5a84236c5a1ce6ca@135.181.239.39:26656,cc01f787c8e1cf849e3b4184067388793c2f5c0d@82.208.20.3:26656,cb498025bcacdaf5884a79759c9d2509b9beacd3@37.27.96.254:26656,3d6b49134755b051576909693bd8cab02fd7ebf5@194.242.57.210:26656,62775997caa3d814c5ad91492cb9d411aea91c58@51.38.53.103:26856,d7b99582e0b224c700bcc6223ce5f6b87f933738@198.244.176.117:51656,4242f5798ae7ed19350f199d13edf00f2386021e@104.251.215.89:26656"
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
sudo tee /etc/systemd/system/initiad.service > /dev/null << EOF
[Unit]
Description=Initia node service
After=network-online.target
[Service]
User=$USER
ExecStart=$(which initiad) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# reset
initiad tendermint unsafe-reset-all --home $HOME/.initia --keep-addr-book
curl https://snapshots-testnet.nodejumper.io/initia-testnet/initia-testnet_latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.initia

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
