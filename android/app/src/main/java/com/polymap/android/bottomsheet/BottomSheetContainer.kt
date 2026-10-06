package com.polymap.android.bottomsheet

import android.content.Context
import android.graphics.RectF
import android.view.MotionEvent
import android.view.VelocityTracker
import android.view.View
import android.view.ViewConfiguration
import android.view.ViewGroup
import androidx.core.view.NestedScrollingParent3
import androidx.core.view.NestedScrollingParentHelper
import androidx.core.view.ViewCompat
import androidx.dynamicanimation.animation.FloatValueHolder
import androidx.dynamicanimation.animation.SpringAnimation
import androidx.dynamicanimation.animation.SpringForce
import com.polymap.android.map.HorizontalSize
import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.exp
import kotlin.math.ln
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow

/**
 * BottomSheetViewController port: a draggable sheet with three snap positions hosting a stack of pages.
 * The container is full-screen; touches outside the sheet fall through to the views below (the map).
 */
class BottomSheetContainer(context: Context) : ViewGroup(context), NestedScrollingParent3 {

    enum class VerticalSize(val raw: Int) { SMALL(0), MEDIUM(1), BIG(2) }

    enum class PopControllerStrategy { ALWAYS_MINIMIZE, MEDIUM_IF_NEED }

    interface Delegate {
        fun onStateChange(from: VerticalSize, to: VerticalSize) {}
        fun onSizeChange(from: HorizontalSize?, to: HorizontalSize) {}
        fun onProgressChange(progress: Float) {}
        fun onPagePushed(page: BottomSheetPage) {}
        fun onPagePopped(page: BottomSheetPage, newTop: BottomSheetPage?) {}
    }

    object Constants {
        const val MIN_WIDTH_FOR_SMALL_SIZE = 1000f
        const val MIN_WIDTH_FOR_ULTRA_SMALL_SIZE = 800f
        const val SMALL_WIDTH = 380f
        const val ULTRA_SMALL_WIDTH = 320f
        const val SMALL_HEIGHT = 70f
        const val MEDIUM_HEIGHT = 305f
        const val TRANSITION_DURATION = 300L
        const val SHADOW_OPACITY = 0.2f
    }

    private val density = resources.displayMetrics.density
    private fun dp(v: Float) = v * density

    var delegate: Delegate? = null
    var popControllerStrategy = PopControllerStrategy.MEDIUM_IF_NEED

    var safeTop = 0
        set(value) { field = value; requestLayout() }
    var safeBottom = 0
        set(value) { field = value; requestLayout() }
    /** Height of the on-screen keyboard (window ime inset); pages get it as extra bottom content inset. */
    var imeBottom = 0
        set(value) { if (field != value) { field = value; updateContentInsets() } }

    /** The dim view drawn behind the sheet (Background class on iOS). Add it to the parent below this container. */
    val dimView: View = View(context).apply {
        setBackgroundColor(0)
        isClickable = false
    }

    var state: VerticalSize = VerticalSize.SMALL
        private set(value) {
            if (field != value) {
                delegate?.onStateChange(field, value)
                field = value
            }
            activePage?.onStateChange(value)
        }

    private var currentPosition = -1f
    private var startPosition = 0f
    private var startContentOffset = 0f
    private var navigationAnimated = false
    var moved = false
        private set
    var movedByScroll = false
        private set

    private val stateByPage = HashMap<BottomSheetPage, VerticalSize>()
    private var lastSize: HorizontalSize? = null
    private var lastState = VerticalSize.SMALL

    /** sheet frame host */
    private val sheet = object : ViewGroup(context) {
        override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
            for (i in 0 until childCount) getChildAt(i).layout(0, 0, r - l, b - t)
        }

        override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
            for (i in 0 until childCount) getChildAt(i).measure(widthMeasureSpec, heightMeasureSpec)
            setMeasuredDimension(MeasureSpec.getSize(widthMeasureSpec), MeasureSpec.getSize(heightMeasureSpec))
        }
    }.apply { clipChildren = false; clipToPadding = false }

    val pages = ArrayList<BottomSheetPage>()
    val activePage: BottomSheetPage? get() = pages.lastOrNull()
    val visiblePage: BottomSheetPage? get() = pages.lastOrNull()

    private val nestedHelper = NestedScrollingParentHelper(this)
    private val touchSlop = ViewConfiguration.get(context).scaledTouchSlop
    private var velocityTracker: VelocityTracker? = null
    private var dragging = false
    /** true while the user is dragging the sheet (not during programmatic animations). */
    val isUserDragging: Boolean get() = dragging
    private var interceptDownY = 0f
    private var interceptDownX = 0f
    private var downInsideSheet = false
    private var touchOnScrollable = false
    private var nestedFlingVelocity = 0f
    private var nestedAtTopOnStart = false
    private var anim: SpringAnimation? = null
    private var stateAnimator: android.animation.ValueAnimator? = null
    /** target position while animating to a state (iOS layout reflects the target immediately) */
    private var settleTarget: Float? = null
    private var lastContentInset = -1

    private fun cancelAnimations() {
        anim?.cancel(); anim = null
        stateAnimator?.cancel(); stateAnimator = null
        settleTarget = null
    }

    private val isAnimating: Boolean get() = anim?.isRunning == true || stateAnimator?.isRunning == true

    init {
        clipChildren = false
        clipToPadding = false
        addView(sheet)
    }

    // ------------------------------------------------------------------ sizes / positions

    val currentSize: HorizontalSize
        get() {
            val windowWidth = width / density
            if (windowWidth > Constants.MIN_WIDTH_FOR_SMALL_SIZE) return HorizontalSize.SMALL
            if (windowWidth > Constants.MIN_WIDTH_FOR_ULTRA_SMALL_SIZE) return HorizontalSize.ULTRA_SMALL
            return HorizontalSize.BIG
        }

    private fun safeAreaOffset(): Float = if (currentSize == HorizontalSize.BIG) safeBottom.toFloat() else max(dp(20f), safeBottom.toFloat())

    fun position(state: VerticalSize): Float {
        val h = height.toFloat()
        return when (state) {
            VerticalSize.SMALL -> h - safeAreaOffset() - dp(Constants.SMALL_HEIGHT)
            VerticalSize.MEDIUM -> h - safeAreaOffset() - dp(Constants.MEDIUM_HEIGHT)
            VerticalSize.BIG -> safeTop + dp(20f)
        }
    }

    private fun sheetWidth(): Int = when (currentSize) {
        HorizontalSize.BIG -> width
        HorizontalSize.SMALL -> dp(Constants.SMALL_WIDTH).toInt()
        HorizontalSize.ULTRA_SMALL -> dp(Constants.ULTRA_SMALL_WIDTH).toInt()
    }

    private fun sheetLeft(): Int = if (currentSize == HorizontalSize.BIG) 0 else max(0, dp(8f).toInt())

    /** Rect of the map not covered by the sheet, in this view's coordinates (SafeZone). */
    fun safeZone(): RectF {
        val pos = settleTarget ?: if (currentPosition < 0) position(state) else currentPosition
        return if (currentSize == HorizontalSize.BIG) {
            RectF(0f, 0f, width.toFloat(), pos)
        } else {
            val offset = progress(pos, position(VerticalSize.MEDIUM), position(VerticalSize.SMALL)).coerceIn(0f, 1f) * (sheetLeft() + sheetWidth())
            RectF(offset, 0f, width.toFloat(), height.toFloat())
        }
    }

    val sheetTop: Float get() = if (currentPosition < 0) position(state) else currentPosition

    // ------------------------------------------------------------------ layout

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val w = MeasureSpec.getSize(widthMeasureSpec); val h = MeasureSpec.getSize(heightMeasureSpec)
        setMeasuredDimension(w, h)
        val sw = if (w == 0) 0 else sheetWidth()
        val sh = if (h == 0) 0 else (h - position(VerticalSize.BIG) + 1).toInt()
        sheet.measure(MeasureSpec.makeMeasureSpec(sw, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(sh, MeasureSpec.EXACTLY))
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        if (!(moved || movedByScroll) && !isAnimating) currentPosition = position(state)
        val top = position(VerticalSize.BIG).toInt()
        sheet.layout(sheetLeft(), top, sheetLeft() + sheet.measuredWidth, top + sheet.measuredHeight)
        applyTranslation()
        val size = currentSize
        if (lastSize != size) {
            val old = lastSize
            lastSize = size
            delegate?.onSizeChange(old, size)
            dimHorizontalSize = size
            visiblePage?.onStateChange(size)
        }
        updateContentInsets()
    }

    private fun applyTranslation() {
        sheet.translationY = currentPosition - position(VerticalSize.BIG)
    }

    private fun updateContentInsets() {
        // pages are as tall as the BIG state; add bottom inset so content is reachable in MEDIUM/SMALL
        val inset = max((currentPosition - position(VerticalSize.BIG)).coerceAtLeast(0f).toInt(), imeBottom)
        if (inset == lastContentInset) return
        lastContentInset = inset
        for (p in pages) p.setContentBottomInset(inset)
    }

    // ------------------------------------------------------------------ progress / dim

    private var dimHorizontalSize: HorizontalSize? = null
    private var dimProgress = 0f

    private fun applyProgress(page: BottomSheetPage?, current: Float, from: Float = position(VerticalSize.SMALL), to: Float = position(VerticalSize.BIG)) {
        val fullProgress = progress(current, from, to)
        delegate?.onProgressChange(fullProgress)
        setDim(progress(current, position(VerticalSize.BIG), position(VerticalSize.MEDIUM)))
        page?.onBottomSheetScroll(fullProgress)
    }

    private fun setDim(p: Float) {
        dimProgress = p
        val enable = p > 0.1f && dimHorizontalSize == HorizontalSize.BIG
        dimView.isClickable = enable
        if (dimHorizontalSize == HorizontalSize.BIG) {
            val a = (p.coerceIn(0f, 1f) * 0.5f * 255).toInt()
            dimView.setBackgroundColor((a shl 24))
        } else dimView.setBackgroundColor(0)
    }

    private fun progress(value: Float, from: Float, to: Float): Float = (value - to) / (from - to)

    // ------------------------------------------------------------------ state changes

    fun changeState(state: VerticalSize, duration: Long = Constants.TRANSITION_DURATION, animated: Boolean = true) {
        this.state = state
        cancelAnimations()
        val target = position(state)
        if (animated && currentPosition >= 0 && abs(target - currentPosition) > 0.5f) {
            val start = currentPosition
            settleTarget = target
            val a = android.animation.ValueAnimator.ofFloat(0f, 1f).apply {
                this.duration = duration
                interpolator = com.polymap.android.ui.easeInOut
                addUpdateListener { v ->
                    val f = v.animatedValue as Float
                    currentPosition = start + (target - start) * f
                    applyTranslation()
                    applyProgress(visiblePage, currentPosition)
                    updateSafeZoneListeners()
                }
                addListener(object : android.animation.AnimatorListenerAdapter() {
                    override fun onAnimationEnd(animation: android.animation.Animator) {
                        if (stateAnimator === animation) { stateAnimator = null; settleTarget = null }
                        updateContentInsets()
                    }
                })
            }
            stateAnimator = a
            a.start()
        } else {
            settleTarget = null
            currentPosition = target
            applyTranslation()
            applyProgress(visiblePage, currentPosition)
            updateSafeZoneListeners()
            updateContentInsets()
        }
    }

    var onSheetMoved: (() -> Unit)? = null
    private fun updateSafeZoneListeners() { onSheetMoved?.invoke() }

    private fun nextState(velocity: Float): VerticalSize {
        fun nearestState(pos: Float, possible: List<VerticalSize>): VerticalSize {
            var nearestDistance = Float.MAX_VALUE
            var nearest = VerticalSize.SMALL
            for (s in possible) {
                val d = abs(position(s) - pos)
                if (d < nearestDistance) { nearest = s; nearestDistance = d }
            }
            return nearest
        }
        val singlePossible = when (state) {
            VerticalSize.SMALL -> listOf(VerticalSize.SMALL, VerticalSize.MEDIUM)
            VerticalSize.MEDIUM -> listOf(VerticalSize.SMALL, VerticalSize.BIG, VerticalSize.MEDIUM)
            VerticalSize.BIG -> listOf(VerticalSize.BIG, VerticalSize.MEDIUM)
        }
        val nearestSingle = nearestState(project(velocity, currentPosition, 0.995f), singlePossible)
        val nearestMulti = nearestState(project(velocity, currentPosition, 0.99f), listOf(VerticalSize.SMALL, VerticalSize.BIG, VerticalSize.MEDIUM))
        return if (abs(state.raw - nearestMulti.raw) > 1) nearestMulti else nearestSingle
    }

    /** UIScrollView-style deceleration projection (velocity in px/s). */
    private fun project(velocity: Float, position: Float, decelerationRate: Float): Float {
        val factor = -1f / (1000f * ln(decelerationRate))
        return position + factor * velocity
    }

    private fun endAnimation(velocity: Float) {
        state = nextState(velocity)
        val target = position(state)
        val delta = target - currentPosition
        var initialVelocity = if (abs(delta) > 0.01f) velocity / delta else 0f
        if (currentPosition < position(VerticalSize.BIG)) {
            initialVelocity /= max(1f, (position(VerticalSize.BIG) - currentPosition) / 5f)
        }
        val damping = if (initialVelocity > 0.01f) 0.8f else 1f
        val response = 0.35f
        val stiffness = (2 * PI / response).pow(2).toFloat()
        cancelAnimations()
        settleTarget = target
        val holder = FloatValueHolder(currentPosition)
        anim = SpringAnimation(holder).apply {
            spring = SpringForce(target).setDampingRatio(damping).setStiffness(stiffness)
            setStartVelocity(velocity)
            minimumVisibleChange = 0.5f
            addUpdateListener { _, value, _ ->
                currentPosition = value
                applyTranslation()
                applyProgress(visiblePage, currentPosition)
                updateSafeZoneListeners()
            }
            addEndListener { _, _, _, _ ->
                settleTarget = null
                currentPosition = target
                applyTranslation()
                applyProgress(visiblePage, currentPosition)
                updateSafeZoneListeners()
                updateContentInsets()
            }
            start()
        }
    }

    private fun expLimit(x: Float, maxVal: Float): Float = (1 - exp(-x / maxVal)) * maxVal

    private fun moveTo(targetPosition: Float) {
        val smallerPos = position(VerticalSize.SMALL)
        val biggerPos = position(VerticalSize.BIG)
        currentPosition = when {
            biggerPos < targetPosition && targetPosition < smallerPos -> targetPosition
            targetPosition > smallerPos -> smallerPos + expLimit(targetPosition - smallerPos, dp(20f))
            else -> biggerPos - expLimit(biggerPos - targetPosition, dp(20f))
        }
        applyTranslation()
        applyProgress(visiblePage, currentPosition, smallerPos, biggerPos)
        updateSafeZoneListeners()
    }

    // ------------------------------------------------------------------ direct touch dragging (pan gesture on the sheet)

    private fun isInsideSheet(x: Float, y: Float): Boolean =
        x >= sheet.left && x <= sheet.right && y >= sheetTop && y <= height

    private fun findScrollableUnder(v: View, x: Float, y: Float): View? {
        if (v.visibility != View.VISIBLE) return null
        if (v is ViewGroup) {
            for (i in v.childCount - 1 downTo 0) {
                val c = v.getChildAt(i)
                val lx = x - c.left - c.translationX; val ly = y - c.top - c.translationY
                if (lx < 0 || ly < 0 || lx > c.width || ly > c.height) continue
                findScrollableUnder(c, lx, ly)?.let { return it }
            }
        }
        return if (v.isNestedScrollingEnabled && (v.canScrollVertically(1) || v.canScrollVertically(-1))) v else null
    }

    override fun dispatchTouchEvent(ev: MotionEvent): Boolean {
        if (ev.actionMasked == MotionEvent.ACTION_DOWN) {
            downInsideSheet = isInsideSheet(ev.x, ev.y)
            if (!downInsideSheet) return false
        }
        if (!downInsideSheet) return false
        return super.dispatchTouchEvent(ev)
    }

    override fun onInterceptTouchEvent(ev: MotionEvent): Boolean {
        if (navigationAnimated) return false
        when (ev.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                interceptDownX = ev.x; interceptDownY = ev.y
                val local = floatArrayOf(ev.x - sheet.left, ev.y - sheet.top - sheet.translationY)
                touchOnScrollable = findScrollableUnder(sheet, local[0], local[1]) != null
                dragging = false
                velocityTracker?.recycle(); velocityTracker = VelocityTracker.obtain().also { it.addMovement(ev) }
                if (isAnimating) { cancelAnimations(); currentPosition = sheet.translationY + position(VerticalSize.BIG) }
            }
            MotionEvent.ACTION_MOVE -> {
                velocityTracker?.addMovement(ev)
                if (!touchOnScrollable && !dragging) {
                    val dy = ev.y - interceptDownY; val dx = ev.x - interceptDownX
                    if (abs(dy) > touchSlop && abs(dy) > abs(dx)) {
                        beginDrag()
                        return true
                    }
                }
            }
            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> { velocityTracker?.recycle(); velocityTracker = null }
        }
        return false
    }

    private fun beginDrag() {
        dragging = true
        moved = true
        cancelAnimations()
        currentPosition = sheet.translationY + position(VerticalSize.BIG)
        startPosition = currentPosition
        activePage?.onPageWillBeginScroll()
        parent?.requestDisallowInterceptTouchEvent(true)
    }

    override fun onTouchEvent(ev: MotionEvent): Boolean {
        if (!downInsideSheet) return false
        velocityTracker?.addMovement(ev)
        when (ev.actionMasked) {
            MotionEvent.ACTION_DOWN -> return true
            MotionEvent.ACTION_MOVE -> {
                if (!dragging) {
                    val dy = ev.y - interceptDownY
                    if (!touchOnScrollable && abs(dy) > touchSlop) beginDrag() else return true
                }
                moveTo(startPosition + (ev.y - interceptDownY))
                return true
            }
            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                if (dragging) {
                    dragging = false; moved = false
                    val vt = velocityTracker
                    var vy = 0f
                    if (vt != null) { vt.computeCurrentVelocity(1000); vy = vt.yVelocity }
                    endAnimation(vy)
                    activePage?.onPageWillEndScroll()
                }
                velocityTracker?.recycle(); velocityTracker = null
                return true
            }
        }
        return super.onTouchEvent(ev)
    }

    // ------------------------------------------------------------------ nested scrolling (page lists)

    override fun onStartNestedScroll(child: View, target: View, axes: Int, type: Int): Boolean =
        (axes and ViewCompat.SCROLL_AXIS_VERTICAL) != 0 && !navigationAnimated

    override fun onNestedScrollAccepted(child: View, target: View, axes: Int, type: Int) {
        nestedHelper.onNestedScrollAccepted(child, target, axes, type)
        if (type == ViewCompat.TYPE_TOUCH) {
            nestedFlingVelocity = 0f
            cancelAnimations()
            currentPosition = sheet.translationY + position(VerticalSize.BIG)
            startPosition = currentPosition
            movedByScroll = false
            nestedAtTopOnStart = !target.canScrollVertically(-1)
        }
    }

    override fun onNestedPreScroll(target: View, dx: Int, dy: Int, consumed: IntArray, type: Int) {
        if (type != ViewCompat.TYPE_TOUCH) return
        val big = position(VerticalSize.BIG)
        val small = position(VerticalSize.SMALL)
        if (dy > 0) {
            // finger moving up: expand the sheet before scrolling the list (only for drags that began at the list top, like iOS)
            if (currentPosition > big + 0.5f && (nestedAtTopOnStart || movedByScroll)) {
                if (!movedByScroll) { movedByScroll = true; activePage?.onPageWillBeginScroll() }
                val newPos = max(big, currentPosition - dy)
                consumed[1] = (currentPosition - newPos).toInt()
                currentPosition = newPos
                applyTranslation(); applyProgress(visiblePage, currentPosition, small, big); updateSafeZoneListeners()
            }
        } else if (dy < 0) {
            // finger moving down: if the list is at its top, collapse the sheet
            if (!target.canScrollVertically(-1)) {
                if (!movedByScroll) { movedByScroll = true; activePage?.onPageWillBeginScroll() }
                val newPos = min(small, currentPosition - dy)
                consumed[1] = (currentPosition - newPos).toInt()
                currentPosition = newPos
                applyTranslation(); applyProgress(visiblePage, currentPosition, small, big); updateSafeZoneListeners()
            }
        }
    }

    override fun onNestedScroll(target: View, dxConsumed: Int, dyConsumed: Int, dxUnconsumed: Int, dyUnconsumed: Int, type: Int, consumed: IntArray) {
        if (type != ViewCompat.TYPE_TOUCH) return
        if (dyUnconsumed < 0) {
            val small = position(VerticalSize.SMALL); val big = position(VerticalSize.BIG)
            if (!movedByScroll) { movedByScroll = true; activePage?.onPageWillBeginScroll() }
            val newPos = min(small, currentPosition - dyUnconsumed)
            consumed[1] += (currentPosition - newPos).toInt()
            currentPosition = newPos
            applyTranslation(); applyProgress(visiblePage, currentPosition, small, big); updateSafeZoneListeners()
        }
    }

    override fun onNestedScroll(target: View, dxConsumed: Int, dyConsumed: Int, dxUnconsumed: Int, dyUnconsumed: Int, type: Int) {
        onNestedScroll(target, dxConsumed, dyConsumed, dxUnconsumed, dyUnconsumed, type, IntArray(2))
    }

    override fun onNestedPreFling(target: View, velocityX: Float, velocityY: Float): Boolean {
        if (movedByScroll) {
            nestedFlingVelocity = velocityY
            // consume the fling while the sheet is not fully expanded, or when collapsing
            val big = position(VerticalSize.BIG)
            return currentPosition > big + 0.5f || velocityY < 0
        }
        return false
    }

    override fun onNestedFling(target: View, velocityX: Float, velocityY: Float, consumed: Boolean): Boolean = false

    override fun onStopNestedScroll(target: View, type: Int) {
        nestedHelper.onStopNestedScroll(target, type)
        if (type != ViewCompat.TYPE_TOUCH) return
        if (movedByScroll) {
            movedByScroll = false
            endAnimation(-nestedFlingVelocity)
            nestedFlingVelocity = 0f
            activePage?.onPageWillEndScroll()
        }
    }

    override fun getNestedScrollAxes(): Int = nestedHelper.nestedScrollAxes

    // ------------------------------------------------------------------ page stack

    fun push(page: BottomSheetPage, animated: Boolean) {
        stateByPage[page] = state
        val hadPages = pages.isNotEmpty()
        val from = pages.lastOrNull()
        pages += page
        page.container = this
        sheet.addView(page)
        page.onStateChange(currentSize)
        page.onStateChange(state)
        page.onBottomSheetScroll(if (currentPosition < 0) 1f else progress(currentPosition, position(VerticalSize.SMALL), position(VerticalSize.BIG)))
        delegate?.onPagePushed(page)

        if (hadPages && isAttachedToWindow) {
            lastState = state
            if (currentSize == HorizontalSize.BIG) changeState(VerticalSize.MEDIUM) else changeState(VerticalSize.BIG)
        }
        if (from != null && animated && isAttachedToWindow) {
            navigationAnimated = true
            animatePush(from, page) { navigationAnimated = false; from.visibility = View.INVISIBLE }
        } else if (from != null) {
            from.visibility = View.INVISIBLE
        }
        updateContentInsets()
    }

    fun pop(animated: Boolean): BottomSheetPage? {
        if (pages.size <= 1) return null
        lastState = state
        val target = pages.removeAt(pages.size - 1)
        val to = pages.last()
        to.visibility = View.VISIBLE
        to.onStateChange(currentSize)
        to.onStateChange(state)
        delegate?.onPagePopped(target, to)

        stateByPage.remove(target)?.let { targetState ->
            if (currentSize == HorizontalSize.BIG) {
                var changeTo = VerticalSize.MEDIUM
                when (popControllerStrategy) {
                    PopControllerStrategy.ALWAYS_MINIMIZE -> if (targetState == VerticalSize.SMALL || state == VerticalSize.SMALL) changeTo = VerticalSize.SMALL
                    PopControllerStrategy.MEDIUM_IF_NEED -> if ((targetState == VerticalSize.SMALL && state == VerticalSize.BIG) || state == VerticalSize.SMALL) changeTo = VerticalSize.SMALL
                }
                changeState(changeTo, animated = false)
            } else if (targetState.raw < state.raw) {
                changeState(targetState, animated = false)
            }
        }
        if (animated && isAttachedToWindow) {
            navigationAnimated = true
            animatePop(target, to) { sheet.removeView(target); target.container = null; navigationAnimated = false }
        } else {
            sheet.removeView(target); target.container = null
        }
        return target
    }

    /** Pops until [page] is on top; returns popped pages (in pop order). */
    fun popTo(page: BottomSheetPage, animated: Boolean): List<BottomSheetPage> {
        val idx = pages.indexOf(page)
        if (idx < 0) return emptyList()
        val popped = ArrayList<BottomSheetPage>()
        while (pages.size - 1 > idx) {
            val last = pages.last()
            val isLast = pages.size - 2 == idx
            pop(animated && isLast)?.let { popped += it } ?: break
            if (last !== popped.lastOrNull()) break
        }
        return popped
    }

    private fun animatePush(from: BottomSheetPage, to: BottomSheetPage, end: () -> Unit) {
        val w = sheet.width.toFloat()
        to.translationX = w
        to.alpha = 1f
        to.animate().translationX(0f).setDuration(Constants.TRANSITION_DURATION).setInterpolator(com.polymap.android.ui.easeInOut).withEndAction(end).start()
        from.animate().scaleX(0.98f).scaleY(0.98f).alpha(0.6f).setDuration(Constants.TRANSITION_DURATION).setInterpolator(com.polymap.android.ui.easeInOut).withEndAction {
            from.scaleX = 1f; from.scaleY = 1f; from.alpha = 1f
        }.start()
    }

    private fun animatePop(from: BottomSheetPage, to: BottomSheetPage, end: () -> Unit) {
        val w = sheet.width.toFloat()
        to.scaleX = 0.98f; to.scaleY = 0.98f; to.alpha = 0.6f
        to.animate().scaleX(1f).scaleY(1f).alpha(1f).setDuration(Constants.TRANSITION_DURATION).setInterpolator(com.polymap.android.ui.easeInOut).start()
        from.animate().translationX(w).setDuration(Constants.TRANSITION_DURATION).setInterpolator(com.polymap.android.ui.easeInOut).withEndAction(end).start()
    }

    // ------------------------------------------------------------------ BottomSheetPageDelegate (used by pages)

    fun verticalSize(): VerticalSize = state
    fun horizontalSize(): HorizontalSize = currentSize
    fun change(verticalSize: VerticalSize, animated: Boolean) = changeState(verticalSize, Constants.TRANSITION_DURATION, animated)

    /** Called by pages when their scroll view begins dragging with an offset near the top (iOS scrollViewWillBeginDragging). */
    fun isBigPosition(): Boolean = abs(currentPosition - position(VerticalSize.BIG)) < 1f
}
