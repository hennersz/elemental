function opLogin
  set -gx "OP_SESSION_$OP_ACCOUNT" (op signin -f --raw)
end