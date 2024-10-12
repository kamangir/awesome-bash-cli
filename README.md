# 🪄 awesome bash cli (abcli)

🪄 `abcli` is an implementation of 🔻 [giza](https://github.com/kamangir/giza) and a language [to speak AI](https://github.com/kamangir/kamangir).

![image](https://github.com/kamangir/assets/blob/main/awesome-bash-cli/marquee-9-306-1.png?raw=true)

# release install

not recommended.

```bash
pip install abcli
```

# dev install

on macOS:

```bash
# change shell to bash
chsh -s /bin/bash

mkdir git
cd git
git clone git@github.com:kamangir/awesome-bash-cli.git

nano ~/.bash_profile
# add "source $HOME/git/awesome-bash-cli/abcli/.abcli/abcli.sh"
# restart the terminal

cd ~/Downloads
curl -o Miniconda3-latest-MacOSX-x86_64.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
bash ./Miniconda3-latest-MacOSX-x86_64.sh

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install awscli

aws configure

git config --global user.name kamangir
git config --global user.email arash@kamangir.net
```

on other environments:

- [Amazon EC2 instances](https://github.com/kamangir/awesome-bash-cli/wiki/ec2)
- [Amazon SageMaker](https://github.com/kamangir/notebooks-and-scripts/blob/main/SageMaker.md)
- [Jetson Nano](https://github.com/kamangir/awesome-bash-cli/wiki/Jetson-Nano)
- [Raspberry Pi](https://github.com/kamangir/awesome-bash-cli/wiki/Raspberry-Pi)

# configuration

create a copy of [`sample.env`](./abcli/sample.env) as `.env` and fill in the secrets.

# branches

- [current](.) active and default branch.
- [main](https://github.com/kamangir/awesome-bash-cli/tree/main) legacy branch, is running on [a cluster of Raspberry pis](https://github.com/kamangir/blue-bracket). ⚠️ do not touch. ⚠️

---


to use on [AWS SageMaker](https://aws.amazon.com/sagemaker/) replace `<plugin-name>` with "abcli" and follow [these instructions](https://github.com/kamangir/notebooks-and-scripts/blob/main/SageMaker.md).

[![pylint](https://github.com/kamangir/awesome-bash-cli/actions/workflows/pylint.yml/badge.svg)](https://github.com/kamangir/awesome-bash-cli/actions/workflows/pylint.yml) [![pytest](https://github.com/kamangir/awesome-bash-cli/actions/workflows/pytest.yml/badge.svg)](https://github.com/kamangir/awesome-bash-cli/actions/workflows/pytest.yml) [![bashtest](https://github.com/kamangir/awesome-bash-cli/actions/workflows/bashtest.yml/badge.svg)](https://github.com/kamangir/awesome-bash-cli/actions/workflows/bashtest.yml) [![PyPI version](https://img.shields.io/pypi/v/abcli.svg)](https://pypi.org/project/abcli/)

built by 🌀 [`blue_options-4.105.1`](https://github.com/kamangir/awesome-bash-cli), based on 🪄 [`abcli-9.348.1`](https://github.com/kamangir/awesome-bash-cli).
