arg1=${1}
arg2=${2}
arg3=${3}
arg4=${4}
arg5=${5}

# To run the service ./runService.sh CAOrderer 
# To run the service ./runService.sh co
function CAOrderer(){
  cd Fabric/ca
  docker compose up -d ca_orderer
  sudo chmod 777 -R fabric-ca
  cd ../..
}

# To run the service ./runService.sh CAPeer 
# To run the service ./runService.sh cp 
function CAPeer(){
  cd Fabric/ca
  docker compose up -d ca_kpu
  sudo chmod -R 777 fabric-ca
  cd ../..
}

# To run the service ./runService.sh generateCertificateOrderer 
# To run the service ./runService.sh gco 
function generateCertificateOrderer(){
  cd Fabric/ca
  ./generate-certificate-orderer.sh $arg2 $arg3
  cd ../..
}

# To run the service ./runService.sh generateCertificatePeer {nameOrg}
# Example ./runService.sh generateCertificatePeer Kpu
# Example ./runService.sh gcp Kpu
function generateCertificatePeer(){
  cd Fabric/ca
  ./generate-certificate-org.sh $arg4 $arg5
  cd ../..
}

# To run the service ./runService.sh generateArtifactChannel {channelName} {Region} 
# Example ./runService.sh generateArtifactChannel daerah-khusus-ibukota-jakarta kecamatan
# Example ./runService.sh gac daerah-khusus-ibukota-jakarta kec
function generateArtifactChannel(){
  cd Fabric/channel/artifacts
  ./generate-channel-artifacts.sh $arg2 $arg3
  cd ../../..
}

# To run the service ./runService.sh Orderer 
# To run the service ./runService.sh o 
function Orderer(){
  cd Fabric/orderer
  docker compose up -d orderer1.zillabc.io
  cd ../..
}

# To run the service ./runService.sh Peer {noPeer}
# Example ./runService.sh Peer 1 
# Example ./runService.sh p 1 
function Peer(){
  cd Fabric/peer${arg2}
  docker compose up -d
  cd ../..
  # testing
  if [ $arg2 -eq 1 ]; then
    cd Fabric/ca
    docker compose up -d ca_kpu
    cd ../..
  fi 
}

# To run the service ./runService.sh createChannel {channelName} {Region}
# Example ./runService.sh createChannel daerah-khusus-ibukota-jakarta kecamatan
# Example ./runService.sh cc daerah-khusus-ibukota-jakarta kec
function createChannel(){
  cd Fabric/channel
  ./createChannel.sh $arg2 $arg3
  cd ../..
}

# To run the service ./runService.sh generateArtifactAnchor {channelName} {Region} {noPeer}
# Example ./runService.sh generateArtifactAnchor daerah-khusus-ibukota-jakarta kecamatan 1
# Example ./runService.sh gaa daerah-khusus-ibukota-jakarta kec 1
function generateArtifactAnchor(){
  cd Fabric/channel/artifacts/anchor-artifact
  ./setAnchorPeer.sh $arg2 $arg3 $arg4
  rm -rf anchor/
  cd ../../../..
}

# To run the service ./runService.sh joinChannel {channelName} {noPeer}
# Example ./runService.sh joinChannel daerah-khusus-ibukota-jakarta 1 kec
# Example ./runService.sh jc daerah-khusus-ibukota-jakarta 1 kec
function joinChannel(){
  cd Fabric/channel
  ./joinChannel.sh $arg2 $arg3 $arg4
  cd ../..
}

# To run the service ./runService.sh installChaincode {noPeer} {Region}
# Example ./runService.sh installChaincode 1 kecamatan
# Example ./runService.sh icc 1 kec
function installChaincode(){
  cd Fabric/chaincode
  ./installChaincode.sh $arg2 $arg3
  cd ../..
}

# To run the service ./runService.sh deployChaincode {noPeer} {Region} {channelName}
# Example ./runService.sh deployChaincode 1 kecamatan daerah-khusus-ibukota-jakarta
# Example ./runService.sh dcc 1 kec daerah-khusus-ibukota-jakarta
function deployChaincode(){
  cd Fabric/chaincode
  ./deployChaincode.sh $arg2 $arg3 $arg4
  cd ../..
}

# To run the service ./runService.sh stopService {noPeer}
# To run the service ./runService.sh stopService 1
# To run the service ./runService.sh ss 1
function stopService(){
  cd Fabric/peer$arg2
  docker compose down

  cd ..
  cd orderer
  docker compose down
  cd ..

  cd ca
  docker compose down
  cd ..
}

# To run the service ./runService.sh removeCertificate
# To run the service ./runService.sh rc
function removeCertificate(){
  rm -rf Fabric/ca/organizations
  rm -rf Fabric/ca/fabric-ca
}

# To run the service ./runService.sh removeArtifacts
# To run the service ./runService.sh ra
function removeArtifacts(){
  rm -rf Fabric/channel/channel-artifacts/*
  rm -rf Fabric/channel/artifacts/profile/*.tx
  rm -rf Fabric/channel/artifacts/profile/*.block
  rm -rf Fabric/channel/artifacts/profile/anchor/*.pb
}

# To run the service ./runService.sh removeChaincode
# To run the service ./runService.sh rcc
function removeChaincode(){
  rm -rf Fabric/chaincode/log.txt
  rm -rf Fabric/chaincode/*.tar.gz
}

# To run the service ./runService.sh removeApiDoc
# To run the service ./runService.sh rad
function removeApiDoc(){
  rm -rf api-2.0/kpu-wallet
  rm -rf api-2.0/config/connection-kpu.json
}

# To run the service ./runService.sh removeAllFile
# To run the service ./runService.sh raf
function removeAllFile(){
  rm -rf Fabric/ca/organizations
  rm -rf Fabric/ca/fabric-ca
  rm -rf Fabric/channel/channel-artifacts/*
  rm -rf Fabric/channel/artifacts/profile/*.tx
  rm -rf Fabric/channel/artifacts/profile/*.block
  rm -rf Fabric/channel/artifacts/profile/anchor/*.pb
  rm -rf Fabric/chaincode/log.txt
  rm -rf Fabric/chaincode/*.tar.gz
  rm -rf api-2.0/kpu-wallet
  rm -rf api-2.0/config/connection-kpu.json
}

# To run the service ./runService.sh dariAwal {nameOrg}
# Example ./runService.sh dariAwal orderer 1 kpu 3
# Example ./runService.sh da orderer 1 kpu 3
function dariAwal(){
  CAOrderer
  CAPeer
  sleep 1
  generateCertificateOrderer
  sleep 2
  generateCertificatePeer
}

# To run the service ./runService.sh dariAwal2 {channelName} {Region} {noPeer}
# Example ./runService.sh dariAwal2 daerah-khusus-ibukota-jakarta kecamatan 1
# Example ./runService.sh da2 daerah-khusus-ibukota-jakarta kec 1
function dariAwal2(){
  cd Fabric/ca
  docker compose stop ca_kpu
  docker compose rm ca_kpu
  cd ../..
  generateArtifactChannel
  Orderer
  sleep 3
  createChannel
  if [ "$arg4" != "" ]; then
    sleep 3
    generateArtifactAnchor
  fi
  cd Fabric/ca/fabric-ca/kpu
  sudo chmod 777 -R msp/
  sudo chmod 777 -R ca-cert.pem
  sudo chmod 777 -R fabric-ca-server-config.yaml
  sudo chmod 777 -R IssuerPublicKey
  sudo chmod 777 -R IssuerRevocationPublicKey
  sudo chmod 777 -R tls-cert.pem
}

# To run the service ./runService.sh nodeOrderer //testing
# To run the service ./runService.sh no 
function nodeOrderer(){
  CAOrderer
  Orderer
}

# To run the service ./runService.sh chaincodeAll {noPeer} {Region} {channelName}
# Example ./runService.sh chaincodeAll 1 kecamatan daerah-khusus-ibukota-jakarta
# Example ./runService.sh cca 1 kec daerah-khusus-ibukota-jakarta
flag=1
function chaincodeAll(){
  if [ $flag -eq 1 ]; then
    installChaincode
    flag=2
  fi
  deployChaincode
}

if [ "$arg1" == "CAOrderer" ] || [ "$arg1" == "co" ]; then
  CAOrderer
elif [ "$arg1" == "CAPeer" ] || [ "$arg1" == "cp" ]; then
  CAPeer
elif [ "$arg1" == "Orderer" ] || [ "$arg1" == "o" ]; then
  Orderer
elif [ "$arg1" == "Peer" ] || [ "$arg1" == "p" ]; then
  Peer
elif [ "$arg1" == "generateCertificateOrderer" ] || [ "$arg1" == "gco" ]; then
  generateCertificateOrderer
elif [ "$arg1" == "generateCertificatePeer" ] || [ "$arg1" == "gcp" ]; then
  generateCertificatePeer
elif [ "$arg1" == "generateArtifactChannel" ] || [ "$arg1" == "gac" ]; then
  generateArtifactChannel
elif [ "$arg1" == "createChannel" ] || [ "$arg1" == "cc" ]; then
  createChannel
elif [ "$arg1" == "generateArtifactAnchor" ] || [ "$arg1" == "gaa" ]; then
  generateArtifactAnchor
elif [ "$arg1" == "joinChannel" ] || [ "$arg1" == "jc" ]; then
  joinChannel
elif [ "$arg1" == "installChaincode" ] || [ "$arg1" == "icc" ]; then
  installChaincode
elif [ "$arg1" == "deployChaincode" ] || [ "$arg1" == "dcc" ]; then
  deployChaincode
elif [ "$arg1" == "stopService" ] || [ "$arg1" == "ss" ]; then
  stopService
elif [ "$arg1" == "removeCertificate" ] || [ "$arg1" == "rc" ]; then
  removeCertificate
elif [ "$arg1" == "removeArtifacts" ] || [ "$arg1" == "ra" ]; then
  removeArtifacts
elif [ "$arg1" == "removeChaincode" ] || [ "$arg1" == "rcc" ]; then
  removeChaincode
elif [ "$arg1" == "removeApiDoc" ] || [ "$arg1" == "rad" ]; then
  removeApiDoc
elif [ "$arg1" == "removeAllFile" ] || [ "$arg1" == "raf" ]; then
  removeAllFile
elif [ "$arg1" == "dariAwal" ] || [ "$arg1" == "da" ]; then
  dariAwal
elif [ "$arg1" == "dariAwal2" ] || [ "$arg1" == "da2" ]; then
  dariAwal2
elif [ "$arg1" == "nodeOrderer" ] || [ "$arg1" == "no" ]; then
  nodeOrderer
elif [ "$arg1" == "chaincodeAll" ] || [ "$arg1" == "cca" ]; then
  chaincodeAll
fi