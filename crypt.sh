#!/bin/bash
./ffmpeg -i $1 -codec copy -map 0 -f segment -vbsf h264_mp4toannexb -segment_list_size 0 -segment_list liste.m3u8 -segment_time 10  stream%d.ts
encyptionKeyFile="crypt.key"
openssl rand 16 > $encyptionKeyFile
encryptionKey=`cat $encyptionKeyFile | hexdump -e '16/1 "%02x"'`

splitFilePrefix="stream"
encryptedSplitFilePrefix="${splitFilePrefix}enc."

numberOfTsFiles=`ls ${splitFilePrefix}*.ts | wc -l`

for (( i=0; i<$numberOfTsFiles; i++ ))
do
    initializationVector=`printf '%032x' $i`
    openssl aes-128-cbc -e -in ${splitFilePrefix}$i.ts -out ${encryptedSplitFilePrefix}$i.ts -nosalt -iv $initializationVector -K $encryptionKey
    rm ${splitFilePrefix}$i.ts
    mv ${encryptedSplitFilePrefix}$i.ts ${splitFilePrefix}$i.ts
done

sed '5i#EXT-X-KEY:METHOD=AES-128,URI="crypt.key"' liste.m3u8 > list.m3u8
mv list.m3u8 liste.m3u8
