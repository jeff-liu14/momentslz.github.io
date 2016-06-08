layout: article
title: 自定义ActionBar
date: 2016-06-05 09:30:46
tags: toolbar actionbar
---
前言：

相信大家都用过ActionBar吧，基本上都会去继承AppCompactActivity，但是在某些情况下，想实现一些特殊的效果的时候，系统自带的ActionBar就显得有点儿鸡肋了，不过后面又出了ToolBar控件，大大的弥补了ActionBar的不足，所以本次的自定义ActionBar就是继承的ToolBar，从而实现了ActionBar的高度以及可显示内容的高度定制。

下面列举几种自定义的样式：
>	1、自定义左侧返回菜单，使用方法见代码：
<pre>
private MyActionBar actionBar;
 actionBar = (MyActionBar) findViewById(R.id.myactionbar);
actionBar.withTitle("分类目录") //设置title文字
          .setABCallBack(this) // 设置左侧返回按钮，中间自定义菜单及右侧按钮点击事件
          .isShowBack(false) //是否显示左侧返回菜单
//效果见下图：
 
</pre>


<img src="http://liuzheng.space/img/title01.png" width="400px">

>	2、自定义ActionBar中间的view

<pre>
private MyActionBar actionBar;
 actionBar = (MyActionBar) findViewById(R.id.myactionbar);
 //自定义中间的view。
 View view = getLayoutInflater().inflate(R.layout.actionbar_center, null);
        view.findViewById(R.id.btn_click).setOnClickListener(v -> Toast.makeText(getApplicationContext(), "id:" + ((Button) v.findViewById(R.id.btn_click)).getText(), Toast.LENGTH_SHORT).show());
actionBar.setABCallBack(this) // 设置左侧返回按钮，中间自定义菜单及右侧按钮点击事件
          .isShowBack(false) //是否显示左侧返回菜单
          .addCenterView(view); //添加自定义view 见图二TEST按钮
//效果见下图：
 
</pre>



<img src="http://liuzheng.space/img/title02.png" width="400px">

>	3、自定义右侧按钮点击事件

<pre>
private MyActionBar actionBar;
 actionBar = (MyActionBar) findViewById(R.id.myactionbar);
 //右侧item adapter
 List<MyPopupWindow.MenuEntity> menuEntities = new ArrayList<>();
        menuEntities.add(new MyPopupWindow.MenuEntity(R.drawable.titlebar_back_press, "name"));
        menuEntities.add(new MyPopupWindow.MenuEntity(R.drawable.titlebar_back_press, "name1"));
        menuEntities.add(new MyPopupWindow.MenuEntity(R.drawable.titlebar_back_press, "name2"));

actionBar.setABCallBack(this) // 设置左侧返回按钮，中间自定义菜单及右侧按钮点击事件
          .isShowBack(false) //是否显示左侧返回菜单
          .addMenuList(menuEntities) // 添加右侧按钮item
          .addCenterView(view); //添加自定义view 
//效果见下图：
 </pre>



<img src="http://liuzheng.space/img/title04.png" width="400px">

MyActionBar 源码：

<pre>
public class MyActionBar extends Toolbar {

    private int backColor;
    private int defaultColor;
    private TextView tvTitle;
    private ImageView ivBack, ivRight;
    private RelativeLayout llBackground;
    private AbCallBack abCallBack;
    private Context mContext;
    private LinearLayout llcontainer;
    private MyPopupWindow popupWindow;

    public MyActionBar(Context context) {
        super(context, null);

    }

    public MyActionBar(Context context, final AttributeSet attrs) {
        this(context, attrs, -1);
    }

    @TargetApi(Build.VERSION_CODES.M)
    public MyActionBar(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        this.mContext = context;
        defaultColor = context.getColor(R.color.colorPrimary);
        LayoutInflater.from(context).inflate(R.layout.actionbar, this, true);
        TypedArray typedArray = context.obtainStyledAttributes(attrs,
                R.styleable.MyActionBar, 0, 0);
        backColor = typedArray.getColor(R.styleable.MyActionBar_myactionbar_background, defaultColor);
        llBackground = (RelativeLayout) findViewById(R.id.ll_background);
        llBackground.setBackgroundColor(backColor);
        llcontainer = (LinearLayout) findViewById(R.id.ll_container);
        tvTitle = (TextView) findViewById(R.id.tv_title);
        ivBack = (ImageView) findViewById(R.id.iv_back);
        ivRight = (ImageView) findViewById(R.id.iv_right);
        ivBack.setColorFilter(getResources().getColor(R.color.white));
        ivBack.setOnClickListener(v -> abCallBack.onBackClick());
        ivRight.setColorFilter(getResources().getColor(R.color.white));
        ivRight.setOnClickListener(v -> popupWindow.show(this));
    }

    public MyActionBar addCenterView(View view) {
        if (llcontainer != null) {
            llcontainer.removeAllViews();
            llcontainer.addView(view);
        }
        return this;
    }

    public MyActionBar addCenterViewClickListener(View view) {
        abCallBack.onCenterViewClick(view);
        return this;
    }

    public MyActionBar setHomeIcon(int resId) {
        if (mContext != null) {
            Picasso.with(mContext)
                    .load(resId)
                    .error(R.drawable.titlebar_back_press)
                    .into(ivBack);
        }
        return this;
    }


    public MyActionBar isShowBack(boolean isShow) {
        if (!isShow) {
            ivBack.setVisibility(INVISIBLE);
        } else {
            ivBack.setVisibility(VISIBLE);
        }
        return this;
    }

    public MyActionBar addMenuList(List<MyPopupWindow.MenuEntity> menuEntityList) {
        popupWindow = new MyPopupWindow(mContext);
        popupWindow.addMenuList(menuEntityList)
                .addOnItemClickLisenter((parent, view, position, id) -> {
                    abCallBack.onRightClick(position);
                    popupWindow.dismiss();
                }).build();

        return this;
    }

    public MyActionBar setABCallBack(AbCallBack abCallBack) {
        this.abCallBack = abCallBack;
        return this;
    }

    public MyActionBar withTitle(String title) {
        tvTitle.setText(title);
        return this;
    }


}
 </pre>

AbCallBack （ActionBar点击事件回调）源码：
<pre>
public interface AbCallBack {
    void onBackClick();
    void onRightClick();
}
</pre>

更多使用方法详见github:

github :	[https://github.com/momentslz/openobj](https://github.com/momentslz/openobj)

更多内容请添加本人公众号：

<img src="http://liuzheng.space/img/share.jpg" width="300px">










