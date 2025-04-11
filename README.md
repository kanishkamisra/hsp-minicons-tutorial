# hsp-minicons-tutorial
Code and Analysis for my HSP 2025 online speaker series talk (organized by Yuhan Zhang), where I demonstrate how to use minicons for some computational psycholinguistics methods.

## Requirements

Make sure you have the following installed, all of which can be installed using `pip install <name>`:

```bash
minicons # (auto installs some requirements) make sure you have the latest version.
notebook # for python notebooks
nltk # make sure you at least have the TweetTokenizer available.
```

## Federmeier and Kutas (1999) stimuli

Original paper: https://www.sciencedirect.com/science/article/pii/S0749596X99926608

**Massive shoutout to Kara Federmeier for sharing the data with me!**

Check out this [readme file](./data/README.md) to see the very brief summary of how the cleanup looked like.

Relevant files: `src/preprocess-f&k-1999.ipynb` and `analysis/join-fk1999.R`.

The cleaned stimuli can be found in `data/fk1999-final.csv` or [this link](data/fk1999-final.csv).

## Demo Notebooks and Code

* [Contextualized Word Embeddings playground using](src/MLM-CWE.ipynb) `minicons.cwe`
* [LM Scoring methods playground using](src/lm-scoring%20tutorial.ipynb) `minicons.scorer`
* [Notebook demonstrating a single run for the Federmeier and Kutas (1999) analysis](src/federmeier%20and%20kutas%20-%20single%20run.ipynb)
    * [Resulting HTML version of the notebook](src/federmeier%20and%20kutas%20-%20single%20run.html)
* [Python script that generalizes the code in the above notebook to all 23 (and more) models looked at in the talk](src/lm-scores.py)
* [Bash script that runs analysis for 23 models](scripts/run_fk1999.sh) 
* [RMarkdown Code for generating a semi-nice looking analysis report](analysis/analyze-fk1999.Rmd)
    * [Resulting HTML version of report](analysis/analyze-fk1999.html)
* [A bunch of messy exploratory R code, in case you are interested](analysis/analyze-fk1999.R)


## Citation

If you end up using minicons, I'd appreciate if you cited it using the following bibtex:

```bib
@article{misra2022minicons,
    title={minicons: Enabling Flexible Behavioral and Representational Analyses of Transformer Language Models},
    author={Kanishka Misra},
    journal={arXiv preprint arXiv:2203.13112},
    year={2022}
}
```

Or in APA: 

```
Misra, K. (2022). minicons: Enabling flexible behavioral and representational analyses of transformer language models. arXiv preprint arXiv:2203.13112.
```