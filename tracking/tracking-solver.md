
**solver的主要作用**就是交替调用前向（forward)算法和后向（backward)算法来更新参数，从而最小化loss，实际上就是一种迭代的优化算法。到目前的版本，caffe提供了六种优化算法来求解最优参数，在solver配置文件中，通过设置type类型来选择。


**Solver的流程：**

1.设计好需要优化的对象，以及用于学习的训练网络和用于评估的测试网络。（通过调用另外一个配置文件prototxt来进行）

2.通过forward和backward迭代的进行优化来更新参数。

3.定期的评价测试网络。 （可设定多少次训练后，进行一次测试）

4.在优化过程中显示模型和solver的状态


**在每一次的迭代过程中，solver做了这几步工作：**

1、调用forward算法来计算最终的输出值，以及对应的loss

2、调用backward算法来计算每层的梯度

3、根据选用的solver方法，利用梯度进行参数更新

4、记录并保存每次迭代的学习率、快照，以及对应的状态。


    net: "TRAIN_FILE"       设置深度网络模型
    base_lr: 0.000001       这四行可以放在一起理解，用于学习率的设置
    lr_policy: "step"       ....
    gamma: 0.1              ....
    stepsize: 100000        ....
    display: 20             每训练20次，在屏幕上显示一次。如果设置为0，则不显示。
    max_iter: 450000        最大迭代次数。这个数设置太小，会导致没有收敛，精确度很低。设置太大，会导致震荡，浪费时间。
    momentum: 0.9           上一次梯度更新的权重
    weight_decay: 0.0005    权重衰减项，防止过拟合的一个参数。
    snapshot: 50000         快照，将训练出来的model和solver状态进行保存，snapshot用于设置训练多少次后进行保存，默认为0，不保存。
    snapshot_prefix: "SOLVERSTATE_DIR/caffenet_train"  设置保存路径
    random_seed: RANDOM_SEED
    device_id: DEVICE_ID
    solver_mode: GPU

- step: 如果设置为step,则还需要设置一个stepsize,  返回 base_lr * gamma ^ (floor(iter / stepsize)),其中iter表示当前的迭代次数

