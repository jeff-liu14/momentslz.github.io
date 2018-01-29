layout: article
title: 使用IntentService进行apk更新
date: 2018-01-29 17:20:46
tags: BroadcastReceiver IntentService
---

通常在使用service更新应用时最常出现的问题就是Notification进度的更新问题、service在什么时间关闭以及需要我们自己在Service中创建新的线程处理耗时操作，当然这种也是可以实现的但是会显得略微繁琐
经过对比发现可以使用IntentService已经实现了对耗时操作的包装出来，我们只需要实现IntentService中的onHandleIntent方法就可以在其中进行耗时操作的处理，在处理下载问题时发现在使用intentservice时暂时没有发现可以优雅的进行进度回调的实现方法，所以我这边使用了本地广播的形式来进行进度刷新。

添加了当前状态判断，当应用处于前台状态时直接进行安装，当应用处于后台时弹出notification弹窗点击后安装，示例如下图：

<img height=480 width=320 src="https://github.com/momentslz/logconverge/blob/master/download.gif">

先创建广播

```
public static class MyBroadcastReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            switch (intent.getAction()) {
                case ACTION_TYPE_PREPARE:
                    if (downloadCallback != null) {
                        downloadCallback.onPrepare();
                    }
                    break;
                case ACTION_TYPE_PROGRESS:
                    int progress = intent.getIntExtra("progress", 0);
//                    Log.d("progress", "|- " + progress + " -|");
                    if (downloadCallback != null) {
                        downloadCallback.onProgress(progress);
                    }
                    break;
                case ACTION_TYPE_COMPLETE:
                    String file_path = intent.getStringExtra("file_path");
                    if (!TextUtils.isEmpty(file_path)) {
                        File file = new File(file_path);
                        if (file.exists()) {
                            if (downloadCallback != null) {
                                downloadCallback.onComplete(file);
                            }
                        }
                    }
                    break;
                case ACTION_TYPE_FAIL:
                    String error = intent.getStringExtra("error");
                    if (downloadCallback != null) {
                        downloadCallback.onFail(error + "");
                    }
                    break;
            }
        }
```

然后在IntentService中初始化本地广播并发送信息

```
@Override
    public void onCreate() {
        super.onCreate();
        mLocalBroadcastManager = LocalBroadcastManager.getInstance(this);
    }

    // 在下载进度刷新的地方进行回调
    private void progress(int progress) {
        Intent intent = new Intent(FileDownloaderManager.ACTION_TYPE_PROGRESS);
        intent.putExtra("progress", progress);
        mLocalBroadcastManager.sendBroadcast(intent);
    }

    private void downApk(String url) {
    .....
    .....
     progress(progress);
    .....
    .....
    }

```
在activity中使用

```
mLocalBroadcastManager = LocalBroadcastManager.getInstance(mContext);
mBroadcastReceiver = new MyBroadcastReceiver();
IntentFilter intentFilter = new IntentFilter();
intentFilter.addAction(ACTION_TYPE_PREPARE);
intentFilter.addAction(ACTION_TYPE_PROGRESS);
intentFilter.addAction(ACTION_TYPE_COMPLETE);
intentFilter.addAction(ACTION_TYPE_FAIL);
mLocalBroadcastManager.registerReceiver(mBroadcastReceiver, intentFilter);
// ondestory时调用
mLocalBroadcastManager.unregisterReceiver(mBroadcastReceiver);
```

以上源码已进行封装，方便使用具体操作步骤如下：
|- 初始化及注册回调

```
//初始化文件下载管理类
FileDownloaderManager.init(context)
// 注册下载进度监听，并开启广播接收
FileDownloaderManager.registerDownload(object : FileDownloaderManager.DownloadCallback {
            override fun onComplete(file: File) = mainView.downloadSucc(file)

            override fun onFail(msg: String?) = Unit

            override fun onProgress(progress: Int) = mainView.onProgress(progress)

            override fun onPrepare() = Unit

        })
//开始下载
FileDownloaderManager.download(url)
```
|- 在下载完成后进行资源重置

```
FileDownloaderManager.unbinder()
```

源码地址：[源码地址](https://github.com/momentslz/logconverge/tree/master/logconverge/src/main/java/com/moment/logconverge/download)
文档地址：[文档地址](https://github.com/momentslz/logconverge)