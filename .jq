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

# Count the frequency of the input array after applying the given filter. If the filter produces
# objects, freq_by adds a count field to them, and otherwise it produces {key, count} objects.
#
# Previously I was producing one object with all the counts, but that forced the values being
# counted to be represented as strings.
def freq_by(f):
    reduce .[] as $i ({}; .[$i | {key: f} | tojson] += 1)
    | to_entries
    | map(
        (.key | fromjson | .key) as $key
        | if ($key | type) == "object" then
            $key + {count: .value}
        else
            {$key, count: .value}
        end
    )
;
def freq: freq_by(.);
