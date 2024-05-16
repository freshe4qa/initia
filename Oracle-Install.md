## Oracle Setup

Step 1: Clone the repository and build binaries

# Clone repository
``cd $HOME``

``rm -rf slinky``

``git clone https://github.com/skip-mev/slinky.git``

``cd slinky``

``git checkout v0.4.3``

# Build binaries
``make install``

# Move binary to local bin
``mv build/slinky /usr/local/bin/
rm -rf build``

# Step 2: Run oracle
# Create systemd service

sudo tee /etc/systemd/system/slinky.service > /dev/null <<EOF

[Unit]

Description=Initia Slinky Oracle

After=network-online.target

[Service]

User=$USER

ExecStart=$(which slinky) --oracle-config-path $HOME/slinky/config/core/oracle.json --market-map-endpoint 127.0.0.1:17990

Restart=on-failure

RestartSec=30

LimitNOFILE=65535


[Install]

WantedBy=multi-user.target

EOF

# Enable and start service

``sudo systemctl daemon-reload
sudo systemctl enable slinky.service
sudo systemctl start slinky.service``

# Step 3: Validating Prices
Upon launching the oracle, you should observe successful price retrieval from the provider sources. Additionally, you have the option to execute the test client script available in the Slinky repository by using the command:

``make run-oracle-client``

# Step 4: Enable Oracle Vote Extension
In order to utilize the Slinky oracle data in the Initia node, the Oracle setting should be enabled in the config/app.toml file.

![sc](https://github.com/freshe4qa/initia/assets/85982863/d15f4de9-efc9-4903-bf3e-b7e4e8331ced)

# Step 5: Check the systemd logs
To check service logs use command below:

``journalctl -fu slinky --no-hostname``
