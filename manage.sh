#!/bin/bash

echo -e "\nManage Script\n"

while getopts ":a:c:d:o:u: l r v h" opt
do
    case $opt in
        a)
                echo "Generating certificate for $OPTARG"
                docker-compose run --rm openvpn easyrsa build-client-full $OPTARG
        ;;
        c)
                echo "Generating certificate for $OPTARG"
                docker-compose run --rm openvpn easyrsa build-client-full $OPTARG nopass
        ;;
        d)
                echo "Revoking certificate for $OPTARG "
                docker-compose run --rm openvpn ovpn_revokeclient $OPTARG remove        
        ;;
        l)
                echo "View user list"
                docker-compose run --rm openvpn ovpn_listclients
        ;;
        r)
                echo "Update certificate"
                docker-compose run --rm openvpn ovpn_getclient_all
                echo "openvpn-data/conf/"                
        ;;
        v)        
                echo "Version information"
                docker exec openvpn openvpn --version
        ;;
        o)        
                echo "OVPN generation"
                docker-compose run --rm openvpn ovpn_getclient $OPTARG > $OPTARG.ovpn
                echo "comp-lzo no" >> $OPTARG.ovpn
                echo "auth-nocache" >> $OPTARG.ovpn
                cp $OPTARG.ovpn ${OPTARG}_full.ovpn
                sed -i '/redirect-gateway def1/d' $OPTARG.ovpn
        ;;
        u)
                echo "Update server certificates for $OPTARG"
                echo "Backuping old files"
                docker-compose run --rm openvpn mv /etc/openvpn/pki/reqs/$OPTARG.req /etc/openvpn/pki/reqs/$OPTARG.req.backup
                docker-compose run --rm openvpn mv /etc/openvpn/pki/private/$OPTARG.key /etc/openvpn/pki/private/$OPTARG.key.backup
                docker-compose run --rm openvpn mv /etc/openvpn/pki/issued/$OPTARG.crt /etc/openvpn/pki/issued/$OPTARG.crt.backup
                echo "Certification generation"
                docker-compose run --rm openvpn easyrsa build-server-full $OPTARG nopass
        ;;
        h)
                echo -e "-a Add user. eg: -a wangyanpeng;\n"
                echo -e "-c Create user without password eg: -c wangyanpeng\n"
                echo -e "-d Revocation of user's certificate. eg: -d wangyanpeng;\n"
                echo -e "-l View user list. eg: -l; \n"
                echo -e "-r Batch generation and update of client configuration files,catalog:openvpn-data/conf/clients . eg: -r;\n"
                echo -e "-v View current version. eg: -v;\n"
                echo -e "-h Get help information. eg: -h;\n"
                echo -e "-o OVPN files generation for specific a user. eg: -o wangyanpeng;\n"
                echo -e "-u Update server certificates. eg: -k wangyanpeng;\n"
        ;;
        ?)
        echo "Unknown parameter"
        echo "-h for help information"
        exit 1;;
    esac
done


