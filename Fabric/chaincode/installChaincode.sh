PEER=${1}
REGION=${2}

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/../ca/organizations/orderer/orderer.intelijen.io/orderers/orderer1.intelijen.io/msp/tlscacerts/tlsca.orderer1.intelijen.io-cert.pem
export PEER_MILITER_CA=${PWD}/../ca/organizations/peer/militer.intelijen.io/peers/peer${PEER}.militer.intelijen.io/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/../channel/artifacts/config/

setGlobalsForPeer(){
    export CORE_PEER_LOCALMSPID="MiliterMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER_MILITER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../ca/organizations/peer/militer.intelijen.io/users/Admin@militer.intelijen.io/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

CC_RUNTIME_LANGUAGE="node"
VERSION="1"
SEQUENCE="1"
if [ "$REGION" == "militer" ]; then
    CC_SRC_PATH="./chaincode-militer"
    CC_NAME="data-militer"
fi

presetup() {
    CC_RUNTIME_LANGUAGE=$CC_RUNTIME_LANGUAGE
    echo "Compiling TypeScript code into JavaScript..."
    pushd $CC_SRC_PATH
    npm install
    npm run build
    popd
    echo "Finished compiling TypeScript code into JavaScript"
}

packageChaincode() {
    rm -rf ${CC_NAME}.tar.gz
    setGlobalsForPeer
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged ===================== "
}

installChaincode() {
    setGlobalsForPeer
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on node ===================== "
}

presetup
packageChaincode
installChaincode