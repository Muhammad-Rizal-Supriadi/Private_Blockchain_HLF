
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="MiliterMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/../../../ca/organizations/peer/militer.intelijen.io/peers/peer1.militer.intelijen.io/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/../../../ca/organizations/peer/militer.intelijen.io/users/Admin@militer.intelijen.io/msp
export CORE_PEER_ADDRESS=localhost:7051
export ORDERER_CA=${PWD}/../../../ca/organizations/orderer/orderer.intelijen.io/orderers/orderer1.intelijen.io/msp/tlscacerts/tlsca.orderer1.intelijen.io-cert.pem

CHANNEL_NAME=${1}
INSTANSI=${2}
PEER=${3}

# NOTE: this must be run in a CLI container since it requires jq and configtxlator 
createAnchorPeerUpdate() {
  if [ "$INSTANSI" != "" ]; then
    while read -r CHANNEL_NAME; do
      echo "Fetching channel config for channel $CHANNEL_NAME"
      fetchChannelConfig $CHANNEL_NAME 

      echo "Generating anchor peer update transaction for militer on channel $CHANNEL_NAME"

      if [ $PEER -eq 1 ]; then
        HOST="peer1.militer.intelijen.io"
        PORT=7051
      else
        echo "${PEER} unknown"
      fi

      # Modify the configuration to append the anchor peer 
      jq '.channel_group.groups.Application.groups.'${CORE_PEER_LOCALMSPID}'.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "'$HOST'","port": '$PORT'}]},"version": "0"}}' ${CORE_PEER_LOCALMSPID}config.json > ${CORE_PEER_LOCALMSPID}modified_config.json

      # Compute a config update, based on the differences between 
      # {orgmsp}config.json and {orgmsp}modified_config.json, write
      # it as a transaction to {orgmsp}anchors.tx
      createConfigUpdate ${CHANNEL_NAME}
    done < "$input_file"
  else
      echo "Fetching channel config for channel $CHANNEL_NAME"
      fetchChannelConfig $CHANNEL_NAME 

      echo "Generating anchor peer update transaction for militer on channel $CHANNEL_NAME"

      if [ $PEER -eq 1 ]; then
        HOST="peer1.militer.intelijen.io"
        PORT=7051
      else
        echo "${PEER} unknown"
      fi

      # Modify the configuration to append the anchor peer 
      jq '.channel_group.groups.Application.groups.'${CORE_PEER_LOCALMSPID}'.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "'$HOST'","port": '$PORT'}]},"version": "0"}}' ${CORE_PEER_LOCALMSPID}config.json > ${CORE_PEER_LOCALMSPID}modified_config.json

      # Compute a config update, based on the differences between 
      # {orgmsp}config.json and {orgmsp}modified_config.json, write
      # it as a transaction to {orgmsp}anchors.tx
      createConfigUpdate ${CHANNEL_NAME}
  fi
}

# fetchChannelConfig <org> <channel_id> <output_json>
# Writes the current channel config for a given channel to a JSON file
fetchChannelConfig(){
    echo "Fetching the most recent configuration block for the channel"
    echo
    mkdir -p anchor
    cd anchor
    mkdir -p ${CHANNEL_NAME}_config
    peer channel fetch config ${CHANNEL_NAME}_config/config_block.pb -o 192.168.1.38:7050 --ordererTLSHostnameOverride orderer1.intelijen.io -c $CHANNEL_NAME --tls --cafile "$ORDERER_CA"
    cd ${CHANNEL_NAME}_config
    echo "Decoding config block to JSON and isolating config to ${CORE_PEER_LOCALMSPID}"
    echo 

    configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
    jq '.data.data[0].payload.data.config' config_block.json > "${CORE_PEER_LOCALMSPID}config.json"
}

# createConfigUpdate <channel_id> 
# Takes an original and modified config, and produces the config update tx
# which transitions between the two
createConfigUpdate(){
  configtxlator proto_encode --input "${CORE_PEER_LOCALMSPID}config.json" --type common.Config --output original_config.pb
  configtxlator proto_encode --input "${CORE_PEER_LOCALMSPID}modified_config.json" --type common.Config --output modified_config.pb
  configtxlator compute_update --channel_id "${CHANNEL_NAME}" --original original_config.pb --updated modified_config.pb --output config_update.pb
  configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json
  echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . >config_update_in_envelope.json
  configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output ./../../../profile/anchor/"${CHANNEL_NAME}_anchors.pb"
  cd ../..
}

if [ "$INSTANSI" = "militer" ] || [ "$INSTANSI" = "mil" ]; then
    folder_path='../../instansi/militer/'${1}
    
    for input_file in "$folder_path"/*.txt; do
        # Check if the file is a regular file
        if [ -f "$input_file" ]; then
            createAnchorPeerUpdate
        fi
    done

elif [ "$INSTANSI" = "" ]; then
    createAnchorPeerUpdate
fi