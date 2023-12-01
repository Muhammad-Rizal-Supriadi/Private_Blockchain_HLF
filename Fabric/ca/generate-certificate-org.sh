peer=1
org_name=${1}
number_of_peer=${2}
createcertificatesForMiliter() {
  echo 
  echo "## Enroll the CA admin"
  echo
  mkdir -p organizations/peer/$org_name.intelijen.io/
  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peer/$org_name.intelijen.io/

  
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca.$org_name.intelijen.io --tls.certfiles ${PWD}/fabric-ca/$org_name/tls-cert.pem
  
  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-militer-intelijen-io.pem 
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-militer-intelijen-io.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-militer-intelijen-io.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-militer-intelijen-io.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peer/$org_name.intelijen.io/msp/config.yaml

  echo
  echo "## Register user"
  echo
  fabric-ca-client register --caname ca.$org_name.intelijen.io --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/$org_name/tls-cert.pem

  echo
  echo "## Register the org admin"
  echo
  fabric-ca-client register --caname ca.$org_name.intelijen.io --id.name "$org_name"admin --id.secret "$org_name"adminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/$org_name/tls-cert.pem

  mkdir -p organizations/peer/$org_name.intelijen.io/peers
  while [ $peer -le $number_of_peer ];
  do
    # --------------------------------------------------------------------------------------------------
    echo
    echo "## Peer $peer"
    echo
    echo "## Register Peer$peer"
    echo
    fabric-ca-client register --caname ca.$org_name.intelijen.io --id.name peer$peer --id.secret peerpw --id.type peer --tls.certfiles ${PWD}/fabric-ca/$org_name/tls-cert.pem

    mkdir -p organizations/peer/$org_name.intelijen.io/peers/peer$peer.$org_name.intelijen.io

    echo
    echo "## Generate the peer$peer msp"
    echo
    fabric-ca-client enroll -u https://peer$peer:peerpw@localhost:7054 --caname ca.$org_name.intelijen.io -M ${PWD}/organizations/peer/$org_name.intelijen.io/peers/peer$peer.$org_name.intelijen.io/msp --csr.hosts peer$peer.$org_name.intelijen.io --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/$org_name/tls-cert.pem

    cp ${PWD}/organizations/peer/$org_name.intelijen.io/msp/config.yaml ${PWD}/organizations/peer/$org_name.intelijen.io/peers/peer$peer.$org_name.intelijen.io/msp/config.yaml

    # ---------------------------------------------------------------------------------------------------

    echo
    echo "## Generate the peer$peer-tls certificates"
    echo
    fabric-ca-client enroll -u https://peer$peer:peerpw@localhost:7054 --caname ca.$org_name.intelijen.io -M ${PWD}/organizations/peer/$org_name.intelijen.io/peers/peer$peer.$org_name.intelijen.io/tls --enrollment.profile tls --csr.hosts peer$peer.$org_name.intelijen.io --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/$org_name/tls-cert.pem

    cp ${PWD}/organizations/peer/$org_name.intelijen.io/peers/peer$peer.$org_name.intelijen.io/tls/tlscacerts/* ${PWD}/organizations/peer/$org_name.intelijen.io/peers/peer$peer.$org_name.intelijen.io/tls/ca.crt
    cp ${PWD}/organizations/peer/$org_name.intelijen.io/peers/peer$peer.$org_name.intelijen.io/tls/signcerts/* ${PWD}/organizations/peer/$org_name.intelijen.io/peers/peer$peer.$org_name.intelijen.io/tls/server.crt
    cp ${PWD}/organizations/peer/$org_name.intelijen.io/peers/peer$peer.$org_name.intelijen.io/tls/keystore/* ${PWD}/organizations/peer/$org_name.intelijen.io/peers/peer$peer.$org_name.intelijen.io/tls/server.key

    if [ $peer -eq 1 ]; then
      mkdir ${PWD}/organizations/peer/$org_name.intelijen.io/msp/tlscacerts
    fi
    cp ${PWD}/organizations/peer/$org_name.intelijen.io/peers/peer$peer.$org_name.intelijen.io/tls/tlscacerts/* ${PWD}/organizations/peer/$org_name.intelijen.io/msp/tlscacerts/ca.crt

    if [ $peer -eq 1 ]; then
      mkdir ${PWD}/organizations/peer/$org_name.intelijen.io/tlsca
    fi
    cp ${PWD}/organizations/peer/$org_name.intelijen.io/peers/peer$peer.$org_name.intelijen.io/tls/tlscacerts/* ${PWD}/organizations/peer/$org_name.intelijen.io/tlsca/tlsca.$org_name.intelijen.io-cert.pem

    if [ $peer -eq 1 ]; then
      mkdir ${PWD}/organizations/peer/$org_name.intelijen.io/ca
    fi
    cp ${PWD}/organizations/peer/$org_name.intelijen.io/peers/peer$peer.$org_name.intelijen.io/msp/cacerts/* ${PWD}/organizations/peer/$org_name.intelijen.io/ca/ca.$org_name.intelijen.io-cert.pem

    echo
    echo --------------------------------------------------------------------------------------------------
    peer=$((peer + 1))
  done

  mkdir -p organizations/peer/$org_name.intelijen.io/users
  mkdir -p organizations/peer/$org_name.intelijen.io/users/User1@$org_name.intelijen.io

  echo
  echo "## Generate the user msp"
  echo
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca.$org_name.intelijen.io -M ${PWD}/organizations/peer/$org_name.intelijen.io/users/User1@$org_name.intelijen.io/msp --tls.certfiles ${PWD}/fabric-ca/$org_name/tls-cert.pem

  mkdir -p organizations/peer/$org_name.intelijen.io/users/Admin@$org_name.intelijen.io

  echo
  echo "## Generate the org admin msp"
  echo
  fabric-ca-client enroll -u https://"$org_name"admin:"$org_name"adminpw@localhost:7054 --caname ca.$org_name.intelijen.io -M ${PWD}/organizations/peer/$org_name.intelijen.io/users/Admin@$org_name.intelijen.io/msp --tls.certfiles ${PWD}/fabric-ca/$org_name/tls-cert.pem

  cp ${PWD}/organizations/peer/$org_name.intelijen.io/msp/config.yaml ${PWD}/organizations/peer/$org_name.intelijen.io/users/Admin@$org_name.intelijen.io/msp/config.yaml

}

createcertificatesForMiliter

