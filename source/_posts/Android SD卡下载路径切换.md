---
title:	Android SD卡下载路径切换
---

### 存储机制原理及初始化

Android存储机制   
>[原文链接: Android | 图解外部存储和内部存储](http://mafei.me/2017/12/19/Android%20%7C%20%E5%9B%BE%E8%A7%A3%E5%A4%96%E9%83%A8%E5%AD%98%E5%82%A8%E5%92%8C%E5%86%85%E9%83%A8%E5%AD%98%E5%82%A8/)
>
> 内外部存储的区别
> 
> 按照内外部存储：带External字眼则一定是外部存储的方法，如 getExternalFilesDir() ，外 部存储需要运行时权限；
>   
> 按照公有私有性质：公有文件是Environment调用函数，而私有文件（包括内部私有与外部私有）是Context调用函数，公有文件不会随着app卸载而删除而私有则会，私有文件不会被Media Scanner扫描到。

需求描述   
> 本人目前从事漫画类型APP开发，用户使用中低端机型（红米、oppo等）比例较高因此用户需要可以对下载路径进行修改因此有此次文章

先上效果图

<img width="200" height="400" src="https://github.com/momentslz/Eyepetizer/blob/master/img/download_path.png?raw=true"/><img width="200" height="400" src="https://github.com/momentslz/Eyepetizer/blob/master/img/download_dialog.png?raw=true"/>

Application初始化
> 初始化类：SdCardManager

```
// packageName:应用applicationId 用来创建私有存储路径
SdCardManager.getInstance().init(this, packageName)
```

> MainActivity初始化当前可用路径

```
/**
 * 初始化获取手机存储权限
 * 默认存储路径为SD卡，当SD卡不存在或不可用时切换使用手机内存
 */
RxPermissions(this)
                .request(android.Manifest.permission.READ_EXTERNAL_STORAGE, android.Manifest.permission.WRITE_EXTERNAL_STORAGE)
                .subscribe({ aBoolean ->
                    if (aBoolean) {
                        if (SdCardManager.getInstance().isDiskAvailable) {
                            if (SdCardManager.getInstance().isNullPath) {
                                SdCardManager.getInstance().changePath(SdCardManager.DownloadPath.SDCARD)
                            }
                        } else {
                            SdCardManager.getInstance().changePath(SdCardManager.DownloadPath.CACHE)
                        }
                    } else {
                        SdCardManager.getInstance().changePath(SdCardManager.DownloadPath.CACHE)
                    }
                }, { })
```

> 获取手机存储路径类相关代码,具体源码参考详见: [Android文件存储位置切换](https://www.aliyun.com/jiaocheng/96447.html)

```
    /**
     * 获取存储设备及容量信息
     */
    public static List<MyStorageVolume> getVolumeList(Context context) {
        List<MyStorageVolume> svList = new ArrayList<MyStorageVolume>(3);
        StorageManager mStorageManager = (StorageManager) context
                .getSystemService(Activity.STORAGE_SERVICE);
        try {
            Method mMethodGetPaths = mStorageManager.getClass().getMethod("getVolumeList");
            Object[] list = (Object[]) mMethodGetPaths.invoke(mStorageManager);
            for (Object item : list) {
                svList.add(new MyStorageVolume(context, item));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return svList;
    }
```
> 创建本地存储路径及SD卡存储路径文件夹,相关理论参考文章: [彻底搞懂Android文件存储---内部存储，外部存储以及各种存储路径解惑](http://blog.csdn.net/u010937230/article/details/73303034)

```
public static void createDir(Application application) {
        File[] files;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            files = application.getExternalFilesDirs("download");
            for (File file : files) {
                if (!file.exists()) {
                    file.mkdirs();
                }
            }
        }
        File file = getExternalStorageDirectory();
        if (!file.exists()) {
            file.mkdirs();
        }

        File file1 = application.getExternalFilesDir("download");
        if (!file1.exists()) {
            file1.mkdirs();
        }

        File sdcard = new File(SdCardManager.getInstance().getDiskDownloadDir());
        if (!sdcard.exists()) {
            sdcard.mkdirs();
        }
        File cache = new File(SdCardManager.getInstance().getCacheDownloadDir());
        if (!cache.exists()) {
            cache.mkdirs();
        }
    }
```

### 路径切换

> 获取当前使用存储路径,通过SdCardManager类获取当前正在使用中的存储路径并显示

```
private fun getDownloadPath() {
        if (SdCardManager.getInstance().isDiskNow) {
            val builder = StringBuilder(activity.getString(R.string.download_path_dialog_sdcard) + ":")
            builder.append(SdCardManager.getInstance().diskDownloadDir + "")
            tv_download.text = builder.toString()
        } else {
            val builder = StringBuilder(activity.getString(R.string.download_path_dialog_phone) + ":")
            builder.append(SdCardManager.getInstance().cacheDownloadDir + "")
            tv_download.text = builder.toString()
        }
    }
```

> 存储路径选择

```
private fun showPathDialog() {
        RxPermissions(activity)
                .request(android.Manifest.permission.READ_EXTERNAL_STORAGE, android.Manifest.permission.WRITE_EXTERNAL_STORAGE)
                .subscribe({ aBoolean ->
                    if (aBoolean!!) {
                        val dialog = PathDialog(activity)
                        dialog.setOnPathChangeLisenter {
                            getDownloadPath()
                            dialog.dismiss()
                        }
                        dialog.show()
                        dialog.setCanceledOnTouchOutside(true)
                    } else {
                        Toast.makeText(activity, "无此权限，无法打开此功能！", Toast.LENGTH_SHORT).show()
                    }
                }) { }
    }
```

> 存储路径选择就涉及到存储路径获取，及存储路径大小获取，相关操作均在dialog中完成初始化及相关操作，关键代码如下：

```
 // 判断SD卡是否可用
        if (SdCardManager.getInstance().isDiskAvailable()) {
            rl_sdcard.setVisibility(View.VISIBLE);
            String sdcard = SdCardManager.getInstance().getSdcardName();
            String size = "剩余"
                    + StorageVolumeUtil.getSizeStr(StorageVolumeUtil.getAvailableSize(sdcard)) + "可用，共"
                    + StorageVolumeUtil.getSizeStr(StorageVolumeUtil.getTotalSize(sdcard));
            tv_sdcard_size.setText("" + size);
        } else {
            rl_sdcard.setVisibility(View.GONE);
        }

        // 获取手机存储路径
        String phone = SdCardManager.getInstance().getCacheName();
        // 计算路径大小
        String size = "剩余"
                + StorageVolumeUtil.getSizeStr(StorageVolumeUtil.getAvailableSize(phone)) + "可用，共"
                + StorageVolumeUtil.getSizeStr(StorageVolumeUtil.getTotalSize(phone));
        tv_phone_size.setText("" + size);
        if (SdCardManager.getInstance().isDiskNow()) {
            rb_sdcard.setChecked(true);
            rb_phone.setChecked(false);
        } else {
            rb_sdcard.setChecked(false);
            rb_phone.setChecked(true);
        }
```


[源码地址: https://github.com/momentslz/Eyepetizer](https://github.com/momentslz/Eyepetizer/tree/master/sdkmanager/src/main/java/com/example/sdkmanager)  
欢迎大家多多star鼓励作者产出更多文章~~~ 














