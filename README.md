# aws-mfa-auth

set AWS environment variables from get-session-token, for use with MFA

source from one's .bashrc/.zshrc - don't execute directly.

## Example .bashrc/.zshrc configuration:

    export AWS_MFA_SERIAL=arn:aws:iam::123456789012:mfa/johndoe
    export AWS_DEFAULT_PROFILE=dayjob
    source ~/src/aws-mfa-auth/aws-mfa-auth.sh

## Requirements

- [jq](https://github.com/stedolan/jq)
- [awscli](https://aws.amazon.com/cli/)
- Credentials must already be setup appropriately in `~/.aws/credentials`.
- `AWS_DEFAULT_PROFILE` must be set to your profile if it is not `default`.
- `AWS_MFA_SERIAL` must be serial or device ID of MFA.

## Usage

```
$ aws-mfa-auth
Tokencode: 123456
$ aws ec2 ...
```

