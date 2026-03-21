def leaf_path_counts:
    [path(.. | scalars)]
    | map(map(numbers |= "[]") | join("."))
    | reduce .[] as $p ({}; .[$p] += 1)
;

def leaf_value_counts(max):
    . as $root
    | [path(.. | scalars)]
    | reduce .[] as $p (
        {};
        ($p | map(numbers |= "[]") | join(".")) as $agg_path
        | if (max < 0) or (.[$agg_path] | length < max) then
            .[$agg_path][$root | getpath($p) | tostring] += 1
        else
            .[$agg_path]["$OTHER"] += 1
        end

    )
;
def leaf_value_counts: leaf_value_counts(-1);

def freq_by(f): reduce .[] as $i ({}; .[$i | f | tostring] += 1);
def freq: freq_by(.);
