#!/bin/bash

sed "s/<leancloud_apikey>/$leancloud_apikey/" config.toml -i
sed "s/<leancloud_apiid>/$leancloud_apiid/" config.toml -i
