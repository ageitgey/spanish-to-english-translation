#!/bin/bash -v

cd data

# get En-Es training data
wget -nc http://www.statmt.org/europarl/v7/es-en.tgz -O europarl-es-en.tgz
wget -nc http://opus.nlpl.eu/download.php?f=EMEA/v3/moses/en-es.txt.zip -O emea-en-es.txt.zip
wget -nc http://opus.nlpl.eu/download.php?f=ECB/v1/moses/en-es.txt.zip -O ecb-en-es.txt.zip
wget -nc http://opus.nlpl.eu/download.php?f=DGT/v2019/moses/en-es.txt.zip -O dgt-en-es.txt.zip
wget -nc http://opus.nlpl.eu/download.php?f=Books/v1/moses/en-es.txt.zip -O books-en-es.txt.zip
wget -nc http://opus.nlpl.eu/download.php?f=MultiUN/v1/moses/en-es.txt.zip -O multiun-en-es.txt.zip
wget -nc http://opus.nlpl.eu/download.php?f=TED2013/v1.1/moses/en-es.txt.zip -O ted2013-en-es.txt.zip
wget -nc http://opus.nlpl.eu/download.php?f=Wikipedia/v1.0/moses/en-es.txt.zip -O wikipedia-en-es.txt.zip
wget -nc http://opus.nlpl.eu/download.php?f=OpenSubtitles/v2018/moses/en-es.txt.zip -O OST-en-es.txt.zip

# extract data
tar -xf europarl-es-en.tgz
unzip -o emea-en-es.txt.zip
unzip -o ecb-en-es.txt.zip
unzip -o dgt-en-es.txt.zip
unzip -o books-en-es.txt.zip
unzip -o multiun-en-es.txt.zip
unzip -o ted2013-en-es.txt.zip
unzip -o wikipedia-en-es.txt.zip
unzip -o OST-en-es.txt.zip

# create corpus files
cat Books.en-es.en DGT.en-es.en ECB.en-es.en EMEA.en-es.en europarl-v7.es-en.en MultiUN.en-es.en TED2013.en-es.en OpenSubtitles.en-es.en Wikipedia.en-es.en > corpus-ordered.en
cat Books.en-es.es DGT.en-es.es ECB.en-es.es EMEA.en-es.es europarl-v7.es-en.es MultiUN.en-es.es TED2013.en-es.es OpenSubtitles.en-es.es Wikipedia.en-es.es > corpus-ordered.es

# shuffle
shuf --random-source=corpus-ordered.en corpus-ordered.en > corpus-full.en
shuf --random-source=corpus-ordered.en corpus-ordered.es > corpus-full.es

# Make data splits
head -n -4000 corpus-full.en > corpus.en
head -n -4000 corpus-full.es > corpus.es
tail -n 4000 corpus-full.en > corpus-dev-test.en
tail -n 4000 corpus-full.es > corpus-dev-test.es
head -n 2000 corpus-dev-test.en > corpus-dev.en
head -n 2000 corpus-dev-test.es > corpus-dev.es
tail -n 2000 corpus-dev-test.en > corpus-test.en
tail -n 2000 corpus-dev-test.es > corpus-test.es

cd ..
