# spzrepo

This is the code to deploy custom repositories (APT/YUM) using S3 and Cloudfront. 

This setup requires a domain managed by you but you can use it without but you will need to change the code a bit.

## Configuration

### APT

```curl -fsSL "https://apt.spezialk.net/apt/pubkey.gpg" | gpg --dearmor -o /etc/apt/keyrings/spezialk.gpg
deb [signed-by=/etc/apt/keyrings/spezialk.gpg] https://apt.spezialk.net/apt/ plucky main
```

## AWS Access

Set the variables AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY to allow access to the terraform provider to your AWS account.
Refer to the terraform documentation on how to create the account and the keys.


## GPG Keys

### Create a new key
 
```gpg --full-generate-key```


### Export the keys


```gpg --list-keys
export KEYID="GPG KEY ID"
gpg --export-secret-keys --armor  $KEYID > private.asc
gpg --export --armor $KEYID > pubkey.gpg
```

### Import a private key

``` gpg --import private.asc ```


## AWS Budget

The solution creates an SNS topic that can be used to receive budget alarms and will trigger a lambda to stop the cloudfront distribution. This is helpful to avoid massive expenses due to an attack or miss-configuration. 

Terraform does not support budget alerts so you have to create it manually and point the action to the SNS topic. 

The email account needs to be verified before being able to receive the notifications. 


TODO
====

- Add an update function to avoid re-creating all the repo when a new file is added.
- Provida a REST API to add/remove files (depends on the update function)

