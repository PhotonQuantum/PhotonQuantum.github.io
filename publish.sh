#!/bin/bash
set -ev
git clone https://${GH_REF} .deploy_git
cd .deploy_git
git checkout master
cd ../
mv .deploy_git/.git/ ./public/
cd ./public
git config user.name "PhotonQuantum"
git config user.email "cy.n01@outlook.com" 
git add .
git commit -m "Travis CI Auto Builder at `date +"%Y-%m-%d %H:%M"`"
git push --force --quiet "https://${Travis_gh_token}@${GH_REF}" master:master
git push --force --quiet "https://PhotonQuantum:${Travis_co_token}@${CO_REF}" master:master
