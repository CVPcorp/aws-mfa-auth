# aws.sh

handy shell functions for working with AWS

source from one's .bashrc/.zshrc - don't execute directly.

## Example .bashrc/.zshrc configuration:

    export AWS_MFA_SERIAL=arn:aws:iam::123456789012:mfa/johndoe
    export AWS_DEFAULT_PROFILE=dayjob
    source ~/src/aws.sh/aws.sh

## Requirements

- [jq](https://github.com/stedolan/jq)
- [awscli](https://aws.amazon.com/cli/)
- Credentials must already be setup appropriately in `~/.aws/credentials`.
- `AWS_DEFAULT_PROFILE` must be set to your profile if it is not `default`.
- `AWS_MFA_SERIAL` must be serial or device ID of MFA.

set AWS environment variables from get-session-token, for use with MFA

## Usage

### awsmfa

```
$ awsmfa
Tokencode: 123456
$ aws ec2 ...
```

### awsip

$ awsip my-instance
10.10.10.10
$

### awssh

$ awssh my-instance 'echo hello from $(hostname)'

hello from ip-10.10.10.10.ec2.internal

