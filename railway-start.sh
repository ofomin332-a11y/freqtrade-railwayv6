#!/bin/sh
set -eu

USERDIR=/freqtrade/user_data
CONFIG="$USERDIR/config.json"

mkdir -p "$USERDIR/strategies"

# Create the standard Freqtrade user directory and SampleStrategy if needed.
if [ ! -f "$USERDIR/strategies/sample_strategy.py" ]; then
    freqtrade create-userdir --userdir "$USERDIR" >/tmp/create-userdir.log 2>&1 || {
        cat /tmp/create-userdir.log
        exit 1
    }
fi

python - <<'PY'
import json, os

path = "/freqtrade/user_data/config.json"
cfg = {
  "max_open_trades": 3,
  "stake_currency": "USDT",
  "stake_amount": "unlimited",
  "dry_run": True,
  "dry_run_wallet": 1000,
  "cancel_open_orders_on_exit": False,
  "trading_mode": "spot",
  "timeframe": "5m",
  "strategy": "SampleStrategy",
  "exchange": {
    "name": os.getenv("FREQTRADE__EXCHANGE__NAME", "binance"),
    "key": os.getenv("FREQTRADE__EXCHANGE__KEY", ""),
    "secret": os.getenv("FREQTRADE__EXCHANGE__SECRET", ""),
    "ccxt_config": {},
    "ccxt_async_config": {},
    "pair_whitelist": ["LINK/USDT"],
    "pair_blacklist": []
  },
  "pairlists": [{"method": "StaticPairList"}],
  "telegram": {
    "enabled": os.getenv("FREQTRADE__TELEGRAM__ENABLED", "true").lower() == "true",
    "token": os.getenv("FREQTRADE__TELEGRAM__TOKEN", ""),
    "chat_id": os.getenv("FREQTRADE__TELEGRAM__CHAT_ID", "")
  },
  "api_server": {
    "enabled": True,
    "listen_ip_address": "0.0.0.0",
    "listen_port": 8080,
    "verbosity": "error",
    "enable_openapi": False,
    "jwt_secret_key": os.getenv("FREQTRADE__API__JWT_SECRET", "change-this-in-railway"),
    "CORS_origins": [],
    "username": os.getenv("FREQTRADE__API__USERNAME", "admin"),
    "password": os.getenv("FREQTRADE__API__PASSWORD", "change-this-in-railway")
  },
  "bot_name": "railway-freqtrade",
  "initial_state": "running",
  "force_entry_enable": False,
  "internals": {"process_throttle_secs": 5}
}
with open(path, "w", encoding="utf-8") as f:
    json.dump(cfg, f, indent=2)
PY

exec freqtrade trade --config "$CONFIG"
