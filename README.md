# IPENS
DrawWithiPens

Develop Log

2018.5.10  

快速写字的时候，第二笔的蓝牙无法识别
原因: 快速落笔，isPenWriting 还未置为NO，新的touch无法添加到holdtouches中备用


2018.5.16
蓝牙笔上报时间不准确，有时会早于touch begin ，所以之前的逻辑无法判断
尚需优化  右手写字的时候，笔识别有待优化
