# VFX_HDR

## 設備
Nikon D7000, 鏡頭SIGMA24-70mm f2.8

## 演算法說明

**1. Image alignment**
- 目的: 在照相會因為手震或是快門震動等各種因素造成影像偏移，這些偏移都會影響HDR成效，故需要先對來源影像作對齊。
- 演算法: **Median Threshold Bitmap**
- 過程: 先將兩張影像以2的次方不斷縮小(總共縮小六次)，從最底層影像開始做起，分別先計算threshold bitmap和exclusion bitmap，將img2的兩張bitmap分別對九個方向(包含自己)做位移，判斷出最佳方向後將位移量\*2回傳給上一層，直到最後一層。

對齊前\
![image](https://github.com/KakaCheng/VFX_HDR/blob/03bca044add3b7a49cc5ef3f68f988b103def30a/Readme_pic/04.jpg)

對齊後\
![image](https://github.com/KakaCheng/VFX_HDR/blob/03bca044add3b7a49cc5ef3f68f988b103def30a/Readme_pic/05.jpg)

**2. Assembling HDR image**
- 目的: 還原影像裡真實環境的亮度分布圖(radiance map)
- 演算法: 參考\[1]
- 過程:

輸入一組影像及曝光時間\
![image](https://github.com/KakaCheng/VFX_HDR/blob/03bca044add3b7a49cc5ef3f68f988b103def30a/Readme_pic/00.jpg)

輸出亮度分布圖\
![image](https://github.com/KakaCheng/VFX_HDR/blob/03bca044add3b7a49cc5ef3f68f988b103def30a/Readme_pic/01.jpg)

**3. Tone mapping**
- 目的: HDR的亮度值範圍非常大，造成局部影像沒辦法顯示出來，導致出現過亮或是過暗的情況，所以需要將範圍縮小到可以用0~255來顯示
- 演算法:
  1. **Bilateral filter** \[2]
  2. **Photographic tone reproduction** \[3]
- 過程:

Bilateral filter\
![image](https://github.com/KakaCheng/VFX_HDR/blob/03bca044add3b7a49cc5ef3f68f988b103def30a/Readme_pic/03.jpg)

Photographic tone reproduction\
![image](https://github.com/KakaCheng/VFX_HDR/blob/03bca044add3b7a49cc5ef3f68f988b103def30a/Readme_pic/02.jpg)

## 參考資料
\[1]: Paul E. Debevec, Jitendra Malik, Recovering High Dynamic Range Radiance Maps from Photographs, SIGGRAPH 1997\
\[2]: Fredo Durand, Julie Dorsey, Fast Bilateral Filtering for the Display of High Dynamic Range Images, SIGGRAPH 2002\
\[3]: Erik Reinhard, Michael Stark, Peter Shirley, Jim Ferwerda, Photographics Tone Reproduction for Digital Images, SIGGRAPH 2002.
