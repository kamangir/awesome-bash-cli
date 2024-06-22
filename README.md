# 🚀 awesome bash cli (abcli)

🚀 `abcli` is an implementation of [🔻 giza](https://github.com/kamangir/giza) and a language [to speak AI](https://github.com/kamangir/kamangir).

![image](https://github.com/kamangir/assets/blob/main/abcli/marquee.png?raw=true)


[![PyPI version](https://img.shields.io/pypi/v/abcli.svg)](https://pypi.org/project/abcli/)

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

create a copy of [`sample.env`](./sample.env) as `.env` and fill in the secrets.

# branches

- [current](.) active and default branch.
- [main](https://github.com/kamangir/awesome-bash-cli/tree/main) legacy branch, is running on [a cluster of Raspberry pis](https://github.com/kamangir/blue-bracket). ⚠️ do not touch. ⚠️
