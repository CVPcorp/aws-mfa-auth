#
# aws-mfa-auth.sh - set AWS environment variables from get-session-token
#
aws-mfa-auth() {

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
