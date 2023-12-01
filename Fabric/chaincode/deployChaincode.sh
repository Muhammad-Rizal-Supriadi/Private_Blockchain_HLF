PEER=${1}
INSTANSI=${2}
CHANNEL_NAME=${3}

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

VERSION="1"
SEQUENCE="1"
if [ "$INSTANSI" == "militer" ]; then
    CC_NAME="data-intelijen"
fi

queryInstalled() {
    setGlobalsForPeer
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer1.militer on channel $CHANNEL_NAME ===================== "
}

approveForMyOrg() {
    setGlobalsForPeer
    peer lifecycle chaincode approveformyorg -o 192.168.1.50:7050 \
        --ordererTLSHostnameOverride orderer1.intelijen.io --tls \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID} \
        --sequence ${SEQUENCE}

    echo "===================== chaincode approved from militer ===================== "

}

checkCommitReadyness() {
    setGlobalsForPeer
    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL_NAME --name ${CC_NAME} -v ${VERSION} \
        --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from militer ===================== "
}

commitChaincodeDefination() {
    setGlobalsForPeer
    peer lifecycle chaincode commit -o 192.168.1.50:7050 --ordererTLSHostnameOverride orderer1.intelijen.io \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER_MILITER_CA \
        --version ${VERSION} --sequence ${SEQUENCE} --init-required
}

queryCommitted() {
    setGlobalsForPeer
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}

chaincodeInvokeInit() {
    setGlobalsForPeer
    peer chaincode invoke -o 192.168.1.50:7050 \
        --ordererTLSHostnameOverride orderer1.intelijen.io \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER_MILITER_CA \
        --isInit -c '{"Args":[]}'

}

deployChaincode() {
    if [ "$INSTANSI" != "n" ]; then
        while read -r CHANNEL_NAME; do
            queryInstalled
            approveForMyOrg
            if [ $PEER -eq 1 ]; then
                checkCommitReadyness
                commitChaincodeDefination
                queryCommitted
                chaincodeInvokeInit
            fi
        done < "$input_file"
    else 
        queryInstalled
        approveForMyOrg
        if [ $PEER -eq 1 ]; then
            checkCommitReadyness
            commitChaincodeDefination
            queryCommitted
            chaincodeInvokeInit
        fi
    fi
}

if [ "$INSTANSI" = "militer" ] || [ "$INSTANSI" = "mil" ]; then
    folder_path='../channel/instansi/militer/'${3}
    
    for input_file in "$folder_path"/*.txt; do
        # Check if the file is a regular file
        if [ -f "$input_file" ]; then
            deployChaincode
        fi
    done
else 
    echo "$INSTANSI is not found"
fi