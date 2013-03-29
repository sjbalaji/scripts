#!/bin/bash
ssh balaji@10.6.9.44 'pidof java | xargs kill -9 ' 
ssh hadoop@10.6.9.51 'pidof java | xargs kill -9 ' 
ssh hadoop@10.6.9.52 'pidof java | xargs kill -9 ' 