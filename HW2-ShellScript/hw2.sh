#!/bin/sh

json_output=false
files_output=false
mismatch_count=0

show_syntax() {
    printf "hw2.sh -i INPUT -o OUTPUT [-c csv|tsv] [-j]\n
        Available Options:\n
        -i: Input file to be decoded
        -o: Output directory
        -c csv|tsv: Output files.[ct]sv
        -j: Output info.json">&2 # stderr
}

decode_data() {
    while IFS= read -r name; do
        IFS= read -r type
        IFS= read -r data
        IFS= read -r md5
        IFS= read -r sha1
        data=$(echo "$data" | openssl base64 -d -A)

        # do it recursively
        if [ "$type" = "hw2" ]; then
            mkdir -p "$output_file/$(dirname "$name")"
            echo "$data" > "$output_file/$name"
            loc_datas=$(yq -r '.files[] | .name, .type, .data, .hash.md5, .hash["sha-1"]' "$output_file/$name")
            echo "$loc_datas" >> "test.txt"
            echo "" >> "test.txt"
            mismatch_count=$((mismatch_count + $(echo "$loc_datas" | decode_data)))
        elif [ "$type" = "file" ]; then

            # data_length=${#data}
            data_length=$(echo "$data" | wc -c | awk '{print $1}')
            # printf "bbbb${data_length}bbbb"

            computed_md5=$(echo "$data" | md5)
            computed_sha1=$(echo "$data" | sha1)

            if [ "$md5" != "$computed_md5" ] || [ "$sha1" != "$computed_sha1" ]; then
                mismatch_count=$((mismatch_count + 1))
                # echo "Mismatched checksums: $mismatch_count"
            fi

            if [ $files_output ] && [ "$format" = "csv" ]; then
                echo "${name},${data_length},$md5,$sha1" >> "$output_file/$csv_file"
                # echo "" >> "$output_file/$csv_file"
            elif [ $files_output ] && [ "$format" = "tsv" ]; then
                printf '%s\t%s\t%s\t%s' "$name" "$data_length" "$md5" "$sha1" >> "$output_file/$tsv_file"
                echo "" >> "$output_file/$tsv_file"
            fi

            mkdir -p "$output_file/$(dirname "$name")"
            echo "$data" > "$output_file/$name"
        fi
    done
    echo $mismatch_count
}

# Parse command-line arguments
while getopts ":i:o:c:j" opt; do
    case $opt in
        i)
            input_file="$OPTARG"
            ;;
        o)
            output_file="$OPTARG"
            ;;
        c)
            format="$OPTARG"
            files_output=true
            if [ "$format" != "csv" ] && [ "$format" != "tsv" ]; then
                show_syntax
                exit 1
            fi
            ;;
        j)
            json_output=true
            ;;
        ?)
            show_syntax
            exit 1
            ;;
    esac
done

# '-z' check if string has zero length 
if [ -z "$input_file" ]; then
    show_syntax
    exit 1
fi

if [ -z "$output_file" ]; then
    show_syntax
    exit 1
fi

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    show_syntax
    exit 1
fi




# mkdir output
rm -r "$output_file"
if [ ! -d "$output_file" ]; then
    mkdir -p "$output_file"
fi
if [ $files_output ]; then
    csv_file="files.csv"
    tsv_file="files.tsv"
    if [ "$format" = "csv" ]; then
        echo "filename,size,md5,sha1" > "$output_file/$csv_file"
    elif [ "$format" = "tsv" ]; then
        printf "filename\tsize\tmd5\tsha1\n" > "$output_file/$tsv_file"
    fi
fi
if $json_output; then
    name=$(grep "name" "$input_file")
    json_file="info.json"
    date=$(date -r  "$(yq -r '.date' "$input_file" )" "+%Y-%m-%dT%H:%M:%S%z" | sed 's/\([0-9]\{2\}\)$/:\1/')

    json_content="{\"name\": \"$(yq -r '.name' "$input_file")\",\"author\": \"$(yq -r '.author' "$input_file")\",\"date\": \"$date\"}"
    echo "$json_content" > "$output_file/$json_file"
fi

mismatch_count=0
datas=$(yq -r '.files[] | .name, .type, .data, .hash.md5, .hash["sha-1"]' "$input_file")
mismatch_count=$(echo "$datas" | decode_data)


# echo "Mismatched checksums: $mismatch_count"
exit "$mismatch_count"



