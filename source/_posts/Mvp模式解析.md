---
title:	MVP模式解析
---
前言：

MVP模式是从MVVM 模式转化而来，MVVM是Model-View-ViewModel的简写,而MVP则是Model-View-Presenter 模式，其中Model负责

下面列举两种的差别：
>	1、MVC

MVC 模式是model view 和 controller 三者之间可以互相通信，但是这样就存在一个问题，就是view层可以调用model层和controller层的代码，所以会导致逻辑混乱。

<img src="http://liuzheng.space/img/mvc.png" width="400px">

>	2、MVP
MVP 是Model view 和 Presenter 组成，MVP最大的好处就是剥离了Presenter层出来替换掉了Controller，从而使得model 层和view层不能直接进行通信，必须通过presenter层间接进行通信，一般来说一个Activity只有一个presenter层来控制逻辑，但是在复杂的Activity中可以通过绑定多个Presenter来实现复杂的逻辑。

<img src="http://liuzheng.space/img/mvp.png" width="400px">

下面为大家展示下我已经封装好的逻辑代码：

model :
<pre><code>
//basemodel 与数据请求相关的接口
public class BaseModel {

    public  interface Classify {
        void getCookClassify(CallBack<CookClassify> callBack);
    }


} 
//MainModel 实现BaseModel.Classify中的接口进行数据请求
public class MainModel implements BaseModel.Classify {

    @Override
    public void getCookClassify(CallBack<CookClassify> callBack) {
    // 数据请求
        GetDataList.getCookClassify(callBack);
    }
}
</code></pre>


view:

<pre><code>
//baseActivity 源码：

public abstract class BaseActivity<T> extends AppCompatActivity {
//Presenter 实例
    protected T presenter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        beforeOnCreate();
        super.onCreate(savedInstanceState);
        setContentView(getLayoutId());
        initViews();
        initdata();
    }

    protected abstract int getLayoutId();

    protected abstract void initViews();

    protected abstract void initdata();

    protected  void beforeOnCreate(){

    }


    @Override
    protected void onResume() {
        super.onResume();
        afterOnResume();
    }

    protected  void afterOnResume(){

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        afterOnDestory();
    }

    protected  void afterOnDestory(){

    }


}




//baseview 接口，用来刷新页面数据，可以根据需求添加不同的方法。
public interface BaseView<T> {
//显示加载框
    void showDialog();
//加载成功
    void onSuccess(T t);
//加载失败
    void onError(Throwable t);
//取消加载框
    void dismissDialog();
}
</code></pre>

presenter:

<pre><code>
public class MainPresenter {
// 页面刷新接口
    private BaseView baseView;
    // 数据调用model
    private BaseModel.Classify cookClassify;

    public MainPresenter init(BaseView baseView) {
        this.baseView = baseView;
        this.cookClassify = new MainModel();
        return this;
    }

    public void getData() {
        baseView.showDialog();
        cookClassify.getCookClassify(new CallBack<CookClassify>() {
            @Override
            public void onCompleted() {
                baseView.dismissDialog();
            }

            @Override
            public void onError(Throwable e) {
                baseView.dismissDialog();
                baseView.onError(e);
            }

            @Override
            public void onNext(CookClassify cookClassify) {
                baseView.onSuccess(cookClassify);
            }
        });
    }

}
</code></pre>


使用步骤：

在BaseModel 中新建model接口 例：
<code><pre>
public interface Classify {
        void getCookClassify(CallBack<CookClassify> callBack);
    }
    </code></pre>
    
新建相应的Model实现接口里的方法并进行数据获取 例：
<code><pre>
 public class MainModel implements BaseModel.Classify {
   @Override
   public void getCookClassify(CallBack<CookClassify> callBack) {
        GetDataList.getCookClassify(callBack);
    }
}
</code></pre>


新建presenter 例：
<code><pre>
 public class MainPresenter {
    private BaseView baseView;
    private BaseModel.Classify cookClassify;
    
   public MainPresenter init(BaseView baseView) {
        this.baseView = baseView;
        this.cookClassify = new MainModel();
        return this;
    }
    
   public void getData() {
        baseView.showDialog();
        cookClassify.getCookClassify(new CallBack<CookClassify>() {
            @Override
            public void onCompleted() {
                baseView.dismissDialog();
            }
           @Override
           public void onError(Throwable e) {
                baseView.dismissDialog();
                baseView.onError(e);
            }
            @Override
            public void onNext(CookClassify cookClassify) {
                baseView.onSuccess(cookClassify);
            }
        });
    }
}
</code></pre>
继承BaseActivity并传入presenter数据类型 例： 
<code><pre>
public class MainActivity extends BaseActivity<.MainPresenter> implements BaseView<CookClassify> {

@Override
protected void initdata() {
		// 实例化presenter
        presenter = new MainPresenter().init(this);
        presenter.getData();
    }

 @Override
    public void showDialog() {
//todo: 显示dialog
    }
    @Override
    public void onSuccess(CookClassify cookClassify) {
    //todo: 刷新页面数据
        MyListAdapter adapter = getAdapter();
        adapter.refreshDatas(cookClassify.getTngou());
    }
    @Override
    public void onError(Throwable t) {
    //todo: 错误处理
        Log.d("debug", "onError===>" + t.getLocalizedMessage());
    }
    @Override
    public void dismissDialog() {
    //todo: 取消dialog显示
    }
}

</code></pre>


更多详情见github openobj:

github :	[https://github.com/momentslz](https://github.com/momentslz)

更多内容请添加本人公众号：

<img src="http://liuzheng.space/img/share.jpg" width="300px">









