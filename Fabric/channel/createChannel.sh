#!/bin/bash

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/../ca/organizations/orderer/orderer.intelijen.io/orderers/orderer1.intelijen.io/msp/tlscacerts/tlsca.orderer1.intelijen.io-cert.pem
export PEER_MILITER_CA=${PWD}/../ca/organizations/peer/militer.intelijen.io/peers/peer1.militer.intelijen.io/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/config/

CHANNEL_NAME=${1}
INSTANSI=${2}

setGlobalsForPeer(){
    export CORE_PEER_LOCALMSPID="MiliterMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER_MILITER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../ca/organizations/peer/militer.intelijen.io/users/Admin@militer.intelijen.io/msp
    export CORE_PEER_ADDRESS=localhost:7051
}


createChannel(){
    if [ "$INSTANSI" != "" ]; then
        while read -r CHANNEL_NAME; do
        setGlobalsForPeer
        echo "##########    Creating channel "$CHANNEL_NAME "    ##########"
    
        peer channel create -o localhost:7050 -c $CHANNEL_NAME \
        --ordererTLSHostnameOverride orderer1.intelijen.io \
        -f ./artifacts/profile/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
        done < "$input_file"
    else 
        setGlobalsForPeer
    
        peer channel create -o localhost:7050 -c $CHANNEL_NAME \
        --ordererTLSHostnameOverride orderer1.intelijen.io \
        -f ./artifacts/profile/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    fi
}

if [ "$INSTANSI" = "militer" ] || [ "$INSTANSI" = "mil" ]; then
    folder_path='instansi/militer/'${1}
    
    for input_file in "$folder_path"/*.txt; do
        # Check if the file is a regular file
        if [ -f "$input_file" ]; then
            createChannel
        fi
    done
else 
    echo "$INSTANSI is not found"
fi