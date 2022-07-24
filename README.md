# awesome bash cli (abcli/abc)

![image](./assets/marquee.png)

`abcli` is a framework for quickly building awesome bash cli's for machine vision/deep learning applications, like [this robot](https://github.com/kamangir/blue-rvr) - `abcli` is a [`bashly`](https://github.com/DannyBen/bashly) that doesn't need a docker image to run and expands less painfully.

to see list of `abcli` commands type in:

```
abcli ?
```

---

`abcli` can be installed manually or through the seed. - either way add this line to the end of `~/.bashrc`/`~/.bash_profile` after the install.

```
source ~/git/awesome-bash-cli/bash/abcli.sh
```

## manual install

```
mkdir -p ~/git
cd ~/git
git clone git@github.com:kamangir/awesome-bash-cli.git

conda create -y -n abcli python=3.9
conda activate abcli
pip3 install pymysql==0.10.1

source ~/git/awesome-bash-cli/bash/abcli.sh
```
## install through the seed

find a machine that is already terraformed by `abcli` and open two terminals - in the first terminal ssh to the target machine - in the second terminal run:

```
abcli seed
```

now switch to the first terminal and paste the clipboard (`Ctrl+V`).

---

to configure `abcli` use [these instructions](./bash/bootstrap/config/README.md).


