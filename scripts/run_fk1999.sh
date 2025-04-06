# declare -a models=(facebook/opt-125m facebook/opt-350m facebook/opt-1.3b facebook/opt-2.7b)
declare -a models=(EleutherAI/pythia-70m-deduped EleutherAI/pythia-160m-deduped EleutherAI/pythia-410m-deduped EleutherAI/pythia-1b-deduped EleutherAI/pythia-1.4b-deduped EleutherAI/pythia-2.8b-deduped)

for model in "${models[@]}"
do
    echo "Running $model"
    python src/lm-scores.py --model $model --batch_size 64 --device cuda:0
done


# declare -a models=(facebook/opt-6.7b)
declare -a models=(EleutherAI/pythia-6.9b-deduped EleutherAI/pythia-12b-deduped)

for model in "${models[@]}"
do
    echo "Running $model"
    python src/lm-scores.py --model $model --batch_size 16 --device cuda:0
done
