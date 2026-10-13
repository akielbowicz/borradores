[.[] | select(.month >= "2026-07" and (.month | test("^[0-9]")))] |
group_by(.month) |
map(
  [ .[] | select(.peak_ctx_est > 100000) ] as $big |
  {
    month: .[0].month,
    n: length,
    n_big: ($big | length),
    big_asst_dom: ($big | map(select(((.asst_chars.text//0) + (.asst_chars.thinking//0) + (.asst_chars.toolcall_args//0)) >= ((.chars_by | to_entries | map(.value // 0) | max // 0))) | length) | length),
    big_bash_dom: ($big | map(select((.chars_by["bash"] // 0) > ((.asst_chars.text//0) + (.asst_chars.thinking//0) + (.asst_chars.toolcall_args//0)) and (.chars_by["bash"] // 0) >= ((.chars_by | to_entries | map(.value // 0) | max // 0))) | length) | length),
    big_read_dom: ($big | map(select((.chars_by["read"] // 0) > ((.asst_chars.text//0) + (.asst_chars.thinking//0) + (.asst_chars.toolcall_args//0)) and (.chars_by["read"] // 0) >= ((.chars_by | to_entries | map(.value // 0) | max // 0))) | length) | length),
    med_peak_big: ($big | map(.peak_ctx_est) | sort | .[length/2|floor]),
    # median share of context occupied by each source in big sessions
    med_share_asst: ($big | map((.asst_chars.text//0) + (.asst_chars.thinking//0) + (.asst_chars.toolcall_args//0)) | sort | .[length/2|floor]),
    med_share_bash: ($big | map(.chars_by["bash"] // 0) | sort | .[length/2|floor]),
    med_share_read: ($big | map(.chars_by["read"] // 0) | sort | .[length/2|floor])
  }
)
| .[]
