#!/bin/bash

# System channel
SYS_CHANNEL="sys-channel"
CHANNEL_NAME=${1}
INSTANSI=${2}

function generateAutomatically() {
    flag=0
    if [ "$INSTANSI" != "" ]; then
        while read -r CHANNEL_NAME; do
            echo "##########    Generating channel artifacts   ##########"
            if [ $flag -eq 0 ]; then
                echo
                echo "# Generate System Genesis Block #"

                configtxgen -profile OrdererGenesis -configPath . -channelID $SYS_CHANNEL  -outputBlock ./profile/genesis.block
                flag=1
            fi
            echo
            echo "# Generate Application Channel $CHANNEL_NAME Configuration #"

            configtxgen -profile MiliterChannel -outputCreateChannelTx ./profile/$CHANNEL_NAME.tx -channelID $CHANNEL_NAME -asOrg MiliterMSP
        done < "$input_file"
    else 
        echo "##########    Generating channel artifacts "$CHANNEL_NAME "   ##########"
        echo
        echo "# Generate System Genesis Block #"

        configtxgen -profile OrdererGenesis -configPath . -channelID $SYS_CHANNEL  -outputBlock ./profile/genesis.block

        echo
        echo "# Generate Application Channel Configuration #"

        configtxgen -profile MiliterChannel -outputCreateChannelTx ./profile/$CHANNEL_NAME.tx -channelID $CHANNEL_NAME -asOrg MiliterMSP
    fi
}

if [ "$INSTANSI" = "militer" ] || [ "$INSTANSI" = "mil" ]; then
    folder_path='../instansi/militer/'${1}
    
    for input_file in "$folder_path"/*.txt; do
        # Check if the file is a regular file
        if [ -f "$input_file" ]; then
            generateAutomatically
        fi
    done

elif [ "$INSTANSI" = "" ]; then
    generateAutomatically
fi