import argparse
import pathlib
import utils

from minicons import scorer
from torch.utils.data import DataLoader
from tqdm import tqdm


def main(args):
    model = args.model
    model_name = model.replace("/", "__")
    output_dir = args.output_dir

    if "gpt2" in model_name or "pythia" in model_name:
        bos_token = True
    else:
        bos_token = False

    lm = scorer.IncrementalLMScorer(model, device=args.device)

    parameters = lm.model.num_parameters()

    stimuli = utils.read_csv_dict("data/fk1999-final.csv")
    batches = DataLoader(stimuli, batch_size=args.batch_size)

    results = []
    for batch in tqdm(batches):
        prefix = batch["prefix"]
        idx = batch["item"]

        expected = batch["expected"]
        within_category = batch["within_category"]
        between_category = batch["between_category"]

        dist = lm.next_word_distribution(prefix, bos_token=bos_token).detach().cpu()
        entropies = (-1.0 * (dist * dist.exp()).sum(1)).tolist()

        expected_scores = lm.conditional_score(
            prefix, expected, bos_token=bos_token, reduction=lambda x: x.sum().item()
        )
        within_scores = lm.conditional_score(
            prefix,
            within_category,
            bos_token=bos_token,
            reduction=lambda x: x.sum().item(),
        )
        between_scores = lm.conditional_score(
            prefix,
            between_category,
            bos_token=bos_token,
            reduction=lambda x: x.sum().item(),
        )

        for i, entropy, e, w, b in zip(
            idx, entropies, expected_scores, within_scores, between_scores
        ):
            results.append((i, entropy, e, w, b, parameters))

    pathlib.Path(output_dir).mkdir(parents=True, exist_ok=True)

    # with open(f"{output_dir}/{model_name}.csv", "w") as f:
    utils.write_csv(
        data=results,
        path=f"{output_dir}/{model_name}.csv",
        header=[
            "item",
            "entropy",
            "expected_logprob",
            "within_logprob",
            "between_logprob",
            "parameters",
        ],
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", type=str, default="gpt2")
    parser.add_argument("--device", type=str, default="cpu")
    parser.add_argument("--batch_size", type=int, default=32)
    parser.add_argument("--output_dir", type=str, default="results/fk1999/")

    args = parser.parse_args()

    main(args)
