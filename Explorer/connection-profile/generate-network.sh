#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n*$/, ""); printf "%s\\\n",$0;}' $1`"
}

CHANNEL=${1}
MODE=${2}
MODE2=${3}
REGION=${4}

function new() {
    function many() {
        function template(){
            while read -r CHANNEL_NAME || [ -n "$CHANNEL_NAME" ]; do
                if [ $flag -eq 1 ]; then
                    function json_ccp {
                        local CP=$(one_line_pem $2)
                        sed -e "s/\${CHANNEL_NAME}/$1/" \
                            -e "s#\${ISI}#$CP#" \
                            ./first-network_2.2.json
                    }
                fi
                if [ $flag -eq 0 ]; then
                    function json_ccp {
                        local CP=$(one_line_pem $2)
                        sed -e "s/\${CHANNEL_NAME}/$1/" \
                            -e "s#\${ISI}#$CP#" \
                            ./first-network-template.yaml
                    }
                    flag=1
                fi
                ISI=./isi.txt
                echo "$(json_ccp $CHANNEL_NAME $ISI)" > first-network_2.2.json
            done < "$input_file"
        }
        if [ "$REGION" == "kecamatan" ] || [ "$REGION" == "kec" ]; then
            folder_path=../../Fabric/channel/data-wilayah/kecamatan/$CHANNEL
            flag=0
            for input_file in "$folder_path"/*.txt; do
                # Check if the file is a regular file
                if [ -f "$input_file" ]; then
                    template
                fi
            done
            echo "file connection profile for $CHANNEL is generated"
        fi
        if [ "$REGION" == "kabupaten" ] || [ "$REGION" == "kab" ]; then
            input_file=../../Fabric/channel/data-wilayah/kabupaten/${CHANNEL}.txt
            flag=0
            template
            echo "file connection profile for $CHANNEL is generated"
        fi
        if [ "$REGION" == "provinsi" ] || [ "$REGION" == "prov" ]; then
            input_file=../../Fabric/channel/data-wilayah/provinsi/$CHANNEL.txt
            flag=0
            template
            echo "file connection profile for $CHANNEL is generated"
        fi
    }
    function single(){
        CHANNEL_NAME=$CHANNEL

        function json_ccp {
            local CP=$(one_line_pem $2)
            sed -e "s/\${CHANNEL_NAME}/$1/" \
                -e "s#\${ISI}#$CP#" \
                ./first-network-template.json
        }
        ISI=./isi.txt
        echo "$(json_ccp $CHANNEL_NAME $ISI)" > first-network_2.2.json
        echo "file connection profile for $CHANNEL is generated"
    }
}

function exist() {
    function many() {
        function template(){
            while read -r CHANNEL_NAME || [ -n "$CHANNEL_NAME" ]; do
                function json_ccp {
                    local CP=$(one_line_pem $2)
                    sed -e "s/\${CHANNEL_NAME}/$1/" \
                        -e "s#\${ISI}#$CP#" \
                        ./first-network_2.2.json
                }
                ISI=./isi.txt
                echo "$(json_ccp $CHANNEL_NAME $ISI)" > first-network_2.2.json
            done < "$input_file"
        }
        if [ "$REGION" == "kecamatan" ] || [ "$REGION" == "kec" ]; then
            folder_path=../../Fabric/channel/data-wilayah/kecamatan/$CHANNEL
            for input_file in "$folder_path"/*.txt; do
                # Check if the file is a regular file
                if [ -f "$input_file" ]; then
                    template
                fi
            done
            echo "new connection profile for $CHANNEL is added"
        fi
        if [ "$REGION" == "kabupaten" ] || [ "$REGION" == "kab" ]; then
            input_file=../../Fabric/channel/data-wilayah/kabupaten/$CHANNEL.txt
            template
            echo "new connection profile for $CHANNEL is added"
        fi
        if [ "$REGION" == "provinsi" ] || [ "$REGION" == "prov" ]; then
            input_file=../../Fabric/channel/data-wilayah/provinsi/$CHANNEL.txt
            template
            echo "new connection profile for $CHANNEL is added"
        fi
    }
    function single(){
        CHANNEL_NAME=$CHANNEL

        function json_ccp {
            local CP=$(one_line_pem $2)
            sed -e "s/\${CHANNEL_NAME}/$1/" \
                -e "s#\${ISI}#$CP#" \
                ./first-network_2.2.json
        }

        ISI=./isi.txt
        echo "$(json_ccp $CHANNEL_NAME $ISI)" > first-network_2.2.json
        echo "new connection profile for $CHANNEL is added"
    }
}

if [ "$MODE" == "new" ]; then
  new
  if [ "$MODE2" == "many" ]; then
    many
  elif [ "$MODE2" == "single" ]; then
    single
  fi
elif [ "$MODE" == "exist" ]; then
  exist
  if [ "$MODE2" == "many" ]; then
    many
  elif [ "$MODE2" == "single" ]; then
    single
  fi
fi