orderer=1
org_name=${1}
number_of_orderer=${2}
createCertificatesForOrderer() {
  echo "## Enroll the CA admin"
  echo
  mkdir -p organizations/orderer/$org_name.intelijen.io/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/orderer/$org_name.intelijen.io/
  
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca.$org_name.intelijen.io --tls.certfiles ${PWD}/fabric-ca/orderer/tls-cert.pem
  
  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer-intelijen-io.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer-intelijen-io.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer-intelijen-io.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer-intelijen-io.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/orderer/$org_name.intelijen.io/msp/config.yaml

  # ---------------------------------------------------------------------------

  echo
  echo "## Register the orderer admin"
  echo

  fabric-ca-client register --caname ca.$org_name.intelijen.io --id.name "$org_name"Admin --id.secret "$org_name"Adminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/orderer/tls-cert.pem

  mkdir -p organizations/orderer/$org_name.intelijen.io/orderers
  while [ $orderer -le $number_of_orderer ];
  do
    # ---------------------------------------------------------------------------
    echo
    echo "## Orderer $orderer"
    echo
    echo "## Register Orderer$orderer"
    echo

    fabric-ca-client register --caname ca.$org_name.intelijen.io --id.name $org_name$orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/orderer/tls-cert.pem

    mkdir -p organizations/orderer/$org_name.intelijen.io/orderers/$org_name$orderer.intelijen.io

    echo
    echo "## Generate the orderer$orderer msp"
    echo
    
    fabric-ca-client enroll -u https://orderer$orderer:ordererpw@localhost:9054 --caname ca.$org_name.intelijen.io -M ${PWD}/organizations/orderer/$org_name.intelijen.io/orderers/$org_name$orderer.intelijen.io/msp --csr.hosts $org_name$orderer.intelijen.io --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/orderer/tls-cert.pem
    
    cp ${PWD}/organizations/orderer/$org_name.intelijen.io/msp/config.yaml ${PWD}/organizations/orderer/$org_name.intelijen.io/orderers/$org_name$orderer.intelijen.io/msp/config.yaml

    # ---------------------------------------------------------------------------

    echo
    echo "## Generate the orderer$orderer-tls certificates"
    echo

    fabric-ca-client enroll -u https://orderer$orderer:ordererpw@localhost:9054 --caname ca.$org_name.intelijen.io -M ${PWD}/organizations/orderer/$org_name.intelijen.io/orderers/$org_name$orderer.intelijen.io/tls --enrollment.profile tls --csr.hosts $org_name$orderer.intelijen.io --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/orderer/tls-cert.pem

    cp ${PWD}/organizations/orderer/$org_name.intelijen.io/orderers/$org_name$orderer.intelijen.io/tls/tlscacerts/* ${PWD}/organizations/orderer/$org_name.intelijen.io/orderers/$org_name$orderer.intelijen.io/tls/ca.crt
    cp ${PWD}/organizations/orderer/$org_name.intelijen.io/orderers/$org_name$orderer.intelijen.io/tls/signcerts/* ${PWD}/organizations/orderer/$org_name.intelijen.io/orderers/$org_name$orderer.intelijen.io/tls/server.crt
    cp ${PWD}/organizations/orderer/$org_name.intelijen.io/orderers/$org_name$orderer.intelijen.io/tls/keystore/* ${PWD}/organizations/orderer/$org_name.intelijen.io/orderers/$org_name$orderer.intelijen.io/tls/server.key

    mkdir ${PWD}/organizations/orderer/$org_name.intelijen.io/orderers/$org_name$orderer.intelijen.io/msp/tlscacerts
    cp ${PWD}/organizations/orderer/$org_name.intelijen.io/orderers/$org_name$orderer.intelijen.io/tls/tlscacerts/* ${PWD}/organizations/orderer/$org_name.intelijen.io/orderers/$org_name$orderer.intelijen.io/msp/tlscacerts/tlsca.$org_name$orderer.intelijen.io-cert.pem
    
    if [ $orderer -eq 1 ]; then
      mkdir ${PWD}/organizations/orderer/$org_name.intelijen.io/msp/tlscacerts
    fi
    cp ${PWD}/organizations/orderer/$org_name.intelijen.io/orderers/$org_name$orderer.intelijen.io/tls/tlscacerts/* ${PWD}/organizations/orderer/$org_name.intelijen.io/msp/tlscacerts/tlsca.$org_name$orderer.intelijen.io-cert.pem

    echo
    echo ---------------------------------------------------------------------------
    orderer=$((orderer + 1))
  done
  mkdir -p organizations/orderer/$org_name.intelijen.io/users
  mkdir -p organizations/orderer/$org_name.intelijen.io/users/Admin@intelijen.io

  echo
  echo "## Generate the admin msp"
  echo

  fabric-ca-client enroll -u https://"$org_name"Admin:"$org_name"Adminpw@localhost:9054 --caname ca.$org_name.intelijen.io -M ${PWD}/organizations/orderer/$org_name.intelijen.io/users/Admin@intelijen.io/msp --tls.certfiles ${PWD}/fabric-ca/orderer/tls-cert.pem

  cp ${PWD}/organizations/orderer/$org_name.intelijen.io/msp/config.yaml ${PWD}/organizations/orderer/$org_name.intelijen.io/users/Admin@intelijen.io/msp/config.yaml
}

createCertificatesForOrderer