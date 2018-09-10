---
title:	Android窗口管理框架源码解析整理
---

> 原文地址 [Android open source project analysis](https://github.com/guoxiaoxing/android-open-source-project-analysis) 感谢原作者[guoxiaoxing](https://github.com/guoxiaoxing)及相关技术大佬的无私付出.

> 此篇文章在各位大佬的源码分析文章的基础上对自己的理解进行整理，各位可结合原文分析使用，如有不实之处欢迎指正.


### Android窗口管理框架
- [x] [Android显示框架：Android应用视图的载体View](https://github.com/guoxiaoxing/android-open-source-project-analysis/blob/master/doc/Android%E7%B3%BB%E7%BB%9F%E5%BA%94%E7%94%A8%E6%A1%86%E6%9E%B6%E7%AF%87/Android%E7%AA%97%E5%8F%A3%E7%AE%A1%E7%90%86%E6%A1%86%E6%9E%B6/02Android%E7%AA%97%E5%8F%A3%E7%AE%A1%E7%90%86%E6%A1%86%E6%9E%B6%EF%BC%9AAndroid%E5%BA%94%E7%94%A8%E8%A7%86%E5%9B%BE%E8%BD%BD%E4%BD%93View.md)

- measure流程  
   1. ViewGroup在onMeasure()中会调用所有子View的measure让它们进行自我测量并在onMeasure中会计算出自己的尺寸然后保存  
   2. ViewGroup根据子View计算出的期望尺寸来计算出它们的实际尺寸和位置然后保存。同时，根据子View的尺寸和位置来计算出自己的尺寸然后保存.  
   3. viewGroup onMeasure() -> view measure() -> view onMeasure() 
   4. 日常开发中我们接触最多的不是MeasureSpec而是LayoutParams，在View测量的时候，LayoutParams会和父View的MeasureSpec相结合被换算成View的MeasureSpec，进而决定View的大小。
   5. View的MeasureSpec计算源码如下所示，该方法用来获取子View的MeasureSpec，由参数我们就可以知道子View的MeasureSpec由父容器的spec，父容器中已占用的的空间大小padding，以及子View自身大小childDimension共同来决定的。
   
```
public abstract class ViewGroup extends View implements ViewParent, ViewManager {
    
     public static int getChildMeasureSpec(int spec, int padding, int childDimension) {
            int specMode = MeasureSpec.getMode(spec);
            int specSize = MeasureSpec.getSize(spec);
    
            int size = Math.max(0, specSize - padding);
    
            int resultSize = 0;
            int resultMode = 0;
    
            switch (specMode) {
            // Parent has imposed an exact size on us
            case MeasureSpec.EXACTLY:
                if (childDimension >= 0) {
                    resultSize = childDimension;
                    resultMode = MeasureSpec.EXACTLY;
                } else if (childDimension == LayoutParams.MATCH_PARENT) {
                    // Child wants to be our size. So be it.
                    resultSize = size;
                    resultMode = MeasureSpec.EXACTLY;
                } else if (childDimension == LayoutParams.WRAP_CONTENT) {
                    // Child wants to determine its own size. It can't be
                    // bigger than us.
                    resultSize = size;
                    resultMode = MeasureSpec.AT_MOST;
                }
                break;
    
            // Parent has imposed a maximum size on us
            case MeasureSpec.AT_MOST:
                if (childDimension >= 0) {
                    // Child wants a specific size... so be it
                    resultSize = childDimension;
                    resultMode = MeasureSpec.EXACTLY;
                } else if (childDimension == LayoutParams.MATCH_PARENT) {
                    // Child wants to be our size, but our size is not fixed.
                    // Constrain child to not be bigger than us.
                    resultSize = size;
                    resultMode = MeasureSpec.AT_MOST;
                } else if (childDimension == LayoutParams.WRAP_CONTENT) {
                    // Child wants to determine its own size. It can't be
                    // bigger than us.
                    resultSize = size;
                    resultMode = MeasureSpec.AT_MOST;
                }
                break;
    
            // Parent asked to see how big we want to be
            case MeasureSpec.UNSPECIFIED:
                if (childDimension >= 0) {
                    // Child wants a specific size... let him have it
                    resultSize = childDimension;
                    resultMode = MeasureSpec.EXACTLY;
                } else if (childDimension == LayoutParams.MATCH_PARENT) {
                    // Child wants to be our size... find out how big it should
                    // be
                    resultSize = 0;
                    resultMode = MeasureSpec.UNSPECIFIED;
                } else if (childDimension == LayoutParams.WRAP_CONTENT) {
                    // Child wants to determine its own size.... find out how
                    // big it should be
                    resultSize = 0;
                    resultMode = MeasureSpec.UNSPECIFIED;
                }
                break;
            }
            return MeasureSpec.makeMeasureSpec(resultSize, resultMode);
        }
        
}
```
- View事件分发

```
    ViewGroup dispatchTouchEvent 
    --> ViewGroup onInterceptTouchEvent 
    --> onInterceptTouchEvent is True
    --> |True| block
    --> |False| View dispatchTouchEvent 
    --> View onTouchEvent 
    --> View performClick
```


- [x] [Android窗口管理框架：Android应用视图的管理者Window](https://github.com/guoxiaoxing/android-open-source-project-analysis/blob/master/doc/Android%E7%B3%BB%E7%BB%9F%E5%BA%94%E7%94%A8%E6%A1%86%E6%9E%B6%E7%AF%87/Android%E7%AA%97%E5%8F%A3%E7%AE%A1%E7%90%86%E6%A1%86%E6%9E%B6/03Android%E7%AA%97%E5%8F%A3%E7%AE%A1%E7%90%86%E6%A1%86%E6%9E%B6%EF%BC%9AAndroid%E5%BA%94%E7%94%A8%E8%A7%86%E5%9B%BE%E7%AE%A1%E7%90%86%E8%80%85Window.md)

window 抽象类，定义了窗口类型，窗口参数以及窗口模式。在定义的窗口回调中进行事件分发，Activity实现了Window.Callback接口，将Activity关联给Window，Window就可以将一些事件交由Activity处理。

```
public interface Callback {

        //键盘事件分发
        public boolean dispatchKeyEvent(KeyEvent event);
        
        //触摸事件分发
        public boolean dispatchTouchEvent(MotionEvent event);
        
        //轨迹球事件分发
        public boolean dispatchTrackballEvent(MotionEvent event);

        //可见性事件分发
        public boolean dispatchPopulateAccessibilityEvent(AccessibilityEvent event);

        //创建Panel View
        public View onCreatePanelView(int featureId);

        //创建menu
        public boolean onCreatePanelMenu(int featureId, Menu menu);

        //画板准备好时回调
        public boolean onPreparePanel(int featureId, View view, Menu menu);

        //menu打开时回调
        public boolean onMenuOpened(int featureId, Menu menu);

        //menu item被选择时回调
        public boolean onMenuItemSelected(int featureId, MenuItem item);

        //Window Attributes发生变化时回调
        public void onWindowAttributesChanged(WindowManager.LayoutParams attrs);

        //Content View发生变化时回调
        public void onContentChanged();

        //窗口焦点发生变化时回调
        public void onWindowFocusChanged(boolean hasFocus);

        //Window被添加到WIndowManager时回调
        public void onAttachedToWindow();
        
        //Window被从WIndowManager中移除时回调
        public void onDetachedFromWindow();
        
         */
        //画板关闭时回调
        public void onPanelClosed(int featureId, Menu menu);
        
        //用户开始执行搜索操作时回调
        public boolean onSearchRequested();
    }
```
- 窗口的唯一实现类为PhoneWindow,PhoneWindow里包含了以下内容：
   1. private DecorView mDecor：DecorView是Activity中的顶级View，它本质上是一个FrameLayout，一般说来它内部包含标题栏和内容栏（com.android.internal.R.id.content）
   2. ViewGroup mContentParent：窗口内容视图，它是mDecor本身或者是它的子View。
   3. private ImageView mLeftIconView：左上角图标
   4. private ImageView mRightIconView：右上角图标
   5. private ProgressBar mCircularProgressBar：圆形loading条
   6. private ProgressBar mHorizontalProgressBar：水平loading条
   7. 其他的一些和转场动画相关的Transition与listener
在PhoneWindow的setContentView方法中判断是否存在DecorView，没有的化就创建DecorView并将创建好的DecorView赋值给mContentParent具体实现如下:

```
public class PhoneWindow extends Window implements MenuBuilder.Callback {
    
    @Override
    public void setContentView(int layoutResID) {
        // Note: FEATURE_CONTENT_TRANSITIONS may be set in the process of installing the window
        // decor, when theme attributes and the like are crystalized. Do not check the feature
        // before this happens.
        if (mContentParent == null) {
            //1. 如果没有DecorView则创建它，并将创建好的DecorView赋值给mContentParent
            installDecor();
        } else if (!hasFeature(FEATURE_CONTENT_TRANSITIONS)) {
            mContentParent.removeAllViews();
        }

        if (hasFeature(FEATURE_CONTENT_TRANSITIONS)) {
            final Scene newScene = Scene.getSceneForLayout(mContentParent, layoutResID,
                    getContext());
            transitionTo(newScene);
        } else {
            //2. 将Activity传入的布局文件生成View并添加到mContentParent中
            mLayoutInflater.inflate(layoutResID, mContentParent);
        }
        mContentParent.requestApplyInsets();
        final Callback cb = getCallback();
        if (cb != null && !isDestroyed()) {
            //3. 回调Window.Callback里的onContentChanged()方法，这个Callback也被Activity
            //所持有，因此它实际回调的是Activity里的onContentChanged()方法，通知Activity
            //视图已经发生改变。
            cb.onContentChanged();
        }
        mContentParentExplicitlySet = true;
    }    
}
```


- [x] [Android窗口管理框架：Android应用窗口的管理服务WindowManagerService](https://github.com/guoxiaoxing/android-open-source-project-analysis/blob/master/doc/Android%E7%B3%BB%E7%BB%9F%E5%BA%94%E7%94%A8%E6%A1%86%E6%9E%B6%E7%AF%87/Android%E7%AA%97%E5%8F%A3%E7%AE%A1%E7%90%86%E6%A1%86%E6%9E%B6/04Android%E7%AA%97%E5%8F%A3%E7%AE%A1%E7%90%86%E6%A1%86%E6%9E%B6%EF%BC%9AAndroid%E5%BA%94%E7%94%A8%E7%AA%97%E5%8F%A3%E7%AE%A1%E7%90%86%E6%9C%8D%E5%8A%A1WindowServiceManager.md)
> wms内容较为复杂建议参考原文分析理解

- [x] [Android窗口管理框架：Android布局解析者LayoutInflater](https://github.com/guoxiaoxing/android-open-source-project-analysis/blob/master/doc/Android%E7%B3%BB%E7%BB%9F%E5%BA%94%E7%94%A8%E6%A1%86%E6%9E%B6%E7%AF%87/Android%E7%AA%97%E5%8F%A3%E7%AE%A1%E7%90%86%E6%A1%86%E6%9E%B6/05Android%E7%AA%97%E5%8F%A3%E7%AE%A1%E7%90%86%E6%A1%86%E6%9E%B6%EF%BC%9AAndroid%E5%B8%83%E5%B1%80%E8%A7%A3%E6%9E%90%E8%80%85LayoutInflater.md)

- 获取XmlResourceParser
  1. Activity 调用LayoutInflater的inflate
  2. inflate中调用Resources的getLayout(resource)去获取对应的XmlResourceParser。
  3. getLayout(resource)又去调用了Resources的loadXmlResourceParser()方法来完成XmlResourceParser的加载
- 解析View树
  1. 获取树的深度，执行深度优先遍历.
  2. 逐个进行元素解析。
  3. 解析添加ad:focusable="true"的元素，并获取View焦点。
  4. 解析View的tag。
  5. 解析include标签，注意include标签不能作为根元素，而merge必须作为根元素。
  6. 根据元素名进行解析，生成View。
  7. 递归调用解析该View里的所有子View，也是深度优先遍历，rInflateChildren内部调用的也是rInflate()方法，只是传入了新的parent View。
  8. 将解析出来的View添加到它的父View中。
  9. 回调根容器的onFinishInflate()方法，这个方法我们应该很熟悉。
- 解析view标签
  1. 解析View标签createViewFromTag。
  2. 如果标签与主题相关，则需要将context与themeResId包裹成ContextThemeWrapper。
  3. BlinkLayout是一种会闪烁的布局，被包裹的内容会一直闪烁，像QQ消息那样。
  4. 用户可以设置LayoutInflater的Factory来进行View的解析，但是默认情况下这些Factory都是为空的。
  5. 默认情况下没有Factory，而是通过onCreateView()方法对内置View进行解析，createView()方法进行自定义View的解析。这里有个小技巧，因为我们在使用自定义View的时候是需要在xml指定全路径的，例如：com.guoxiaoxing.CustomView，那么这里就有个.了，可以利用这一点判定是内置View还是自定义View。
- [x] [Android窗口管理框架：Android列表控件RecyclerView](https://github.com/guoxiaoxing/android-open-source-project-analysis/blob/master/doc/Android%E7%B3%BB%E7%BB%9F%E5%BA%94%E7%94%A8%E6%A1%86%E6%9E%B6%E7%AF%87/Android%E7%AA%97%E5%8F%A3%E7%AE%A1%E7%90%86%E6%A1%86%E6%9E%B6/06Android%E7%AA%97%E5%8F%A3%E7%AE%A1%E7%90%86%E6%A1%86%E6%9E%B6%EF%BC%9AAndroid%E5%88%97%E8%A1%A8%E6%8E%A7%E4%BB%B6RecyclerView.md)

![](https://github.com/guoxiaoxing/android-open-source-project-analysis/raw/master/art/app/ui/recyclerview_structure.png)
- Adapter将数据DataSet翻译成RecyclerView可以理解的ViewHolder，Recycler负责对这些ViewHolder进行管理,LayoutManager从Recycler获取这些ViewHolder，然后在RecyclerView里对它们进行布局，在布局的过程中还可以通过ItemDecoration、ItemAnimator为这些ViewHolder添加分隔条、转场动画等东西，让整个RecyclerView更加具有交互性。

### Android组件管理框架

- [x] [Android组件管理框架：Android组件管理服务ActivityManagerService](https://github.com/guoxiaoxing/android-open-source-project-analysis/blob/master/doc/Android%E7%B3%BB%E7%BB%9F%E5%BA%94%E7%94%A8%E6%A1%86%E6%9E%B6%E7%AF%87/Android%E7%BB%84%E4%BB%B6%E7%AE%A1%E7%90%86%E6%A1%86%E6%9E%B6/02Android%E7%BB%84%E4%BB%B6%E7%AE%A1%E7%90%86%E6%A1%86%E6%9E%B6%EF%BC%9AAndroid%E7%BB%84%E4%BB%B6%E7%AE%A1%E7%90%86%E6%9C%8D%E5%8A%A1ActivityServiceManager.md)
> init进程 –> Zygote进程 –> SystemServer进程 –>各种应用进程

- [x] [Android组件管理框架：Android视图容器Activity](https://github.com/guoxiaoxing/android-open-source-project-analysis/blob/master/doc/Android%E7%B3%BB%E7%BB%9F%E5%BA%94%E7%94%A8%E6%A1%86%E6%9E%B6%E7%AF%87/Android%E7%BB%84%E4%BB%B6%E7%AE%A1%E7%90%86%E6%A1%86%E6%9E%B6/03Android%E7%BB%84%E4%BB%B6%E7%AE%A1%E7%90%86%E6%A1%86%E6%9E%B6%EF%BC%9AAndroid%E8%A7%86%E5%9B%BE%E5%AE%B9%E5%99%A8Activity.md)
- 点击桌面应用图标，Launcher进程将启动Activity（MainActivity）的请求以Binder的方式发送给了AMS。
- AMS接收到启动请求后，交付ActivityStarter处理Intent和Flag等信息，然后再交给ActivityStackSupervisior/ActivityStack处理Activity进栈相关流程。同时以Socket方式请求Zygote进程fork新进程。
- Zygote接收到新进程创建请求后fork出新进程。
- 在新进程里创建ActivityThread对象，新创建的进程就是应用的主线程，在主线程里开启Looper消息循环，开始处理创建Activity。
- ActivityThread利用ClassLoader去加载Activity、创建Activity实例，并回调Activity的onCreate()方法。这样便完成了Activity的启动。
- 什么情况下需要设置FLAG_ACTIVITY_NEW_TASK标志位
  1. 调用者不是Activity Context
  2. 调用者Activity调用single Instance
  3. 目标Activity设置的有single Instance或者single task
  4. 调用者处于finish状态
- 启动模式一共有四种
  1. standard：多实例模式，每次启动都会有创建一个实例，默认会进入启动它的那个Activity所属的任务栈的栈顶，读者以前可能使用过Application Context去启动Activity，这是情况下会报错，就是因为 Application Context没有所谓的任务栈，解决的方式就是给它添加一个FLAG_ACTIVITY_NEW_TASK的标志位，创建一个新的任务栈。
  2. singleTop：栈顶复用模式，如果新启动的Activity已经位于任务栈顶，则不会创建新的实例，而是回调原来Activity实例的onNewIntent()方法，如果新启动的Activity没有位于任务栈顶，则会创建 新的Activity实例。
  3. singleTask：栈内复用模式，如果新启动的Activity已经位于任务栈内，则不会创建新的实例，而是回调原来Activity实例的onNewIntent()方法并且清除它之上的Activity（这里需要注意一下：任务栈里 的Activity是永远不会重排序的，所以它会清楚上方所有的Activity来让自己回到栈顶），如果新启动的Activity 没有位于任务栈，则新建一个Activity实例。
  4. singleInstance：单实例模式，和singleTask相似，但是singleTask可以在多个栈里拥有多个实例，而singleInstance在多个栈里只能有唯一实例，这个一般用在特殊场景里，例如电话界面。
