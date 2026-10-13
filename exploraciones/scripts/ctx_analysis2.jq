def textlen:
  if type == "string" then length
  elif type == "array" then map(textlen) | add // 0
  elif type == "object" then
    if .type == "toolCall" then ((.arguments // "") | tostring | length)
    else ((.text // .thinking // "") | length)
    end
  else 0 end;

def acclen:
  if type == "string" then {str: length}
  elif type == "array" then
    (map(acclen) | reduce .[] as $x ({str: 0, think: 0, args: 0};
       .str += ($x.str // 0) | .think += ($x.think // 0) | .args += ($x.args // 0)))
  elif type == "object" then
    if .type == "toolCall" then {args: ((.arguments // "") | tostring | length)}
    elif .type == "thinking" then {think: ((.thinking // "") | length)}
    elif .type == "text" then {str: ((.text // "") | length)}
    else {str: 0}
    end
  else {str: 0} end;

[.[]] as $all
| [$all[] | select(.type == "message")] as $ms
| (reduce $ms[] as $m (
    {by: {}, cum: 0, peak: 0, big: {}, turns: 0,
     asst: {str: 0, think: 0, args: 0}, models: {}};
    . as $s
    | ($m.message.role) as $role
    | if $role == "assistant" then
        ($m.message.content | acclen) as $a
        | .cum += (($a.str // 0) + ($a.think // 0) + ($a.args // 0))
        | .asst.str += ($a.str // 0)
        | .asst.think += ($a.think // 0)
        | .asst.args += ($a.args // 0)
        | .turns += 1
        | .models[$m.message.model] = ((.models[$m.message.model] // 0) + 1)
      elif $role == "user" then
        .cum += ($m.message.content | textlen)
        | .by.user = ((.by.user // 0) + ($m.message.content | textlen))
      elif $role == "toolResult" then
        ($m.message.content | textlen) as $len
        | .cum += $len
        | .by[$m.message.toolName] = ((.by[$m.message.toolName] // 0) + $len)
        | if $len > 25000 then .big[$m.message.toolName] = ((.big[$m.message.toolName] // 0) + 1) else . end
      else . end
    | if .cum > .peak then .peak = .cum else . end
  ))
| reduce ($all[] | select(.type == "compaction") | 1) as $c (.; .compactions += 1)
| ([$ms[] | select(.message.role == "assistant" and .message.provider != null) | .message.provider] | group_by(.) | .[0]) as $p |
  if .turns > 0 then
  {
    file: $file,
    month: ($file | sub("^\\./[^/]*/"; "") | .[0:7]),
    provider: $p,
    model: (.models | to_entries | max_by(.value) | .key),
    turns: .turns,
    compactions: .compactions,
    peak_ctx_est: (.peak / 4 | floor),
    final_ctx_est: (.cum / 4 | floor),
    chars_by: (.by | with_entries(.value = (.value | floor))),
    asst_chars: {text: .asst.str, thinking: .asst.think, toolcall_args: .asst.args},
    big_results: .big
  } else empty end
