from subprocess import Popen, PIPE
from pathlib import Path
import bpe
from websocket import create_connection


# Text Input Processing
NORMALIZE_SCRIPT = Path(__file__).parents[1] / "tools" / "moses-scripts" / "scripts" / "tokenizer" / "normalize-punctuation.perl"
TOKENIZE_SCRIPT = Path(__file__).parents[1] / "tools" / "moses-scripts" / "scripts" / "tokenizer" / "tokenizer.perl"
TRUECASE_SCRIPT = Path(__file__).parents[1] / "tools" / "moses-scripts" / "scripts" / "recaser" / "truecase.perl"
TRUECASE_MODEL = Path(__file__).parents[0] / "model" / "tc.es"
BPE_MODEL = Path(__file__).parents[0] / "model" / "esen.bpe"

# Text Output Processing
DE_BPE_COMMAND = ["sed", r"s/\@\@ //g"]
DE_TRUECASE_SCRIPT = Path(__file__).parents[1] / "tools" / "moses-scripts" / "scripts" / "recaser" / "detruecase.perl"
DE_TOKENIZE_SCRIPT = Path(__file__).parents[1] / "tools" / "moses-scripts" / "scripts" / "tokenizer" / "detokenizer.perl"


def run_script(command, data):
    with Popen(command, stdin=PIPE, stdout=PIPE, stderr=PIPE) as proc:
        out, err = proc.communicate(data.encode("utf-8"))
        return out.decode("utf-8")


def normalize_punctuation(text):
    command = ["perl", NORMALIZE_SCRIPT, "-l", "es"]
    return run_script(command, text)


def tokenize(text):
    command = ["perl", TOKENIZE_SCRIPT, "-a", "-l", "es"]
    return run_script(command, text)


def truecase(text):
    command = ["perl", TRUECASE_SCRIPT, "-model", TRUECASE_MODEL]
    return run_script(command, text)


def apply_bpe(sentences):
    with open(BPE_MODEL) as codes:
        merges = -1
        separator = '@@'
        vocabulary = None
        glossaries = None

        bpe_parser = bpe.BPE(codes, merges, separator, vocabulary, glossaries)

        dropout = 0
        return [bpe_parser.process_line(line, dropout) for line in sentences]


#../../build/marian-server --port 8080 -c model/model.npz.best-translation.npz.decoder.yml -d 0 -b 12 -n1 --mini-batch 64 --maxi-batch 10 --maxi-batch-sort src
def translate_raw_strings(strings):
    results = []
    ws = create_connection("ws://localhost:{}/translate".format(8080))

    for line in strings:
        ws.send(line)
        result = ws.recv()
        results.append(result.rstrip())

    ws.close()
    return results


def remove_bpe_tokens(text):
    command = ["sed", r"s/\@\@ //g"]
    return run_script(command, text)


def de_truecase(text):
    command = [DE_TRUECASE_SCRIPT]
    return run_script(command, text)


def detokenize(text):
    command = [DE_TOKENIZE_SCRIPT, "-l", "en"]
    return run_script(command, text)


def prepare_model_input(sentences):
    text = "\n\n".join(sentences)
    text = normalize_punctuation(text)
    text = tokenize(text)
    text = truecase(text)
    sentences = text.split("\n\n")
    sentences = apply_bpe(sentences)
    return sentences


def clean_model_output(sentences):
    text = "\n\n".join(sentences)
    text = remove_bpe_tokens(text)
    text = de_truecase(text)
    text = detokenize(text)
    sentences = text.split("\n\n")
    return sentences


def translate_sentences(sentences):
    sentences = prepare_model_input(sentences)
    raw_translated_sentences = translate_raw_strings(sentences)
    translation = clean_model_output(raw_translated_sentences)

    return translation
