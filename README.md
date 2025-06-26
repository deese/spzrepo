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


