#!/bin/env bash

server="windows"

echo "confirm whether ping is working"
ansible $server -m win_ping

echo "show windows's facts"
ansible $server -m setup

echo "show windows process with script module"
ansible $server -m script -a "ps1/showProcess.ps1"
