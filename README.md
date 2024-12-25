# windows10-bat-ffmpeg-convert-ui
windows10 bat ffmpeg convert ui customize videoWidth videoHeight audioBitrate crfValue 中文介面

![GitHub圖像](https://github.com/pliok7485/windows10-bat-ffmpeg-convert-ui/blob/main/%E4%BD%BF%E7%94%A8%E4%BB%8B%E9%9D%A2.png)

這是一個讓你快速輸入FFMPEG影片轉檔參數的補助小工具

比如你想要一個720P畫質的影片就輸入1280跟720

然後決定畫質的是CRF值0~63 數值越大畫質越差反之數值越小畫質越好

再來就是音訊的品質 數字越大越接近原始影片音訊品質

--------------------------------------------------------------
我用AI寫了一個ffmpeg的bat執行檔 

執行後只要按照上面的說明輸入寬高、音訊、比特率、跟CRF值就能調整影片大小

要壓縮影片到5mb以下 除了CRF值以外的數值輸入越小影片輸出檔案就越小

並把任何影片檔案轉換成webm

下載zip檔解壓縮

點擊執行mp4towebm-setyouself.bat

第一次執行會先建立放影片的Video資料夾

把影片放進去Video後再執行mp4towebm-setyouself.bat

設好參數就能開始批次轉檔了

就能輸入參數開始轉檔了

如果沒裝FFMPEG是不能執行的請去下載FFMPEG安裝

FFMPEG安裝教學
https://the-walking-fish.com/p/install-ffmpeg-on-windows/

