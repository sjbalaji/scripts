#!/bin/bash
read PROCESS_NAME
pidof $PROCESS_NAME 
pidof $PROCESS_NAME  | xargs kill -9 