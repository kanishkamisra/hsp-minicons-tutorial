declare -a models=(facebook/opt-125m facebook/opt-350m facebook/opt-1.3b facebook/opt-2.7b)

for model in "${models[@]}"
do
    echo "Running $model"
    python src/lm-scores.py --model $model --batch_size 64 --device cuda:0
done


declare -a models=(facebook/opt-6.7b)

for model in "${models[@]}"
do
    echo "Running $model"
    python src/lm-scores.py --model $model --batch_size 16 --device cuda:0
done
