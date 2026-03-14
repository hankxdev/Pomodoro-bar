#!/bin/bash

STATE="/tmp/pomodoro_state"
LOG="$HOME/pomodoro_log.csv"

WORK=1500
SHORT=300
LONG=900

now(){ date +%s; }

notify(){
osascript -e "display notification \"$1\" with title \"Pomodoro\" sound name \"Glass\""
}

init(){
echo "work,1,$(now),running" > $STATE
}

if [ ! -f "$STATE" ]; then
init
fi

IFS=',' read MODE ROUND START STATUS < $STATE

CURRENT=$(now)

case $MODE in
work) DUR=$WORK;;
short) DUR=$SHORT;;
long) DUR=$LONG;;
esac

ELAPSED=$((CURRENT-START))
LEFT=$((DUR-ELAPSED))

if [ "$STATUS" = "running" ] && [ $LEFT -le 0 ]; then

if [ "$MODE" = "work" ]; then

echo "$(date +%F),$(date +%T),work,$ROUND" >> "$LOG"

if [ $ROUND -lt 4 ]; then
notify "Break 5 minutes"
echo "short,$ROUND,$(now),running" > $STATE
else
notify "Long break 15 minutes"
echo "long,$ROUND,$(now),running" > $STATE
fi

elif [ "$MODE" = "short" ]; then

ROUND=$((ROUND+1))
notify "Start Pomodoro $ROUND"
echo "work,$ROUND,$(now),running" > $STATE

else

notify "New cycle started"
echo "work,1,$(now),running" > $STATE

fi

exit
fi

case $MODE in
work) ICON="🍅 $ROUND/4";;
short) ICON="☕";;
long) ICON="🛌";;
esac

if [ "$STATUS" = "paused" ]; then
echo "⏸ $ICON"
else
MIN=$((LEFT/60))
SEC=$((LEFT%60))
printf "%s %02d:%02d\n" "$ICON" $MIN $SEC
fi

echo "---"

TODAY=$(date +%F)

COUNT=$(grep "^$TODAY" "$LOG" 2>/dev/null | wc -l | tr -d ' ')

FOCUS_SEC=$((COUNT*WORK))

FOCUS_H=$((FOCUS_SEC/3600))
FOCUS_M=$(((FOCUS_SEC%3600)/60))

echo "Today 🍅: $COUNT"
echo "Focus time: ${FOCUS_H}h${FOCUS_M}m"

REMAIN_CYCLES=$((4-ROUND))

REMAIN_TIME=$((LEFT + REMAIN_CYCLES*(WORK+SHORT) + LONG))

FINISH=$(date -r $((CURRENT+REMAIN_TIME)) +"%H:%M")

echo "Finish cycle: $FINISH"

echo "---"

if [ "$STATUS" = "running" ]; then
echo "Pause | bash='$0' param1=pause terminal=false refresh=true"
else
echo "Resume | bash='$0' param1=resume terminal=false refresh=true"
fi

echo "Skip | bash='$0' param1=skip terminal=false refresh=true"
echo "Reset | bash='$0' param1=reset terminal=false refresh=true"

echo "---"
echo "Open Log | bash='open $LOG' terminal=false"

case "$1" in

pause)
IFS=',' read MODE ROUND START STATUS < $STATE
echo "$MODE,$ROUND,$START,paused" > $STATE
;;

resume)
IFS=',' read MODE ROUND START STATUS < $STATE
echo "$MODE,$ROUND,$(now),running" > $STATE
;;

skip)
IFS=',' read MODE ROUND START STATUS < $STATE
echo "$MODE,$ROUND,0,running" > $STATE
;;

reset)
rm "$STATE"
;;

esac