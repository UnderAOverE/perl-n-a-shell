if telnet localhost 80 </dev/null 2>&1 | grep -q Connected; then
  echo "Connected"
else
  echo "no connection"
fi

