# abcli plugins

An `abcli` plugin is a mechanism to quickly build a bash cli around existing code to automate parameter selection and other tasks. Here are eamples for `abcli` plugins:

1. [blue-rvr](https://github.com/kamangir/blue-rvr): A low-cost rover that carries a camera, runs deep learning vision models through python and TensorFlow, and is cloud-connected.
1. [blue-bracket](https://github.com/kamangir/blue-bracket): Multiple machine vision & ai designs on raspberry pi and jetson nano on the edge.
1. [rv22](https://github.com/kamangir/RAW-Vancouver-PORTAL-2022): A digital art installation.

To build an `abcli` plugin you need existing code or code under development that is executed through the command line. Then, follow these steps.

1. Checkout the repo.
1. Add the contents of this folder to the repo.
1. Checkout and configure `abcli`.

## Advanced

1. Update [`keywords.py`](../abcli/keywords/keywords.py).
1. Remove the file [`no-browser`](./no-browser) in the repo root and build out the [browser](https://github.com/kamangir/browser) pages.