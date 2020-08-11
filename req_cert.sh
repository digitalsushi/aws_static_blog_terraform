#!/bin/bash

if [ `uname` != "Darwin" ]
then
  echo "This script was only tested on a mac. "
  sleep 5
fi

for tool in "jq aws"
do
  if ! which $tool 2>/dev/null 1>&2
  then
    echo "You must have $tool installed to use this."
    exit 1
   fi
done

# Perform a very basic test to verify your credentials are active.
if ! aws s3 ls 2>/dev/null 1>&2
then
  echo "You must configure the aws command with your credentials to use this."
  exit 1
fi

if ! grep -q __UNKNOWN_WEBSITE_CERTIFICATE__ vars.tf
then
  echo "You seem to already have already set up a certificate."
  echo "I am going to abort because I dont want to disrupt that work."
  exit 0
fi

echo "This script will request a TLS certificate for"
echo "your website using the AWS command."
echo
echo -n "What is the hostname of your website? example, blog.example.com: "
read website_name
echo "Ok, I am going to request a certificate for $website_name in 10 seconds, control-c if you dont want."
sleep 10

cert=$(aws acm request-certificate --domain-name $website_name)

echo $cert > out.txt # output the response to a local file
certarn=$(cat out.txt | jq -r ".CertificateArn")

# This replaces __UNKNOWN_WEBSITE_CERTIFICATE__ inside the vars.tf file with ARN we learned from the aws command.
sed -i "" "s,__UNKNOWN_WEBSITE_CERTIFICATE__,${certarn}," vars.tf

echo "The vars.tf file has been updated with your TLS certificate ARN."
echo "Please go find the email from AWS and complete the authorization to"
echo "turn this into an activate certificate."

echo 
echo Do this before you run the terraform steps, or you will cause yourself a little confusion.
