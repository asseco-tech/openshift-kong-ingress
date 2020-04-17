tmp_folder=$1

if [ ! -d "${tmp_folder}" ]; then
  return
fi

# flatten plugins folder to tmp
if [ -d "./plugins" ]; then
    echo "folder: $(pwd)"
    echo "+ Flatten plugins"
    mkdir -p "${tmp_folder}/plugins"
    for folder in $(ls ./plugins 2> /dev/null); do
        plugin_name=$(basename $folder)
        mkdir -p ${tmp_folder}/plugins/${plugin_name}
        find ./plugins/${plugin_name}/ -maxdepth 1 -type f  | grep -E '.' > /dev/null
        [ $? -eq 0 ] && cp -p ./plugins/${plugin_name}/*  ${tmp_folder}/plugins/${plugin_name}/
        if [ -d "./plugins/${plugin_name}/plugin" ]; then
            cp -p ./plugins/${plugin_name}/plugin/* ${tmp_folder}/plugins/${plugin_name}/
        fi
    done;
fi
