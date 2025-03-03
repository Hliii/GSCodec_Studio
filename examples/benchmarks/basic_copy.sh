SCENE_DIR="/data1/hli/dataset/mip_nerf360"
RESULT_DIR="/data1/hli/gscodec"
SCENE_LIST="bicycle" #"garden bicycle stump bonsai counter kitchen room" # treehill flowers
RENDER_TRAJ_PATH="ellipse"

for SCENE in $SCENE_LIST;
do
    if [ "$SCENE" = "bonsai" ] || [ "$SCENE" = "counter" ] || [ "$SCENE" = "kitchen" ] || [ "$SCENE" = "room" ]; then
        DATA_FACTOR=2
    else
        DATA_FACTOR=4
    fi

    echo "Running $SCENE"

    # train without eval
    CUDA_VISIBLE_DEVICES=0 python simple_trainer_scaffold.py default --eval_steps -1 --disable_viewer --data_factor $DATA_FACTOR \
        --render_traj_path $RENDER_TRAJ_PATH \
        --data_dir $SCENE_DIR/$SCENE/ \
        --result_dir $RESULT_DIR/$SCENE/

    # run eval and render
    for CKPT in $RESULT_DIR/$SCENE/ckpts/*;
    do
        CUDA_VISIBLE_DEVICES=0 python simple_trainer_scaffold.py default --disable_viewer --data_factor $DATA_FACTOR \
            --render_traj_path $RENDER_TRAJ_PATH \
            --data_dir $SCENE_DIR/$SCENE/ \
            --result_dir $RESULT_DIR/$SCENE/ \
            --ckpt $CKPT
    done
done


for SCENE in $SCENE_LIST;
do
    echo "=== Eval Stats ==="

    for STATS in $RESULT_DIR/$SCENE/stats/val*.json;
    do  
        echo $STATS
        cat $STATS; 
        echo
    done

    echo "=== Train Stats ==="

    for STATS in $RESULT_DIR/$SCENE/stats/train*_rank0.json;
    do  
        echo $STATS
        cat $STATS; 
        echo
    done
done