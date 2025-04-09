# declare -a models=(facebook/opt-125m facebook/opt-350m facebook/opt-1.3b facebook/opt-2.7b)
# declare -a models=(EleutherAI/pythia-70m-deduped EleutherAI/pythia-160m-deduped EleutherAI/pythia-410m-deduped EleutherAI/pythia-1b-deduped EleutherAI/pythia-1.4b-deduped EleutherAI/pythia-2.8b-deduped)

# for model in "${models[@]}"
# do
#     echo "Running $model"
#     python src/lm-scores.py --model $model --batch_size 64 --device cuda:0
# done


# # declare -a models=(facebook/opt-6.7b)
# declare -a models=(EleutherAI/pythia-6.9b-deduped EleutherAI/pythia-12b-deduped)

# for model in "${models[@]}"
# do
#     echo "Running $model"
#     python src/lm-scores.py --model $model --batch_size 16 --device cuda:0
# done

# declare -a models=(facebook/opt-6.7b)
# declare -a models=(RWKV/rwkv-4-169m-pile RWKV/rwkv-4-430m-pile RWKV/rwkv-4-1b5-pile RWKV/rwkv-4-3b-pile RWKV/rwkv-4-7b-pile)

# for model in "${models[@]}"
# do
#     echo "Running $model"
#     python src/lm-scores.py --model $model --batch_size 16 --device cuda:0
# done


declare -a models=(state-spaces/mamba-130m-hf state-spaces/mamba-370m-hf state-spaces/mamba-790m-hf state-spaces/mamba-1.4b-hf state-spaces/mamba-2.8b-hf)

for model in "${models[@]}"
do
    echo "Running $model"
    python src/lm-scores.py --model $model --batch_size 16 --device cuda:0 --mamba
done
