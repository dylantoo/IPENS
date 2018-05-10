# IPENS
DrawWithiPens

Develop Log

2018.5.10  

快速写字的时候，第二笔的蓝牙无法识别
原因: 快速落笔，isPenWriting 还未置为NO，新的touch无法添加到holdtouches中备用
