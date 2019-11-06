## Introduction

This repository contains a handy script to load GitHub deploy keys in TravisCI jobs.


## Setup

See the initial comments at [`load-deploy-key.sh`](https://github.com/mlocati/travisci-github-deploy-key/blob/master/load-deploy-key.sh)

## Usage

In your TravisCI job, call:

```sh
wget -q -O - https://raw.githubusercontent.com/mlocati/travisci-github-deploy-key/master/load-deploy-key.sh | sh
```
