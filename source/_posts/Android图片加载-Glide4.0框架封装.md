---
title:	Android图片加载-Glide4.0框架封装
---
基于现有项目存在大量高清美图展示的模块，所以在使用并对比了Glide和fresco的加载效果及使用体验后定下来的，两个框架都非常优秀但其侧重点略有不同之所以会选择Glide是因为本人挺喜欢Glide的API风格，简单方便而且不会涉及到自定义view.

Glide地址：[https://bumptech.github.io/glide/](https://bumptech.github.io/glide/)

本次侧重点会放在对应用的内存管理上来，当然对于图片的处理也是内存管理相当重要的一部分.

先上效果图

<img width="200" height="400" src="https://github.com/momentslz/Eyepetizer/blob/master/img/meitu_list.png?raw=true"/><img width="200" height="400" src="https://github.com/momentslz/Eyepetizer/blob/master/img/meitu_detail_0.png?raw=true"/><img width="200" height="400" src="https://github.com/momentslz/Eyepetizer/blob/master/img/meitu_detai_1.png?raw=true"/><img width="200" height="400" src="https://github.com/momentslz/Eyepetizer/blob/master/img/meitu_preview.png?raw=true"/>

# 使用步骤

### Glide添加

```
compile('com.github.bumptech.glide:glide:4.6.1') {
        exclude group: "com.android.support"
    }
// glide kotlin 的工具包
kapt 'com.github.bumptech.glide:compiler:4.6.1'
compile "com.github.bumptech.glide:okhttp3-integration:4.5.0"
compile 'com.github.bumptech.glide:annotations:4.6.1'
```
### 封装图片加载类

目前只提供了简单的封装，当然你也可以根据项目需求继续进行拓展


```
/**
 * Created by moment on 2018/2/6.
 */

class ImageLoad {

    open fun load(context: WeakReference<Context>, url: String?, image: ImageView?) {
        if (image == null) return
         // 具体图片加载实现可以使用第三方框架加载，也可以自己实现，
         这里提供Glide4.0的使用示例：
        var requestOptions = RequestOptions().centerCrop()
                .placeholder(R.drawable.default_banner)
                .error(R.drawable.default_banner)
                .transform(CenterCrop())
                .format(DecodeFormat.PREFER_RGB_565)
                .priority(Priority.LOW)
                .dontAnimate()
                .diskCacheStrategy(DiskCacheStrategy.RESOURCE)

        Glide.with(context.get()!!.applicationContext)
                .load(url)
                .apply(requestOptions)
                .into(object : DrawableImageViewTarget(image) {
                })
    }

    open fun load(context: WeakReference<Context>, url: String?, image: ImageView?, transformation: BitmapTransformation) {
        if (image == null) return
         // 具体图片加载逻辑
    }

    open fun load(holder: Int, context: WeakReference<Context>, url: String, image: ImageView?, width: Int, height: Int) {
        if (image == null) return
        // 具体图片加载逻辑
    }

    open fun loadCircle(context: WeakReference<Context>, url: String?, image: ImageView?, width_height: Int) {
        if (image == null) return
         // 具体图片加载逻辑
    }

    open fun loadRound(context: WeakReference<Context>, url: String, image: ImageView?, width: Int, height: Int, round: Int) {
        if (image == null) return
         // 具体图片加载逻辑
    }

    open fun clearCache(context: WeakReference<Context>) {
        // 强制清楚缓存，可以为内存缓存也可以为硬盘缓存
        Glide使用示例：
        Glide.get(context.get()!!.applicationContext).clearMemory()
        System.gc()
    }

}
```

### 使用说明

```
// 加载圆形头像
ImageLoad().loadCircle(WeakReference(mContext), remark.user_info.portrait, viewHolder.civ_avatar,40)

// 加载正常图片
ImageLoad().load(WeakReference(mContext), news.image_1, holder.imageView, width, height)

// 加载圆角图片
ImageLoad().loadRound(WeakReference(mContext), briefCard["icon"].toString(), holder.image, 5)

```

在列表加载图片时会使应用的内存上升，但Glide提供给我们一个API来减少在列表加载时会损耗不必要的内存的方法，以recyclerview 为例：
Android SD卡下载路径切换.md
```
recyclerview.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrollStateChanged(recyclerView: RecyclerView?, newState: Int) {
                super.onScrollStateChanged(recyclerView, newState)
                when (newState) {
                    2 -> { // SCROLL_STATE_FLING
                        Glide.with(activity.applicationContext).pauseRequests()
                    }
                    0 -> { // SCROLL_STATE_IDLE
                        Glide.with(activity.applicationContext).resumeRequests()
                    }
                    1 -> { // SCROLL_STATE_TOUCH_SCROLL
                        Glide.with(activity.applicationContext).resumeRequests()
                    }
                }

            }
        })
```

在列表滑动过程中我们可以调用pauseRequests方法来是图片暂停加载，当滑动结束后再调用resumeRequests来恢复加载.当然要想降低应用内存开销的话也可以调用ImageLoad().clearCache(WeakReference(this@MainActivity.applicationContext))来清空Glide的内存缓存

具体使用方法及使用细节详见[仿开眼视频Android客户端 ](https://github.com/momentslz/Eyepetizer/blob/master/app/src/main/java/com/moment/eyepetizer/utils/ImageLoad.kt)欢迎大家多多star.