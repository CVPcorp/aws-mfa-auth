#
# aws.sh - Handy shell functions to make working with AWS easier
#
# Copyright 2017 Customer Value Partners
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# return private IP of first instance that matches given name
awsip() {
  # verify awscli is installed
  command -v aws >/dev/null 2>&1 || {
    echo >&2 "aws not available on PATH.";
    return 1;
  }

  host=$1
  aws ec2 describe-instances \
    --region us-east-1 \
    --filters "Name=tag:Name,Values=${host}" \
              'Name=instance-state-name,Values=running' \
    --query 'Reservations[*].Instances[*].[PrivateIpAddress]' \
    --output text | head -1
}

awssh() {
  ip=$1
  shift
  ssh $(awsip ${ip}) $@
}

awsmfa() {

    # verify awscli is installed
    command -v aws >/dev/null 2>&1 || {
        echo >&2 "aws not available on PATH.";
        return 1;
    }

    # verify jq is installed
    command -v jq >/dev/null 2>&1 || {
        echo >&2 "jq not available on PATH.";
        return 1;
    }

    # verify AWS_MFA_SERIAL is not empty/unset
    if [ -z "${AWS_MFA_SERIAL}" ]; then
        echo "AWS_MFA_SERIAL is empty or unset.";
        return 1
    fi

    unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN

    # verify aws credentials are set
    aws sts get-caller-identity >/dev/null 2>&1 || { 
        printf >&2 "aws sts get-caller-identity failed. "
        echo "Plase check your AWS_DEFAULT_PROFILE and ~/.aws/credentials.";
        return 1;
    }

    stty -echo
    printf "Tokencode: "
    read tokencode
    stty echo
    printf "\n"

    sts_json=$(aws sts get-session-token --serial-number ${AWS_MFA_SERIAL}\
                                         --token-code ${tokencode})

    export AWS_ACCESS_KEY_ID=$(echo ${sts_json} \
            | jq -r .Credentials.AccessKeyId)

    export AWS_SECRET_ACCESS_KEY=$(echo ${sts_json} \
            | jq -r .Credentials.SecretAccessKey)

    export AWS_SESSION_TOKEN=$(echo ${sts_json} \
            | jq -r .Credentials.SessionToken)

}
