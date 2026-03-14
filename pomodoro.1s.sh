#!/bin/bash

STATE="/tmp/pomodoro_state"
PAUSE_FILE="/tmp/pomodoro_paused_left"
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
rm -f "$PAUSE_FILE"
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

if [ "$MODE" = "work" ]; then
  REMAIN_CYCLES=$((4-ROUND))
  if [ $REMAIN_CYCLES -lt 0 ]; then REMAIN_CYCLES=0; fi
  REMAIN_TIME=$((LEFT + REMAIN_CYCLES*(WORK+SHORT) + LONG))
elif [ "$MODE" = "short" ]; then
  REMAIN_CYCLES=$((4-ROUND-1))
  if [ $REMAIN_CYCLES -lt 0 ]; then REMAIN_CYCLES=0; fi
  REMAIN_TIME=$((LEFT + (REMAIN_CYCLES+1)*WORK + REMAIN_CYCLES*SHORT + LONG))
else
  REMAIN_TIME=$LEFT
fi

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
echo "Open Log | bash='open' param1='$LOG' terminal=false"

case "$1" in

pause)
IFS=',' read MODE ROUND START STATUS < $STATE
case $MODE in
  work) P_DUR=$WORK;;
  short) P_DUR=$SHORT;;
  long) P_DUR=$LONG;;
esac
P_ELAPSED=$(($(now)-START))
P_LEFT=$((P_DUR-P_ELAPSED))
if [ $P_LEFT -lt 0 ]; then P_LEFT=0; fi
echo "$P_LEFT" > "$PAUSE_FILE"
echo "$MODE,$ROUND,$START,paused" > $STATE
;;

resume)
IFS=',' read MODE ROUND START STATUS < $STATE
case $MODE in
  work) R_DUR=$WORK;;
  short) R_DUR=$SHORT;;
  long) R_DUR=$LONG;;
esac
SAVED_LEFT=$(cat "$PAUSE_FILE" 2>/dev/null || echo "")
if [ -n "$SAVED_LEFT" ] && [ "$SAVED_LEFT" -gt 0 ] 2>/dev/null; then
  NEW_START=$(($(now)-R_DUR+SAVED_LEFT))
else
  NEW_START=$(now)
fi
echo "$MODE,$ROUND,$NEW_START,running" > $STATE
rm -f "$PAUSE_FILE"
;;

skip)
IFS=',' read MODE ROUND START STATUS < $STATE
case $MODE in
  work) S_DUR=$WORK;;
  short) S_DUR=$SHORT;;
  long) S_DUR=$LONG;;
esac
PAST=$(($(now)-S_DUR-1))
echo "$MODE,$ROUND,$PAST,running" > $STATE
rm -f "$PAUSE_FILE"
;;

reset)
rm -f "$STATE" "$PAUSE_FILE"
;;

esac