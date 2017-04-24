#!/bin/bash
uname -a
firefox -v
xvfb-run bundle exec rspec
