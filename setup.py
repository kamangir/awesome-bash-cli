from setuptools import setup

from abcli import NAME, VERSION

setup(
    name=NAME,
    author="kamangir",
    version=VERSION,
    description="a framework for quickly building awesome bash cli's for machine vision/deep learning.",
    packages=["abcli"],
)
