#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local P1P=$(one_line_pem $5)
    local P2P=$(one_line_pem $6)
    local P3P=$(one_line_pem $7)
    local OP=$(one_line_pem $8)
    local CP=$(one_line_pem $9)
    sed -e "s/\${HOSTO}/$1/" \
        -e "s/\${HOSTP1}/$2/" \
        -e "s/\${HOSTP2}/$3/" \
        -e "s/\${HOSTP3}/$4/" \
        -e "s#\${PEER1PEM}#$P1P#" \
        -e "s#\${PEER2PEM}#$P2P#" \
        -e "s#\${PEER3PEM}#$P3P#" \
        -e "s#\${OPEM}#$OP#" \
        -e "s#\${CAPEM}#$CP#" \
        ./ccp-template.yaml
}

HOSTO=192.168.1.37
HOSTP1=192.168.1.50
HOSTP2=192.168.1.42
HOSTP3=192.168.1.33
HOSTCA=192.168.1.50
PEER1PEM=../../Fabric/ca/organizations/peer/militer.intelijen.io/peers/peer1.militer.intelijen.io/tls/tlscacerts/tls-localhost-7054-ca-militer-intelijen-io.pem
PEER2PEM=../../Fabric/ca/organizations/peer/militer.intelijen.io/peers/peer2.militer.intelijen.io/tls/tlscacerts/tls-localhost-7054-ca-militer-intelijen-io.pem
PEER3PEM=../../Fabric/ca/organizations/peer/militer.intelijen.io/peers/peer3.militer.intelijen.io/tls/tlscacerts/tls-localhost-7054-ca-militer-intelijen-io.pem
OPEM=../../Fabric/ca/organizations/orderer/orderer.intelijen.io/orderers/orderer1.intelijen.io/tls/tlscacerts/tls-localhost-9054-ca-orderer-intelijen-io.pem
CAPEM=../../Fabric/ca/organizations/peer/militer.intelijen.io/msp/tlscacerts/ca.crt

echo "$(json_ccp $HOSTO $HOSTP1 $HOSTP2 $HOSTP3 $PEER1PEM $PEER2PEM $PEER3PEM $OPEM $CAPEM )" > connection-militer.json
echo "Connection Generated"

CHANNEL=${1}
MODE=${2}
REGION=${3}

function one_line_pem {
    echo "`awk 'NF {sub(/\\n*$/, ""); printf "%s\\\n",$0;}' $1`"
}

function many() {
    function template(){
        while read -r CHANNEL_NAME || [ -n "$CHANNEL_NAME" ]; do
            function json_ccp {
                local CP=$(one_line_pem $2)
                sed -e "s/\${CHANNEL_NAME}/$1/" \
                    -e "s#\${ISI}#$CP#" \
                    ./connection-militer.json
            }
            ISI=./isi.txt
            echo "$(json_ccp $CHANNEL_NAME $ISI)" > connection-militer.json
        done < "$input_file"
    }
    if [ "$REGION" == "militer" ] || [ "$REGION" == "mil" ]; then
        folder_path=../../Fabric/channel/instansi/militer/$CHANNEL
        for input_file in "$folder_path"/*.txt; do
            # Check if the file is a regular file
            if [ -f "$input_file" ]; then
                template
            fi
        done
        echo "new connection profile for $CHANNEL is added"
    fi
}
function single(){
    CHANNEL_NAME=$CHANNEL
    function json_ccp {
        local CP=$(one_line_pem $2)
        sed -e "s/\${CHANNEL_NAME}/$1/" \
            -e "s#\${ISI}#$CP#" \
            ./connection-militer.json
    }
    ISI=./isi.txt
    echo "$(json_ccp $CHANNEL_NAME $ISI)" > connection-militer.json
    echo "new connection profile for $CHANNEL is added"
}

if [ "$MODE" == "many" ]; then
  many
elif [ "$MODE" == "single" ]; then
  single
fi
