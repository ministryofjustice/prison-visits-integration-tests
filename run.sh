#!/bin/bash

firefox -v
xvfb-run bundle exec rspec
