#!/bin/bash

source <(curl -s https://raw.githubusercontent.com/bangpateng/symphony/main/logo.sh)

sudo apt update && sudo apt upgrade -y
sudo apt install -y ca-certificates zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev curl git wget make jq build-essential pkg-config lsb-release libssl-dev libreadline-dev libffi-dev gcc screen unzip lz4 python3 python3-pip

python3 --version
pip3 --version

curl --proto '=https' --tlsv1.2 -sSfL https://raw.githubusercontent.com/Dedenwrg/dependencies/main/docker/docker.sh | sudo sh 
sudo groupadd docker
sudo usermod -aG docker $USER

sudo rm -rf /usr/local/go
curl -L https://go.dev/dl/go1.22.4.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> $HOME/.bash_profile
source $HOME/.bash_profile
go version

git clone https://github.com/allora-network/allora-chain.git
cd allora-chain && make all
allorad version

read -p "Enter your Keplr seed phrase: " SEED_PHRASE

cd $HOME
git clone https://github.com/allora-network/basic-coin-prediction-node
cd basic-coin-prediction-node

cat <<EOF > config.json
{
    "wallet": {
        "addressKeyName": "testkey",
        "addressRestoreMnemonic": "$SEED_PHRASE",
        "alloraHomeDir": "",
        "gas": "1000000",
        "gasAdjustment": 1.0,
        "nodeRpc": "https://allora-testnet-rpc.polkachu.com/",
        "maxRetries": 1,
        "delay": 1,
        "submitTx": false
    },
    "worker": [
        {
            "topicId": 1,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 5,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "ETH"
            }
        },
        {
            "topicId": 2,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 5,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "ETH"
            }
        },
        {
            "topicId": 7,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 5,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "ETH"
            }
        }
    ]
}
EOF

chmod +x init.config
./init.config
docker compose up -d --build

echo "Installation and configuration complete. Worker is running."
