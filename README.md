## Introduction

This repository contains a handy script to load GitHub deploy keys in TravisCI jobs.


## Usage

### Generate a private key

- Install OpenSSH on your system (or in a Virtual Machine, Docker container, WSL, ...)
- Generate an RSA private key without a passphrase:
    ```
    ssh-keygen -b 4096 -t rsa -N "" -C "My deploy key" -f github_deploy_key
    ```
- Encrypt the private key
    ```
    openssl aes-256-cbc -e -in github_deploy_key -pass "pass:<a-password-of-your-choice>" -md sha256 -out github_deploy_key.enc
    ```

### Add the key to the GitHub deploy keys

Go to `https://github.com/<username>/<reponame>/settings/keys/new` and enter this data:
  - *Title*  
    a name of your choice
  - *Key*  
    paste the contents of the `github_deploy_key.pub` file
  - *Allow write access*  
    check this if you will need to push to the repository

### Add the decryption password to TravisCI

- Go to `https://travis-ci.org/<username>/<reponame>/settings`
- In the `Environment Variables` section, add a new variable with:
  - *Name*  
    `DEPLOYKEY_PASSWORD`
  - *Value*  
    &lt;a-password-of-your-choice&gt;

### Add the encrypted key to your repository

Add the `github_deploy_key.enc file` file to your repository.  
By default, you can save it as `.travis/github_deploy_key.enc`

### Configure the TravisCI job

- If you didn't save the encrypted key as `.travis/github_deploy_key.enc`, define an environment variable named `DEPLOYKEY_FILE` whose value is the relative path to the encrypted key
- Invoke the following code to load the key so that GIT has (write) access to the repository:
    ```sh
    wget -q -O - https://raw.githubusercontent.com/mlocati/travisci-github-deploy-key/master/load-deploy-key.sh | sh
    ```

## Credits

From a great idea by [@B3rn475](https://github.com/B3rn475).
