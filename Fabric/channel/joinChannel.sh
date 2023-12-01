#!/bin/bash

CHANNEL_NAME=${1}
INSTANSI=${2}
PEER=${3}

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/../ca/organizations/orderer/orderer.intelijen.io/orderers/orderer1.intelijen.io/msp/tlscacerts/tlsca.orderer1.intelijen.io-cert.pem
export PEER_MILITER_CA=${PWD}/../ca/organizations/peer/militer.intelijen.io/peers/peer${PEER}.militer.intelijen.io/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/config/

setGlobalsForPeer(){
    export CORE_PEER_LOCALMSPID="MiliterMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER_MILITER_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../ca/organizations/peer/militer.intelijen.io/users/Admin@militer.intelijen.io/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

removeOldCrypto(){
    rm -rf ./api-2.0/org1-wallet/*
}

joinChannel(){
    if [ "$INSTANSI" != "" ]; then
        while read -r CHANNEL_NAME; do
            setGlobalsForPeer
            echo " Peer $PEER join channel $CHANNEL_NAME"
            peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block 
        done < "$input_file"
    else 
        setGlobalsForPeer
        echo " Peer $PEER join channel $CHANNEL_NAME"
        peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block 
    fi
}

updateAnchorPeer(){
    if [ "$INSTANSI" != "" ]; then
        while read -r CHANNEL_NAME; do
            setGlobalsForPeer
            echo " Peer $PEER anchor in channel $CHANNEL_NAME"
            peer channel update -o 192.168.1.38:7050 --ordererTLSHostnameOverride orderer1.intelijen.io -c $CHANNEL_NAME -f ./artifacts/profile/anchor/${CHANNEL_NAME}_anchors.pb --tls --cafile "$ORDERER_CA"
        done < "$input_file"
    else 
        setGlobalsForPeer
        peer channel update -o 192.168.1.38:7050 --ordererTLSHostnameOverride orderer1.intelijen.io -c $CHANNEL_NAME -f ./artifacts/profile/anchor/${CHANNEL_NAME}_anchors.pb --tls --cafile "$ORDERER_CA"
    fi
}

removeOldCrypto

if [ "$INSTANSI" = "militer" ] || [ "$INSTANSI" = "mil" ]; then
    folder_path='instansi/militer/'${1}
    
    for input_file in "$folder_path"/*.txt; do
        # Check if the file is a regular file
        if [ -f "$input_file" ]; then
            joinChannel
            if [ $PEER -eq 1 ]; then
                updateAnchorPeer
            fi
        fi
    done
else 
    echo "$INSTANSI is not found"
fi

