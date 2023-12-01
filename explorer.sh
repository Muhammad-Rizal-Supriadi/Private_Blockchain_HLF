cp -r Fabric/ca/organizations Explorer

cd Explorer/organizations/peer/militer.intelijen.io/users/Admin@militer.intelijen.io/msp/keystore

# Find the file with a certain pattern in the name
filename=$(find . -type f -name '*_sk' -print -quit)

# Check if filename is empty
if [ -z "$filename" ]; then
  echo "File not found."
else
  # Rename the file
  mv "$filename" priv_sk
  echo "File renamed successfully."
fi

# generate network
cd ../../../../../../../connection-profile

./generate-network.sh ${1} ${2} ${3} ${4}
