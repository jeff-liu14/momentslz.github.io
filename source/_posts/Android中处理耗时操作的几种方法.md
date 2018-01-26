layout: article
title: Android中处理耗时操作的几种方法
date: 2018-01-26 09:30:46
tags: toolbar actionbar
---
# 耗时操作的几种操作方式
### Thread Handler Looper MessageQueue

创建handler时会创建looer对象并用looper中的messageQueue对象初始化当前messageQueue当使用handler发送消息时会有两种方式发送：sendMessage和dispatchMessage    
前者发送的消息会直接发送至messageQueue中通过looper对象循环处理并将结果转发至handler的handleMessage方法中经过了线程之间的切换   
后者则通过判断是否存在Runnable接口回调来选择返回信息的方式存在的话则直接调用Runnable中的run方法，若不存在则直接调用handler中的handMessage方法，在同一线程完成
 

在主线程使用   
在主线程创建handler对象并其修饰为static类型，覆写handleMessage方法对收到的message对象进行处理，从打印信息可以发现当前线程为main线程即主线程，其中的looper对象是在ActivityThread.main中创建的   
handler 使用示例:

```
public static Handler handler = new Handler() { 
        @Override   
        public void handleMessage(Message msg) {   
            switch (msg.what) {   
                case 10001:   
                    Log.d("main", msg.obj + "" + Looper.myLooper().getThread().getName());   
            }  
        }
    };
```

thread使用:

```
new Thread(new Runnable() {
        @Override
        public void run() {
            Message message = handler.obtainMessage();
            message.what = 10001;
            message.obj = "hello";
            handler.dispatchMessage(message);
        }
    }).start();
```
在thread线程中使用handler对象时参考Lopper源码中的示例：

```
private class LopperThread extends Thread {
        private Handler mHandler;

        @Override
        public void run() {
            super.run();
            Looper.prepare();
            mHandler = new Handler() {
                @Override
                public void handleMessage(Message msg) {
                    switch (msg.what) {
                        case 10001:
                            Log.d("main", msg.obj + "" + Looper.myLooper().getThread().getName());
                    }
                }
            };
            Message message = mHandler.obtainMessage();
            message.what = 10001;
            message.obj = "hello";
            mHandler.sendMessage(message);
            Looper.loop();
        }
    }
```
使用方法为：

```
LopperThread thread = new LopperThread();
thread.start();
```

### AsyncTask

asynctask的创建： 
  
```
public class MyTestTask extends AsyncTask<Integer, Integer, String> {

    private static final String TAG = MyTestTask.class.getSimpleName();

    @Override
    protected void onPreExecute() {
        super.onPreExecute();
        Log.i(TAG, "onPreExecute->运行前,主线程)" + Looper.myLooper().getThread().getName());
    }

    @Override
    protected void onPostExecute(String s) {
        super.onPostExecute(s);
        Log.i("TAG", "onPostExecute->运行后,主线程" + Looper.myLooper().getThread().getName());
    }

    @Override
    protected void onProgressUpdate(Integer... values) {
        super.onProgressUpdate(values);
        Log.i("TAG", "onProgressUpdate->更新进度,主线程" + Looper.myLooper().getThread().getName());
    }

    @Override
    protected String doInBackground(Integer... params) {
        Log.i(TAG, "doInBackground->运行中,子线程");
        for (int i = 0; i < 10; i++) {
            publishProgress(i);
        }
        return "finish";
    }
}
```
其中三个泛型的参数分别为：   
Params(传入doInBackground方法中的参数)   
Progress(onProgressUpdate方法中更新进度的参数)    
Result(后台执行完成后的返回参数)   

使用：

```
for (int i = 0; i < 128; i++) {
    new MyTestTask().execute();
}
```

使用须知：AsyncTask   
3.0之前为并发执行最大并发数两位128(参见2.3.7源码MAXIMUM_POOL_SIZE = 128)，当并发数量大于128时会报异常   
3.0之后AsyncTask变为顺序执行，当上一个任务完成后才会执行下一个任务，顺序执行
[参考链接](http://blog.csdn.net/qq_23547831/article/details/50803849)
### HandlerThread

handlerthread继承自Thread所以本来就是线程，只是在线程的run方法中添加了looper循环来实现耗时操作，在使用时先调用start方法开启线程然后通过mHandlerThread.getLooper()的方法获取handlerThread中的looper对象和新创建的hanlder对象进行绑定即通过以下方法初始化新建的handler：

```
public Handler(Looper looper) {
     this(looper, null, false);
}
```
在handler初始化后即和handlerthread完成绑定，需注意的是耗时操作需在新建的handler的handleMessage方法中进行

```
@Override
    public void run() {
        mTid = Process.myTid();
        Looper.prepare();
        synchronized (this) {
            mLooper = Looper.myLooper();
            notifyAll();
        }
        Process.setThreadPriority(mPriority);
        onLooperPrepared();
        Looper.loop();
        mTid = -1;
    }
```
通过Looper.prepare()和 Looper.loop()实现了looper循环使用方法：

```
初始化：
HandlerThread mHandlerThread = new HandlerThread("myHandlerThread");
mHandlerThread.start();
Handler mHandler = new Handler(mHandlerThread.getLooper()) {
      @Override
      public void handleMessage(Message msg) {
      //耗时操作
      do something....
           Log.i("tag", "message_obj：" + msg.obj.toString());
      }
};

发送Message：
Message msg = new Message();
msg.obj = "message_obj";
mHandler.sendMessage(msg);
```

[参考链接](http://blog.csdn.net/lmj623565791/article/details/47079737/)

### IntentService
IntentService在onCreate时使用HandlerService对ServiceHandler进行了绑定，在ServiceHandler的handleMessage方法中调用了抽象方法onHandleIntent进行耗时操作，所以在IntentService的onHandleIntent方法中可以进行耗时操作，在onHandleIntent调用后还调用了stopSelf方法结束自己，所以IntentService当执行完耗时操作后会自动销毁

代码示例：

```
public class TestIntentService extends IntentService {
    private static String TAG = "IntentServiceLoad";

    public TestIntentService() {
        super(TAG);
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        //耗时操作
        // TODO: 2018/1/25 do something...
        Log.d(TAG, "onHandleIntent");
    }
}
```

使用方法和service相同就不举例说明了，在应用中一般会用来下载文件



