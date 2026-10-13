[.[] | select(.month >= "2026-07" and (.month | test("^[0-9]")))] |
group_by(.month + " " + (.model // "?")) |
map(
  (.[0].month) as $m | (.[0].model) as $mod |
  ([.[] | .chars_by] | reduce .[] as $c ({}; reduce ($c|keys[]) as $k (.; .[$k] = ((.[$k]//0) + ($c[$k]//0))))) as $agg |
  ([.[] | .asst_chars] | reduce .[] as $a ({s:0, t:0, g:0};
     .s += ($a.text // 0) | .t += ($a.thinking // 0) | .g += ($a.toolcall_args // 0))) as $a |
  ([$a.s, $a.t, $a.g] | add + 1) as $atot |
  ([.[] | .turns] | add // 0) as $turns |
  {
    month: $m,
    model: $mod,
    n: length,
    med_turns: ([.[]|.turns]|sort|.[length/2|floor]),
    med_peak: ([.[]|.peak_ctx_est]|sort|.[length/2|floor]),
    p90_peak: ([.[]|.peak_ctx_est]|sort|.[length*9/10|floor]),
    pct_gt100k: ((map(select(.peak_ctx_est>100000))|length) * 100 / length | round),
    pct_gt200k: ((map(select(.peak_ctx_est>200000))|length) * 100 / length | round),
    compaction_pct: ((map(select(.compactions>0))|length) * 100 / length | round),
    total_Mtok: (((($agg|to_entries|map(.value//0)|add//0)) / 4 / 1000000) * 10 | round / 10),
    asst_text_pct: (($a.s / $atot * 100) | round),
    asst_think_pct: (($a.t / $atot * 100) | round),
    asst_args_pct: (($a.g / $atot * 100) | round),
    asst_tok_per_turn: ((($a.s+$a.t+$a.g)/4/($turns+1)) | round),
    bash_tok_per_turn: ((($agg["bash"]//0)/4/($turns+1)) | round),
    read_tok_per_turn: ((($agg["read"]//0)/4/($turns+1)) | round),
    big_bash_per_100turns: (((map(.big_results.bash//0)|add) / ($turns+1)) * 100 * 10 | round / 10),
    big_read_per_100turns: (((map(.big_results.read//0)|add) / ($turns+1)) * 100 * 10 | round / 10)
  }
)
| sort_by(.month, -.n)
| .[]
