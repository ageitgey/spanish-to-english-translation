from translate_with_model import translate_sentences
from sentence_splitter import split_text_into_sentences


text = """El niño que vivió.

El señor y la señora Dursley, que vivían en el número 4 de Privet Drive,
estaban orgullosos de decir que eran muy normales, afortunadamente. Eran las
últimas personas que se esperaría encontrar relacionadas con algo extraño o
misterioso, porque no estaban para tales tonterías.

El señor Dursley era el director de una empresa llamada Grunnings, que
fabricaba taladros. Era un hombre corpulento y rollizo, casi sin cuello, aunque
con un bigote inmenso. La señora Dursley era delgada, rubia y tenía un cuello
casi el doble de largo de lo habitual, lo que le resultaba muy útil, ya que pasaba
la mayor parte del tiempo estirándolo por encima de la valla de los jardines
para espiar a sus vecinos. Los Dursley tenían un hijo pequeño llamado Dudley,
y para ellos no había un niño mejor que él."""

sentences = split_text_into_sentences(text.replace("\n", " "), "es")

print("Input:")
print("\n".join(sentences))

print("Output:")
print("\n".join(translate_sentences(sentences)))