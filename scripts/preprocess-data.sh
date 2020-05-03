#!/bin/bash -v

# Suffix of source language files
SRC=es

# Suffix of target language files
TRG=en

# Number of merge operations. Network vocabulary should be slightly larger (to
# include characters), or smaller if the operations are learned on the joint
# vocabulary
bpe_operations=85000

# path to moses decoder: https://github.com/moses-smt/mosesdecoder
mosesdecoder=../tools/moses-scripts

# path to subword segmentation scripts: https://github.com/rsennrich/subword-nmt
subword_nmt=../tools/subword-nmt

# tokenize
for prefix in corpus corpus-dev corpus-test
do
    cat data/$prefix.$SRC \
        | $mosesdecoder/scripts/tokenizer/normalize-punctuation.perl -l $SRC \
        | $mosesdecoder/scripts/tokenizer/tokenizer.perl -a -l $SRC > data/$prefix.tok.$SRC

    cat data/$prefix.$TRG \
        | $mosesdecoder/scripts/tokenizer/normalize-punctuation.perl -l $TRG \
        | $mosesdecoder/scripts/tokenizer/tokenizer.perl -a -l $TRG > data/$prefix.tok.$TRG

done

# clean empty and long sentences, and sentences with high source-target ratio (training corpus only)
$mosesdecoder/scripts/training/clean-corpus-n.perl data/corpus.tok $SRC $TRG data/corpus.tok.clean 1 80

# train truecaser
$mosesdecoder/scripts/recaser/train-truecaser.perl -corpus data/corpus.tok.clean.$SRC -model model/tc.$SRC
$mosesdecoder/scripts/recaser/train-truecaser.perl -corpus data/corpus.tok.clean.$TRG -model model/tc.$TRG

# apply truecaser (cleaned training corpus)
for prefix in corpus
do
    $mosesdecoder/scripts/recaser/truecase.perl -model model/tc.$SRC < data/$prefix.tok.clean.$SRC > data/$prefix.tc.$SRC
    $mosesdecoder/scripts/recaser/truecase.perl -model model/tc.$TRG < data/$prefix.tok.clean.$TRG > data/$prefix.tc.$TRG
done

# apply truecaser (dev/test files)
for prefix in corpus-dev corpus-test
do
    $mosesdecoder/scripts/recaser/truecase.perl -model model/tc.$SRC < data/$prefix.tok.$SRC > data/$prefix.tc.$SRC
    $mosesdecoder/scripts/recaser/truecase.perl -model model/tc.$TRG < data/$prefix.tok.$TRG > data/$prefix.tc.$TRG
done

# train BPE
cat data/corpus.tc.$SRC data/corpus.tc.$TRG | $subword_nmt/learn_bpe.py -s $bpe_operations > model/$SRC$TRG.bpe

# apply BPE
for prefix in corpus corpus-dev corpus-test
do
    $subword_nmt/bpe.py -c model/$SRC$TRG.bpe < data/$prefix.tc.$SRC > data/$prefix.bpe.$SRC
    $subword_nmt/bpe.py -c model/$SRC$TRG.bpe < data/$prefix.tc.$TRG > data/$prefix.bpe.$TRG
done
