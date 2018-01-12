#!/bin/sh

wget -qO- https://github.com/lherman-cs/clemson-iprint/releases/download/0.1/iprint.deb > /tmp/iprint.deb && sudo dpkg -i /tmp/iprint.deb
