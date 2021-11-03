#!/bin/bash

source /etc/profile

# Variation
Interface=wg
Region=
Hostname=
Telegram_Token=
Telegram_ChatID=
Count=0
ErrorCount=0
URL_Message="https://api.telegram.org/bot$Telegram_Token/sendMessage"
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"

function Start {
    echo -e " [Intro] One-Click Automatically Change IP Script for Cloudflare-WARP"
    echo -e " [Intro] Test System:Ubuntu 20"
    echo -e " [Intro] OpenSource-Project:https://github.com/acacia233/Project-WARP-Unlock"
    echo -e " [Intro] Telegram Channel:https://t.me/cutenicobest"
    echo -e " [Intro] Version:2021-11-3-1"
    Test_Netflix_Access
}

function Test_Netflix_Access {
    result1="$(curl --interface $Interface --user-agent "${UA_Browser}" -fsL --write-out %{http_code} --output /dev/null --max-time 5 "https://www.netflix.com/title/81215567" 2>&1)"
    if [[ "$result1" == "200" ]]; then
        result2="$(curl --interface $Interface --user-agent "${UA_Browser}" -fs --max-time 10 --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/80018499" | cut -d '/' -f4 | cut -d '-' -f1 2>&1)"
        if [[ "$result2" == "$Region" ]]; then
            ErrorCount=0
            Judge
        fi
    elif [[ "$result1" == "403" ]]; then
        ChangeIP
    else
        let ErrorCount++
        if [[ $ErrorCount == 5 ]];then
            curl -s -X POST $URL_Message -d chat_id=$Telegram_ChatID -d text="Node:$Hostname%0ANeed to manually check" >/dev/null
            break
        fi
        Judge
    fi
}

function ChangeIP {
    wg-quick down $Interface >/dev/null 2>&1
    sleep 1
    wg-quick up $Interface >/dev/null 2>&1
    let Count++
    Test_Netflix_Access
}

function Judge {
    if [[ $Count == 0 ]];then
        sleep 30
        echo -e " [Info] Still Working,Skipped..."
        Test_Netflix_Access
    else
        PushNotification
        Test_Netflix_Access
    fi
}

function PushNotification {
    local Message="New WARP IP for Netflix%0ANode:$Hostname%0AChange Times:$Count"
    echo -e " [Info] Change Times:$Count"
    curl -s -X POST $URL_Message -d chat_id=$Telegram_ChatID -d text="$Message" >/dev/null
    Count=0
}

Start
